// models/promo_code_model.dart
class PromoCodeResponse {
  final List<PaymentMethod>? paymentMethods;
  final double? newPrice;

  PromoCodeResponse({
    this.paymentMethods,
    this.newPrice,
  });

  factory PromoCodeResponse.fromJson(Map<String, dynamic> json) {
    return PromoCodeResponse(
      paymentMethods: json['payment_methods'] != null
          ? (json['payment_methods'] as List)
          .map((item) => PaymentMethod.fromJson(item))
          .toList()
          : null,
      newPrice: json['new_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_methods': paymentMethods?.map((item) => item.toJson()).toList(),
      'new_price': newPrice,
    };
  }
}

class PaymentMethod {
  final int? id;
  final String? payment;
  final String? description;
  final String? logo;
  final int? statue;
  final String? createdAt;
  final String? updatedAt;
  final String? logoLink;

  PaymentMethod({
    this.id,
    this.payment,
    this.description,
    this.logo,
    this.statue,
    this.createdAt,
    this.updatedAt,
    this.logoLink,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      payment: json['payment'],
      description: json['description'],
      logo: json['logo'],
      statue: json['statue'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      logoLink: json['logo_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment': payment,
      'description': description,
      'logo': logo,
      'statue': statue,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'logo_link': logoLink,
    };
  }
}