import 'problem_detail.dart';

/// Every failure the kit's HTTP layer produces.
///
/// Sealed on purpose: a `switch` over it is exhaustive, so adding a case here
/// breaks the compile in apps instead of silently falling into a default
/// branch. Subtypes follow gokit's [ApiErrorCode], not the HTTP status —
/// `CONFLICT` and `ALREADY_EXISTS` share status 409 but mean different things.
///
/// Everything a gokit error body carries is preserved: [code], [statusCode],
/// [title], [message] and [traceId]. Log the trace id — it is what the backend
/// searches on.
sealed class ApiException implements Exception {
  const ApiException({
    this.message,
    this.statusCode,
    this.code = ApiErrorCode.unknown,
    this.title,
    this.traceId,
  });

  /// `detail` from the problem body, or a transport-level description.
  final String? message;

  final int? statusCode;

  /// Stable server code. `unknown` when the failure never reached the server.
  final ApiErrorCode code;

  /// `title` from the problem body — stable summary of the error type.
  final String? title;

  /// Correlation id for the failed request, when the server sent one.
  final String? traceId;

  @override
  String toString() =>
      '$runtimeType(${code.wireValue}'
      '${statusCode != null ? ', $statusCode' : ''}): ${message ?? title ?? ''}'
      '${traceId != null ? ' [trace=$traceId]' : ''}';
}

/// `NOT_FOUND` — 404.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message,
    super.statusCode = 404,
    super.code = ApiErrorCode.notFound,
    super.title,
    super.traceId,
  });
}

/// `UNAUTHORIZED` — 401. Raised after token refresh failed or was absent.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message,
    super.statusCode = 401,
    super.code = ApiErrorCode.unauthorized,
    super.title,
    super.traceId,
  });
}

/// `FORBIDDEN` — 403. Authenticated, but not allowed. Distinct from
/// [UnauthorizedException]: signing in again will not help.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message,
    super.statusCode = 403,
    super.code = ApiErrorCode.forbidden,
    super.title,
    super.traceId,
  });
}

/// `VALIDATION_FAILED` (422) or `INVALID_INPUT` (400) — the request was
/// understood and rejected. [fieldErrors] is what a form binds its inline
/// messages to.
class ValidationException extends ApiException {
  const ValidationException({
    super.message,
    super.statusCode,
    super.code = ApiErrorCode.validationFailed,
    super.title,
    super.traceId,
    this.fieldErrors = const [],
  });

  final List<FieldError> fieldErrors;

  /// Reason for [field], if the server flagged it. Feed this straight into a
  /// `TextFormField.validator`.
  String? reasonFor(String field) {
    for (final error in fieldErrors) {
      if (error.field == field) return error.reason;
    }
    return null;
  }
}

/// `ALREADY_EXISTS` / `CONFLICT` / `PRECONDITION_FAILED` — the request clashed
/// with server state. Usually recoverable by refetching and retrying.
class ConflictException extends ApiException {
  const ConflictException({
    super.message,
    super.statusCode = 409,
    super.code = ApiErrorCode.conflict,
    super.title,
    super.traceId,
  });
}

/// `RATE_LIMITED` — 429. [retryAfter] comes from the `Retry-After` header when
/// the server sends one.
class RateLimitedException extends ApiException {
  const RateLimitedException({
    super.message,
    super.statusCode = 429,
    super.code = ApiErrorCode.rateLimited,
    super.title,
    super.traceId,
    this.retryAfter,
  });

  final Duration? retryAfter;
}

/// `TIMEOUT` (504) or a client-side connect/send/receive timeout.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.statusCode,
    super.code = ApiErrorCode.timeout,
    super.title,
    super.traceId,
  });
}

/// The request never completed: no connectivity, DNS failure, socket error.
/// There is no server response, so there is no code or trace id.
class NetworkException extends ApiException {
  const NetworkException({super.message = 'No internet connection'});
}

/// `INTERNAL_ERROR`, `SERVICE_UNAVAILABLE`, `DATA_LOSS`, `UNIMPLEMENTED`, or any
/// other 5xx — the server failed. Nothing the user did caused it.
class ServerException extends ApiException {
  const ServerException({
    super.message,
    super.statusCode,
    super.code = ApiErrorCode.internalError,
    super.title,
    super.traceId,
  });
}

