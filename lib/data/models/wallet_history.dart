class WalletResponse {
  final List<WalletHistory>? wallet_history;
  final int? money;
  final List<PaymentMethod>? payment_methods;

  WalletResponse({
    this.wallet_history,
    this.money,
    this.payment_methods,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      wallet_history: (json['wallet_history'] as List<dynamic>?)
          ?.map((e) => WalletHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      money: json['money'] is int ? json['money'] : int.tryParse(json['money'].toString() ?? '0'),
      payment_methods: (json['payment_methods'] as List<dynamic>?)
          ?.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WalletHistory {
  final int? wallet;
  final String? date;
  final String? state;
  final String? payment_method;
  final String? rejected_reason;

  WalletHistory({
    this.wallet,
    this.date,
    this.state,
    this.payment_method,
    this.rejected_reason,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      wallet: json['wallet'] is int ? json['wallet'] : int.tryParse(json['wallet'].toString() ?? '0'),
      date: json['date']?.toString(),
      state: json['state']?.toString(),
      payment_method: json['payment_method']?.toString(),
      rejected_reason: json['rejected_reason']?.toString(),
    );
  }
}

class PaymentMethod {
  final int? id;
  final String? payment;
  final String? description;
  final String? logo;
  final int? statue;
  final String? created_at;
  final String? updated_at;
  final String? logo_link;

  PaymentMethod({
    this.id,
    this.payment,
    this.description,
    this.logo,
    this.statue,
    this.created_at,
    this.updated_at,
    this.logo_link,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString() ?? '0'),
      payment: json['payment']?.toString(),
      description: json['description']?.toString(),
      logo: json['logo']?.toString(),
      statue: json['statue'] is int ? json['statue'] : int.tryParse(json['statue'].toString() ?? '0'),
      created_at: json['created_at']?.toString(),
      updated_at: json['updated_at']?.toString(),
      logo_link: json['logo_link']?.toString(),
    );
  }
}