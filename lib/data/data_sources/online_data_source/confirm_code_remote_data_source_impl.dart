import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/data/models/confirm_code_response_dm.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/confirm_code_data_source.dart';
import '../../../core/cache/shared_preferences_utils.dart';
@Injectable(as:ConfirmCodeDataSource)
class ConfirmCodeRemoteDataSourceImpl implements ConfirmCodeDataSource{
  ApiManager apiManager;
  ConfirmCodeRemoteDataSourceImpl({required this.apiManager});
  @override
  Future<Either<Failures, ConfirmCodeDm>> confirmCode(int code) async{
   try{
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

    var response=await apiManager.postData(endPoint: EndPoints.confirmCode,
       options: Options(headers: {
         'Authorization': 'Bearer $token'
       }),
       body: {
       "code":code
       }
     );

     if(response.statusCode==200){
     var result=  ConfirmCodeDm.fromJson(response.data);
     return Right(result);
     }else{
       return Left(ServerError(errorMsg:
       response.data['errors']?.toString() ?? "Unknown error occurred"));
     }
   }catch (e){
     return Left(ServerError(errorMsg: e.toString()));
   }
  }
}