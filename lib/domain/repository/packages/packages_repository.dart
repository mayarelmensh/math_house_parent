import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/get_students_response_dm.dart';
import '../../entities/packages_response_entity.dart';
import '../../../data/models/courses_response_dm.dart';

abstract class PackagesRepository {
  /// جلب باكدجز لكورس معين وطالب معين (كائن واحد)
  Future<Either<Failures, PackagesResponseEntity>> getPackages({
    required int courseId,
    required int userId,
  });

  /// جلب باكدجز لكل الطلاب ولكل الكورسات (خريطة courseId -> قائمة باكدجز)
  Future<Either<Failures, Map<int, List<PackagesResponseEntity>>>> getPackagesForAllStudents({
    required List<CourseDm> courses,
    required List<StudentsDm> myStudents,
  });

  /// جلب باكدجز لطلاب معينين في كورس محدد (قائمة باكدجز)
  Future<Either<Failures, List<PackagesResponseEntity>>> getPackagesForSpecificCourse({
    required int courseId,
    required List<StudentsDm> myStudents,
  });
}