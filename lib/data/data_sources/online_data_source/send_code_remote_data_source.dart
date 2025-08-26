import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/repository/data_sources/send_code_data_source.dart';
import '../../../core/cashe/shared_preferences_utils.dart';
import '../../models/send_code_response_dm.dart';
@Injectable(as: SendCodeDataSource)
class SendCodeRemoteDataSourceImpl implements SendCodeDataSource {
  ApiManager apiManager;

  SendCodeRemoteDataSourceImpl({required this.apiManager});

  @override
  Future<Either<Failures, SendCodeResponseDm>> sendCode(int id) async {
    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity()
          .checkConnectivity();

      if (!(connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile))) {
        return Left(
          ServerError(
            errorMsg:
                "No Internet Connection, Please check internet connection.",
          ),
        );
      }
      var token = SharedPreferenceUtils.getData(key: 'token');

      var response = await apiManager.postData(
        endPoint: EndPoints.addStudent,
        options: Options(headers: {
          'Authorization': 'Bearer $token'}),
           body: {"user_id": id},
      );

      if (response.statusCode == 200) {
        final result = SendCodeResponseDm.fromJson(response.data);
        return Right(result);
      } else {
        return Left(
          ServerError(
            errorMsg:
                response.data['errors']?.toString() ?? "Unknown error occurred",
          ),
        );
      }
    } catch (e) {
      return Left(ServerError(errorMsg: e.toString()));
    }
  }
}
