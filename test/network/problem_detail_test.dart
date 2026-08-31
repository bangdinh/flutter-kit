import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_test/flutter_test.dart';

/// The error contract: RFC 9457 problem bodies as b2b-gokit emits them.
void main() {
  group('ApiErrorCode', () {
    test('maps every gokit code from the wire', () {
      expect(ApiErrorCode.fromWire('NOT_FOUND'), ApiErrorCode.notFound);
      expect(
        ApiErrorCode.fromWire('VALIDATION_FAILED'),
        ApiErrorCode.validationFailed,
      );
      expect(
        ApiErrorCode.fromWire('PRECONDITION_FAILED'),
        ApiErrorCode.preconditionFailed,
      );
    });

    test('degrades on a code this kit predates, instead of throwing', () {
      expect(ApiErrorCode.fromWire('SOME_NEW_CODE'), ApiErrorCode.unknown);
      expect(ApiErrorCode.fromWire(null), ApiErrorCode.unknown);
    });
  });

  group('ProblemDetail.fromJson', () {
    test('parses a full validation problem', () {
      final problem = ProblemDetail.fromJson({
        'type': 'about:blank',
        'title': 'Validation failed',
        'status': 422,
        'code': 'VALIDATION_FAILED',
        'traceId': 'abc123',
        'errors': [
          {'field': 'email', 'code': 'REQUIRED', 'reason': 'is required'},
        ],
      });

      expect(problem.code, ApiErrorCode.validationFailed);
      expect(problem.status, 422);
      expect(problem.traceId, 'abc123');
      expect(problem.fieldErrors.single.field, 'email');
      expect(problem.fieldErrors.single.code, 'REQUIRED');
    });

    test('falls back to the response status when the body omits it', () {
      final problem = ProblemDetail.fromJson({
        'code': 'NOT_FOUND',
      }, fallbackStatus: 404);

      expect(problem.status, 404);
    });

    test('survives a malformed body — an interceptor must not throw', () {
      final problem = ProblemDetail.fromJson({'errors': 'not-a-list'});

      expect(problem.code, ApiErrorCode.unknown);
      expect(problem.fieldErrors, isEmpty);
    });
  });

  group('apiExceptionFromProblem', () {
    ApiException from(String code, int status, {List<FieldError>? fields}) {
      return apiExceptionFromProblem(
        ProblemDetail(
          status: status,
          code: ApiErrorCode.fromWire(code),
          title: 'T',
          detail: 'D',
          traceId: 'trace-1',
          fieldErrors: fields ?? const [],
        ),
      );
    }

    test('dispatches on the code, not the status', () {
      // Both are 409 — only the code tells them apart.
      expect(from('CONFLICT', 409), isA<ConflictException>());
      expect(from('ALREADY_EXISTS', 409), isA<ConflictException>());
      expect(
        from('ALREADY_EXISTS', 409).code,
        ApiErrorCode.alreadyExists,
        reason: 'the original code must survive the mapping',
      );
    });

    test('maps each family to its exception', () {
      expect(from('NOT_FOUND', 404), isA<NotFoundException>());
      expect(from('UNAUTHORIZED', 401), isA<UnauthorizedException>());
      expect(from('FORBIDDEN', 403), isA<ForbiddenException>());
      expect(from('INVALID_INPUT', 400), isA<ValidationException>());
      expect(from('VALIDATION_FAILED', 422), isA<ValidationException>());
      expect(from('RATE_LIMITED', 429), isA<RateLimitedException>());
      expect(from('TIMEOUT', 504), isA<TimeoutException>());
      expect(from('SERVICE_UNAVAILABLE', 503), isA<ServerException>());
      expect(from('INTERNAL_ERROR', 500), isA<ServerException>());
    });

    test('carries trace id and detail through', () {
      final exception = from('NOT_FOUND', 404);

      expect(exception.traceId, 'trace-1');
      expect(exception.message, 'D');
      expect(exception.title, 'T');
      expect(exception.toString(), contains('trace-1'));
    });

    test('exposes field errors for form binding', () {
      final exception =
          from(
                'VALIDATION_FAILED',
                422,
                fields: const [
                  FieldError(field: 'email', reason: 'is required'),
                ],
              )
              as ValidationException;

      expect(exception.reasonFor('email'), 'is required');
      expect(exception.reasonFor('name'), isNull);
    });

    test('an unknown code falls back to the status', () {
      expect(from('SOMETHING_NEW', 404), isA<NotFoundException>());
      expect(from('SOMETHING_NEW', 503), isA<ServerException>());
      expect(from('SOMETHING_NEW', 418), isA<UnknownApiException>());
    });
  });

  group('apiExceptionToMessage', () {
    test('prefers a field reason for validation failures', () {
      const exception = ValidationException(
        fieldErrors: [FieldError(field: 'email', reason: 'Email is required')],
      );

      expect(apiExceptionToMessage(exception), 'Email is required');
    });

    test('never leaks a trace id to the user', () {
      const exception = NotFoundException(traceId: 'abc123', message: 'raw');

      expect(apiExceptionToMessage(exception), isNot(contains('abc123')));
      expect(apiExceptionToMessage(exception), isNot(contains('raw')));
    });
  });
}
