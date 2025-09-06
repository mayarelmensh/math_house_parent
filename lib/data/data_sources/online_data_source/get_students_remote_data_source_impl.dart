import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/api/api_manager.dart';
import '../../../core/api/end_points.dart';
import '../../../core/cache/shared_preferences_utils.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repository/data_sources/remote_data_source/get_students_data_source.dart';
import '../../models/get_students_response_dm.dart';

@Injectable(as: GetStudentsRemoteDataSource)
class GetStudentsRemoteDataSourceImpl implements GetStudentsRemoteDataSource {
  final ApiManager apiManager;

  GetStudentsRemoteDataSourceImpl({required this.apiManager});

  @override
  Future<Either<Failures, List<StudentsDm>>> getStudents() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!(connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile))) {
        return Left(NetworkError(errorMsg: "No Internet Connection, Please check your connection."));
      }

      var token = SharedPreferenceUtils.getData(key: 'token');

      final response = await apiManager.getData(
        endPoint: EndPoints.getStudents,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data == null) {

        return Left(ServerError(errorMsg: "No data received from server"));
      }

      final data = response.data['students'];
      if (data is! List) {
        return Left(ServerError(errorMsg: "Invalid response format for students list"));
      }

      final students = data.map((e) {
        if (e is Map<String, dynamic>) {
          return StudentsDm.fromJson(e);
        } else {
          throw Exception("Invalid student data format");
        }
      }).toList();

      return Right(students);
    } catch (e) {
      return Left(ServerError(errorMsg: e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<StudentsDm>>> getMyStudents() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!(connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile))) {
        return Left(NetworkError(errorMsg: "No Internet Connection, Please check your connection."));
      }

      var token = SharedPreferenceUtils.getData(key: 'token');

      final response = await apiManager.getData(
        endPoint: EndPoints.getStudents,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data == null) {
        return Left(ServerError(errorMsg: "No data received from server"));
      }

      final data = response.data['my_students'];
      if (data is! List) {
        return Left(ServerError(errorMsg: "Invalid response format for my_students list"));
      }

      final myStudents = data.map((e) {
        if (e is Map<String, dynamic>) {
          return StudentsDm.fromJson(e);
        } else {
          throw Exception("Invalid my_student data format");
        }
      }).toList();

      return Right(myStudents);
    } catch (e) {
      return Left(ServerError(errorMsg: e.toString()));
    }
  }
}
