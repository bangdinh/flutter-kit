import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/result.dart';
import '../errors/api_exception.dart';

part 'api_error_handler.g.dart';

/// Wraps a call to a data source and returns a [Result] instead of throwing.
///
/// Use it in the **repository** layer so feature code never handles Dio types:
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
    final apiException =
        e.error is ApiException
            ? e.error! as ApiException
            : UnknownApiException(message: e.message, error: e);
    return Result.failure(apiException);
  } on ApiException catch (e) {
    return Result.failure(e);
  } on Exception catch (e) {
    return Result.failure(UnknownApiException(error: e));
  }
}

/// Maps an [ApiException] to a user-facing message.
///
/// App rule: subclass and override [message] for wording or localization,
/// then override [apiErrorMessagesProvider]. Call `super.message(exception)`
/// for the cases you don't want to change.
class ApiErrorMessages {
  const ApiErrorMessages();

  String message(ApiException exception) => apiExceptionToMessage(exception);
}

/// The active [ApiErrorMessages]. Override in the app for localized copy.
@Riverpod(keepAlive: true)
ApiErrorMessages apiErrorMessages(Ref ref) => const ApiErrorMessages();

/// Kit default wording — English, deliberately generic.
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
