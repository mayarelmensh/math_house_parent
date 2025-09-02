import 'package:injectable/injectable.dart';

import '../../domain/entities/buy_package_entity.dart';
import '../../domain/repository/buy_package/buy_package_repository.dart';
import '../../domain/repository/data_sources/remote_data_source/buy_package_data_sourse.dart';

@Injectable(as: BuyPackageRepository)
class BuyPackageRepositoryImpl implements BuyPackageRepository {
  final BuyPackageRemoteDataSource remoteDataSource;

  BuyPackageRepositoryImpl(this.remoteDataSource);

  @override
  Future<BuyPackageEntity> buyPackage({
    required int userId,
    required int paymentMethodId,
    required String image,
    required int packageId,
  }) async {
    // هنا لازم dm يكون من نوع BuyPackageDM
    final BuyPackageEntity dm = await remoteDataSource.buyPackage(
        userId: userId,
        paymentMethodId: paymentMethodId,
        image: image,
        packageId: packageId
    );

    // كده صح
    return dm;
  }
}