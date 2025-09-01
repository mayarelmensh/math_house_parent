import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/data/models/get_students_response_dm.dart';
import '../../../core/api/api_manager.dart';
import '../../../core/api/end_points.dart';
import '../../../core/cache/shared_preferences_utils.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repository/data_sources/remote_data_source/packages_data_source.dart';
import '../../models/packages_response_dm.dart' hide CourseDm;
import '../../models/courses_response_dm.dart';

@Injectable(as: PackagesRemoteDataSource)
class PackagesRemoteDataSourceImpl implements PackagesRemoteDataSource {
  final ApiManager apiManager;
  PackagesRemoteDataSourceImpl({required this.apiManager});

  @override
  @override
  Future<Either<Failures, PackagesResponseDm>> getPackages({required int courseId, required int userId}) async {
    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      if (token == null) {
        return Left(ServerError(errorMsg: "Authentication token not found"));
      }

      final response = await apiManager.postData(
        body: {
          'user_id': userId,
        },
        endPoint: '${EndPoints.packages}$courseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        return Left(ServerError(errorMsg: 'Failed to fetch packages. Status: ${response.statusCode}'));
      }

      if (response.data == null) {
        return Left(ServerError(errorMsg: "No data received from server"));
      }

      final packagesResponse = PackagesResponseDm.fromJson(response.data);
      return Right(packagesResponse);
    } catch (e) {
      return Left(ServerError(errorMsg: e.toString()));
    }
  }

  @override
  Future<Either<Failures, Map<int, List<PackagesResponseDm>>>> getPackagesForAllStudents({
    required List<CourseDm> courses,
    required List<StudentsDm> myStudents,
  }) async {
    try {
      var token = SharedPreferenceUtils.getData(key: 'token');

      // Check token
      if (token == null) {
        return Left(ServerError(errorMsg: "Authentication token not found"));
      }

      Map<int, List<PackagesResponseDm>> packagesByCourse = {};

      // Loop through each course
      for (var course in courses) {
        List<PackagesResponseDm> coursePackages = [];

        // Loop through each student for this course
        for (var student in myStudents) {
          try {
            final response = await apiManager.postData(
              body: {
                'user_id': student.id
              },
              endPoint: '${EndPoints.packages}${course.id}',
              options: Options(
                  headers: {'Authorization': 'Bearer $token'}
              ),
            );

            // Check status code
            if (response.statusCode == 200 && response.data != null) {
              // Parse response
              final packages = PackagesResponseDm.fromJson(response.data);
              coursePackages.add(packages);
            }
          } catch (e) {
            // Log error for this specific student/course combination but continue
            print('Error fetching packages for student ${student.id} in course ${course.id}: $e');
          }
        }

        // Add packages for this course
        if (course.id != null) {
          packagesByCourse[course.id!] = coursePackages;
        }
      }

      return Right(packagesByCourse);

    } on DioException catch (dioError) {
      String errorMessage = "Network error: ${dioError.message}";
      if (dioError.response?.statusCode != null) {
        errorMessage = "Server error: ${dioError.response!.statusCode}";
      }
      return Left(ServerError(errorMsg: errorMessage));
    } catch (e) {
      return Left(ServerError(errorMsg: "Error: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failures, List<PackagesResponseDm>>> getPackagesForSpecificCourse({
    required int courseId,
    required List<StudentsDm> myStudents,
  }) async {
    try {
      var token = SharedPreferenceUtils.getData(key: 'token');

      // Check token
      if (token == null) {
        return Left(ServerError(errorMsg: "Authentication token not found"));
      }

      List<PackagesResponseDm> allPackages = [];

      // Loop through each student for the specific course
      for (var student in myStudents) {
        try {
          final response = await apiManager.postData(
            body: {
              'user_id': student.id
            },
            endPoint: '${EndPoints.packages}$courseId',
            options: Options(
                headers: {'Authorization': 'Bearer $token'}
            ),
          );

          // Check status code and parse response
          if (response.statusCode == 200 && response.data != null) {
            final packages = PackagesResponseDm.fromJson(response.data);
            allPackages.add(packages);
          }
        } catch (e) {
          // Log error for this specific student but continue with others
          print('Error fetching packages for student ${student.id}: $e');
        }
      }

      return Right(allPackages);

    } on DioException catch (dioError) {
      String errorMessage = "Network error: ${dioError.message}";
      if (dioError.response?.statusCode != null) {
        errorMessage = "Server error: ${dioError.response!.statusCode}";
      }
      return Left(ServerError(errorMsg: errorMessage));
    } catch (e) {
      return Left(ServerError(errorMsg: "Error: ${e.toString()}"));
    }
  }
}

