import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../data/models/courses_response_dm.dart';
import '../../data/models/get_students_response_dm.dart';
import '../entities/packages_response_entity.dart';
import '../repository/packages/packages_repository.dart';
@injectable
class PackagesUseCase {
  final PackagesRepository packagesRepository;

  PackagesUseCase({required this.packagesRepository});

  /// جلب باكدجز لكورس معين وطالب معين (كائن واحد)
  Future<Either<Failures, PackagesResponseEntity>> getPackagesByCourseId({
    required int courseId,
    required int userId,
  }) {
    return packagesRepository.getPackages(courseId: courseId, userId: userId);
  }

  /// جلب باكدجز لكل الطلاب ولكل الكورسات (خريطة courseId -> قائمة باكدجز)
  Future<Either<Failures, Map<int, List<PackagesResponseEntity>>>> getPackagesForAllStudents({
    required List<CourseDm> courses,
    required List<StudentsDm> myStudents,
  }) {
    return packagesRepository.getPackagesForAllStudents(
      courses: courses,
      myStudents: myStudents,
    );
  }

  /// جلب باكدجز لطلاب معينين في كورس محدد (قائمة باكدجز)
  Future<Either<Failures, List<PackagesResponseEntity>>> getPackagesForSpecificCourse({
    required int courseId,
    required List<StudentsDm> myStudents,
  }) {
    return packagesRepository.getPackagesForSpecificCourse(
      courseId: courseId,
      myStudents: myStudents,
    );
  }
}