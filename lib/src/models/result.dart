/// A Result type for explicit error handling without exceptions.
///
/// Follows Andrea's tip #62: try-catch & Result type
/// — makes success/failure explicit in the type system.
///
/// Usage:
///   ```dart
///   Future<Result<User>> login(String email, String password) async {
///     try {
///       final user = await api.login(email, password);
///       return Result.success(user);
///     } on ApiException catch (e) {
///       return Result.failure(e);
///     }
///   }
///   ```
///
///   Consuming:
///   ```dart
///   final result = await login(email, password);
///   switch (result) {
///     case Success(:final data):
///       // handle data
///     case Failure(:final exception):
///       // handle error
///   }
///   ```
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Exception exception) = Failure<T>;

  /// Transforms the success value.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Result.success(transform(data)),
      Failure(:final exception) => Result.failure(exception),
    };
  }

  /// Transforms the success value with an async function.
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(:final data) => Result.success(await transform(data)),
      Failure(:final exception) => Result.failure(exception),
    };
  }

  /// Returns the data if success, or null if failure.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.exception);
  final Exception exception;
}
