abstract class ResetPasswordState {}

class ResetPasswordInitialState extends ResetPasswordState {}

class ResetPasswordLoadingState extends ResetPasswordState {}

class ResetPasswordSuccessState extends ResetPasswordState {
  final String message;
  ResetPasswordSuccessState(this.message);
}

class ResetPasswordErrorState extends ResetPasswordState {
  final String errorMessage;
  ResetPasswordErrorState(this.errorMessage);
}