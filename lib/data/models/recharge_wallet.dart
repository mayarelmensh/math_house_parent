// wallet_recharge_response_entity.dart
class WalletRechargeResponseEntity {
  final String? success;

  WalletRechargeResponseEntity({
    this.success,
  });

  factory WalletRechargeResponseEntity.fromJson(Map<String, dynamic> json) {
    return WalletRechargeResponseEntity(
      success: json['success'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}