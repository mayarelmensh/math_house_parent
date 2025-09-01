import '../../../domain/entities/payment_methods_response_entity.dart';

class PaymentMethodsResponseDm extends PaymentMethodsResponseEntity {
  PaymentMethodsResponseDm({super.paymentMethods});

  factory PaymentMethodsResponseDm.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponseDm(
      paymentMethods: json['payment_methods'] != null
          ? List<PaymentMethodDm>.from(
          json['payment_methods'].map((x) => PaymentMethodDm.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_methods': paymentMethods
          ?.map((x) => (x as PaymentMethodDm).toJson())
          .toList(),
    };
  }
}

class PaymentMethodDm extends PaymentMethodEntity {
  PaymentMethodDm({
    super.id,
    super.payment,
    super.paymentType,
    super.description,
    super.logo,
  });

  factory PaymentMethodDm.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDm(
      id: json['id'],
      payment: json['payment'],
      paymentType: json['payment_type'],
      description: json['description'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment': payment,
      'payment_type': paymentType,
      'description': description,
      'logo': logo,
    };
  }
}