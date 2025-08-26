class SendCodeResponseEntity {
  final String? successMessage;
  final Map<String, List<String>>? errors;

  const SendCodeResponseEntity({
    this.successMessage,
    this.errors,
  });

  bool get isSuccess => successMessage != null;
}
