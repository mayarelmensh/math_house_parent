import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_manager.dart';
import '../../../core/api/end_points.dart';
import '../../../core/cashe/shared_preferences_utils.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repository/data_sources/get_students_data_source.dart';
import '../../models/students_response_dm.dart';
@Injectable(as: GetStudentsDataSource)
class GetStudentsRemoteDataSourceImpl implements GetStudentsDataSource {
  final ApiManager apiManager;

  GetStudentsRemoteDataSourceImpl({required this.apiManager});

  @override
  Future<Either<Failures, List<StudentsDm>>> getStudents() async {
    try {
      final List<ConnectivityResult> connectivityResult =
      await Connectivity().checkConnectivity();

      if (!(connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile))) {
        return Left(ServerError(
            errorMsg: "No Internet Connection, Please check internet connection."));
      }

      var token = SharedPreferenceUtils.getData(key: 'token');

      final response = await apiManager.getData(endPoint: EndPoints.getStudents,
      options: Options(headers: {
        'Authorization':'Bearer $token',
      })
      );

      if (response.data == null) {
        return Left(ServerError(errorMsg: "No data received from server"));
      }

      final data = response.data['students'];
      if (data is! List) {
        return Left(ServerError(errorMsg: "Invalid response format"));
      }

      try {
        final students = data.map((e) {
          if (e is Map<String, dynamic>) {
            return StudentsDm.fromJson(e);
          } else {
            throw Exception("Invalid student data format");
          }
        }).toList();

        return Right(students);
      } catch (e) {
        return Left(ServerError(errorMsg: "Parsing error: ${e.toString()}"));
      }
    } catch (e) {
      return Left(NetworkError(errorMsg: "Network error: ${e.toString()}"));
    }
  }

  sendCode(){}
}
