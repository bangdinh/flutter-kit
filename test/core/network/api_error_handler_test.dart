import 'package:dio/dio.dart';
import 'package:flutter_kit/core/network/errors/api_exception.dart';
import 'package:flutter_kit/core/network/helpers/api_error_handler.dart';
import 'package:flutter_kit/shared/models/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('apiCall', () {
    test('returns Success on successful call', () async {
      final result = await apiCall(() async => 42);

      expect(result, isA<Success<int>>());
      expect(result.dataOrNull, 42);
    });

    test('returns Failure on DioException with ApiException error', () async {
      final result = await apiCall<int>(() async {
        throw DioException(
          requestOptions: RequestOptions(),
          error: const TimeoutException(),
          type: DioExceptionType.connectionTimeout,
        );
      });

      expect(result, isA<Failure<int>>());
      switch (result) {
        case Failure(:final exception):
          expect(exception, isA<TimeoutException>());
        default:
          fail('Expected Failure');
      }
    });

    test('returns Failure on plain ApiException', () async {
      final result = await apiCall<String>(() async {
        throw const UnauthorizedException();
      });

      expect(result, isA<Failure<String>>());
    });

    test('wraps unknown exceptions as UnknownApiException', () async {
      final result = await apiCall<String>(() async {
        throw Exception('random error');
      });

      switch (result) {
        case Failure(:final exception):
          expect(exception, isA<UnknownApiException>());
        default:
          fail('Expected Failure');
      }
    });
  });

  group('apiExceptionToMessage', () {
    test('maps UnauthorizedException', () {
      expect(
        apiExceptionToMessage(const UnauthorizedException()),
        contains('sign in'),
      );
    });

    test('maps NotFoundException', () {
      expect(
        apiExceptionToMessage(const NotFoundException()),
        contains('not found'),
      );
    });

    test('maps TimeoutException', () {
      expect(
        apiExceptionToMessage(const TimeoutException()),
        contains('timed out'),
      );
    });

    test('maps NetworkException', () {
      expect(
        apiExceptionToMessage(const NetworkException()),
        contains('internet'),
      );
    });

    test('maps ServerException with status code', () {
      final msg = apiExceptionToMessage(
        const ServerException(statusCode: 503),
      );
      expect(msg, contains('503'));
    });
  });
}
