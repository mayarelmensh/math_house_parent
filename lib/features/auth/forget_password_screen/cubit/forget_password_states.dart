abstract class ForgetPasswordState {}

class ForgetPasswordInitialState extends ForgetPasswordState {}

class ForgetPasswordLoadingState extends ForgetPasswordState {}

class ForgetPasswordSuccessState extends ForgetPasswordState {
  final String message;
  ForgetPasswordSuccessState(this.message);
}

class ForgetPasswordErrorState extends ForgetPasswordState {
  final String errorMessage;
  ForgetPasswordErrorState(this.errorMessage);
}