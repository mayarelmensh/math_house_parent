import 'package:math_house_parent/domain/entities/buy_package_entity.dart';

class BuyPackageResponseDm extends BuyPackageEntity  {
  BuyPackageResponseDm({required super.success});


  factory BuyPackageResponseDm.fromJson(Map<String, dynamic> json) {
    return BuyPackageResponseDm(success: json['success']);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }

  BuyPackageEntity toEntity() {
    return BuyPackageEntity(success: success);
  }
}
