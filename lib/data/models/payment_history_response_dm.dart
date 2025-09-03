// payment_model.dart
class PaymentModel {
  final int id;
  final String date;
  final String paymentMethod;
  final int price;
  final String service;
  final String status;

  PaymentModel({
    required this.id,
    required this.date,
    required this.paymentMethod,
    required this.price,
    required this.service,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      price: json['price'] ?? 0,
      service: json['service'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'payment_method': paymentMethod,
      'price': price,
      'service': service,
      'status': status,
    };
  }

  // Helper methods
  bool get isPending => status.toLowerCase() == 'pendding' || status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approve' || status.toLowerCase() == 'approved';

  String get formattedPrice => '${price.toString()} جنيه';

  String get statusInArabic {
    if (isPending) return 'في الانتظار';
    if (isApproved) return 'مقبول';
    return status;
  }
}

class PaymentResponse {
  final List<PaymentModel> payments;

  PaymentResponse({required this.payments});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    var paymentsList = json['payments'] as List;
    List<PaymentModel> payments = paymentsList
        .map((paymentJson) => PaymentModel.fromJson(paymentJson))
        .toList();

    return PaymentResponse(payments: payments);
  }
}