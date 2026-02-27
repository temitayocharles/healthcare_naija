sealed class AppResult<T> {
  const AppResult();

  bool get isSuccess => this is AppSuccess<T>;
  bool get isFailure => this is AppFailure<T>;
}

class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.data);

  final T data;
}

class AppFailure<T> extends AppResult<T> {
  const AppFailure({
    required this.code,
    required this.message,
    this.retriable = false,
    this.cause,
  });

  final String code;
  final String message;
  final bool retriable;
  final Object? cause;
}
