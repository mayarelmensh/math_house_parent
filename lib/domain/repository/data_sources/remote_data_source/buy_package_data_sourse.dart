import 'package:math_house_parent/domain/entities/buy_package_entity.dart';

abstract class BuyPackageRemoteDataSource {
  Future<BuyPackageEntity> buyPackage({
    required int userId,
    required int paymentMethodId,
    required String image,
    required int packageId,
  });
}