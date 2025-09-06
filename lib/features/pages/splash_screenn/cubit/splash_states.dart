
class SplashStates {}

class SplashInitial extends SplashStates {}

class SplashLoading extends SplashStates {}

class SplashNavigate extends SplashStates {
  final String route;
  SplashNavigate(this.route);
}

class SplashError extends SplashStates {
  final String message;
  SplashError(this.message);
}