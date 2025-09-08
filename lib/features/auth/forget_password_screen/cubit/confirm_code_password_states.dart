abstract class OtpVerificationState {}

class OtpVerificationInitialState extends OtpVerificationState {}

class OtpVerificationLoadingState extends OtpVerificationState {}

class OtpVerificationSuccessState extends OtpVerificationState {
  final String message;
  OtpVerificationSuccessState(this.message);
}

class OtpVerificationErrorState extends OtpVerificationState {
  final String errorMessage;
  OtpVerificationErrorState(this.errorMessage);
}