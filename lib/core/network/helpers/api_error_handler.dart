import 'package:dio/dio.dart';

import '../../../shared/models/result.dart';
import '../errors/api_exception.dart';

/// Generic wrapper for API calls — catches Dio errors and returns [Result].
///
/// Andrea's tip #44: AsyncValue.guard vs try-catch
/// — centralizes error handling so feature code stays clean.
///
/// Usage in repository:
///   ```dart
///   Future<Result<User>> getUser(String id) {
///     return apiCall(() async {
///       final response = await dio.get('/users/$id');
///       return UserModel.fromJson(response.data).toEntity();
///     });
///   }
///   ```
Future<Result<T>> apiCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Result.success(result);
  } on DioException catch (e) {
    final apiException = e.error is ApiException
        ? e.error as ApiException
        : UnknownApiException(message: e.message, error: e);
    return Result.failure(apiException);
  } on ApiException catch (e) {
    return Result.failure(e);
  } on Exception catch (e) {
    return Result.failure(UnknownApiException(error: e));
  }
}

/// Maps [ApiException] to user-facing message.
///
/// Override this in your app for custom messages or localization.
String apiExceptionToMessage(ApiException exception) {
  return switch (exception) {
    UnauthorizedException() => 'Session expired. Please sign in again.',
    NotFoundException() => 'The requested resource was not found.',
    TimeoutException() => 'Request timed out. Please try again.',
    NetworkException() => 'No internet connection. Check your network.',
    ServerException(:final statusCode) =>
      'Server error${statusCode != null ? ' ($statusCode)' : ''}. Please try later.',
    UnknownApiException() => 'Something went wrong. Please try again.',
  };
}
