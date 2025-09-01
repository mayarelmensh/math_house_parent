import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/data/models/courses_response_dm.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/courses_list_data_source.dart';
import '../../../core/cache/shared_preferences_utils.dart';
@Injectable(as:CoursesListDataSource )
class CoursesListRemoteDataSourceImpl implements CoursesListDataSource {
  ApiManager apiManager;
  CoursesListRemoteDataSourceImpl({required this.apiManager});
  @override
  Future<Either<Failures, CoursesResponseDm>> getCoursesList() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!(connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile))) {
        return Left(
          NetworkError(
            errorMsg: "No Internet Connection, Please check your connection.",
          ),
        );
      }
      var token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.getData(
        endPoint: EndPoints.coursesList,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data == null) {
        return Left(ServerError(errorMsg: "No data received from server"));
      }
      final coursesResponse = CoursesResponseDm.fromJson(response.data);
      return Right(coursesResponse);
    } catch (e) {
      return Left(ServerError(errorMsg: e.toString()));
    }
  }
}
