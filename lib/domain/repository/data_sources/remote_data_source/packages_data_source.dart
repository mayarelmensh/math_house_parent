import 'package:dartz/dartz.dart';
import 'package:math_house_parent/data/models/get_students_response_dm.dart';
import 'package:math_house_parent/domain/entities/packages_response_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/models/courses_response_dm.dart';

abstract class PackagesRemoteDataSource {
  /// Original method - kept for backward compatibility
  Future<Either<Failures, PackagesResponseEntity>> getPackages({required int courseId,required int userId});

  /// Get packages for all students across all courses
  /// Returns a Map where key is courseId and value is list of packages for that course
  Future<Either<Failures, Map<int, List<PackagesResponseEntity>>>> getPackagesForAllStudents({
    required List<CourseDm> courses,
    required List<StudentsDm> myStudents,
  });

  /// Get packages for all students in a specific course
  Future<Either<Failures, List<PackagesResponseEntity>>> getPackagesForSpecificCourse({
    required int courseId,
    required List<StudentsDm> myStudents,
  });
}