
abstract class Failures{
  String errorMsg;
  Failures({required this.errorMsg});

}
class ServerError extends Failures{
  ServerError({required super.errorMsg});

}

class NetworkError extends Failures{
  NetworkError({required super.errorMsg});
}

class ValidationFailure extends Failures {
  ValidationFailure({required super.errorMsg});
}

class UnauthorizedFailure extends Failures {
  UnauthorizedFailure({required super.errorMsg});
}

class NotFoundFailure extends Failures {
  NotFoundFailure({required super.errorMsg});
}