/// A response the kit could not classify: a cancelled request, a non-problem
/// error body, or a code newer than this kit version.
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unexpected error occurred',
    super.statusCode,
    super.code,
    super.title,
    super.traceId,
    this.error,
  });

  /// The underlying object, when there was one.
  final Object? error;
}

/// Builds the right [ApiException] subtype from a parsed problem body.
///
/// Dispatch is on [ProblemDetail.code] first — it is the stable contract — and
/// falls back to the status only for a code this kit doesn't know.
ApiException apiExceptionFromProblem(
  ProblemDetail problem, {
  Duration? retryAfter,
}) {
  final message = problem.detail;
  final title = problem.title.isEmpty ? null : problem.title;
  final status = problem.status == 0 ? null : problem.status;
  final traceId = problem.traceId;

  return switch (problem.code) {
    ApiErrorCode.notFound => NotFoundException(
      message: message,
      statusCode: status,
      title: title,
      traceId: traceId,
    ),
    ApiErrorCode.unauthorized => UnauthorizedException(
      message: message,
      statusCode: status,
      title: title,
      traceId: traceId,
    ),
    ApiErrorCode.forbidden => ForbiddenException(
      message: message,
      statusCode: status,
      title: title,
      traceId: traceId,
    ),
    ApiErrorCode.validationFailed ||
    ApiErrorCode.invalidInput ||
    ApiErrorCode.outOfRange => ValidationException(
      message: message,
      statusCode: status,
      code: problem.code,
      title: title,
      traceId: traceId,
      fieldErrors: problem.fieldErrors,
    ),
    ApiErrorCode.alreadyExists ||
    ApiErrorCode.conflict ||
    ApiErrorCode.preconditionFailed => ConflictException(
      message: message,
      statusCode: status,
      code: problem.code,
      title: title,
      traceId: traceId,
    ),
    ApiErrorCode.rateLimited => RateLimitedException(
      message: message,
      statusCode: status,
      title: title,
      traceId: traceId,
      retryAfter: retryAfter,
    ),
    ApiErrorCode.timeout => TimeoutException(
      message: message ?? 'Request timed out',
      statusCode: status,
      title: title,
      traceId: traceId,
    ),
    ApiErrorCode.internalError ||
    ApiErrorCode.serviceUnavailable ||
    ApiErrorCode.dataLoss ||
    ApiErrorCode.unimplemented => ServerException(
      message: message,
      statusCode: status,
      code: problem.code,
      title: title,
      traceId: traceId,
    ),
    // Unknown code: fall back to the status, so a service that adds a code
    // still maps to something sensible instead of a generic failure.
    ApiErrorCode.unknown => _fromStatus(problem, retryAfter: retryAfter),
  };
}

ApiException _fromStatus(ProblemDetail problem, {Duration? retryAfter}) {
  final message = problem.detail;
  final title = problem.title.isEmpty ? null : problem.title;
  final status = problem.status == 0 ? null : problem.status;
  final traceId = problem.traceId;

  return switch (status) {
    401 => UnauthorizedException(
      message: message,
      title: title,
      traceId: traceId,
    ),
    403 => ForbiddenException(message: message, title: title, traceId: traceId),
    404 => NotFoundException(message: message, title: title, traceId: traceId),
    409 => ConflictException(message: message, title: title, traceId: traceId),
    422 || 400 => ValidationException(
      message: message,
      statusCode: status,
      title: title,
      traceId: traceId,
      fieldErrors: problem.fieldErrors,
    ),
    429 => RateLimitedException(
      message: message,
      title: title,
      traceId: traceId,
      retryAfter: retryAfter,
    ),
    504 => TimeoutException(
      message: message ?? 'Request timed out',
      statusCode: status,
      title: title,
      traceId: traceId,
    ),
    final int code when code >= 500 => ServerException(
      message: message,
      statusCode: code,
      title: title,
      traceId: traceId,
    ),
    _ => UnknownApiException(
      message: message,
      statusCode: status,
      title: title,
      traceId: traceId,
    ),
  };
}
