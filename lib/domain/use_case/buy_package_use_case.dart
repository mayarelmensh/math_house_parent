import 'package:injectable/injectable.dart';
import '../entities/buy_package_entity.dart';
import '../repository/buy_package/buy_package_repository.dart';

@lazySingleton
class BuyPackageUseCase {
  final BuyPackageRepository repository;

  BuyPackageUseCase(this.repository);

  Future<BuyPackageEntity> execute({
    required int userId,
    required int paymentMethodId,
    required String image,
    required int packageId,
  }) {
    return repository.buyPackage(
      userId: userId,
      paymentMethodId: paymentMethodId,
      image: image,
      packageId: packageId,
    );
  }
}
