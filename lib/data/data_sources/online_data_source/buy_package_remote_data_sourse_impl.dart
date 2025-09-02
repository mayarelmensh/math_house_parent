import 'package:injectable/injectable.dart';
import 'package:math_house_parent/data/models/buy_package_response_dm.dart';
import '../../../core/api/api_manager.dart';
import '../../../domain/repository/data_sources/remote_data_source/buy_package_data_sourse.dart';
@Injectable(as:BuyPackageRemoteDataSource )
class BuyPackageRemoteDataSourceImpl implements BuyPackageRemoteDataSource {
final ApiManager apiManager;

BuyPackageRemoteDataSourceImpl(this.apiManager);

@override
Future<BuyPackageResponseDm> buyPackage({
  required int userId,
  required int paymentMethodId,
  required String image,
  required int packageId,
}) async {
  final response = await apiManager.postData(
    endPoint: '/parent/packages/payment_package/$packageId',
    body: {
      'user_id': userId,
      'payment_method_id': paymentMethodId,
      'image': image,
    },
  );

  return BuyPackageResponseDm.fromJson(response.data);
}
}