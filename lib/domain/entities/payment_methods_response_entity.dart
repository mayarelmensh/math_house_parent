class PaymentMethodsResponseEntity {
  final List<PaymentMethodEntity>? paymentMethods;

  PaymentMethodsResponseEntity({this.paymentMethods});
}

class PaymentMethodEntity {
  final dynamic? id;
  final String? payment;
  final String? paymentType;
  final String? description;
  final String? logo;

  PaymentMethodEntity({
    this.id,
    this.payment,
    this.paymentType,
    this.description,
    this.logo,
  });
}