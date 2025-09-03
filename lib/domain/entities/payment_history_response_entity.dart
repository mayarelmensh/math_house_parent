class PaymentHistoryResponseEntity {
  final int id;
  final String date;
  final String paymentMethod;
  final int price;
  final String service;
  final String status;

  const PaymentHistoryResponseEntity({
    required this.id,
    required this.date,
    required this.paymentMethod,
    required this.price,
    required this.service,
    required this.status,
  });
}
