import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/packages_response_entity.dart';
import '../../../domain/repository/packages/packages_repository.dart';
import '../../../domain/repository/data_sources/remote_data_source/packages_data_source.dart';
import '../../../data/models/courses_response_dm.dart';
import '../models/get_students_response_dm.dart';

@Injectable(as: PackagesRepository)
class PackagesRepositoryImpl implements PackagesRepository {
  final PackagesRemoteDataSource packagesRemoteDataSource;

  PackagesRepositoryImpl({required this.packagesRemoteDataSource});

  @override
  Future<Either<Failures, PackagesResponseEntity>> getPackages({required int courseId,required int userId}) async {
    return await packagesRemoteDataSource.getPackages(courseId: courseId,userId: userId);
  }

  @override
  Future<Either<Failures, Map<int, List<PackagesResponseEntity>>>> getPackagesForAllStudents({
    required List<CourseDm> courses,
    required List<StudentsDm> myStudents,
  }) async {
    return await packagesRemoteDataSource.getPackagesForAllStudents(
      courses: courses,
      myStudents: myStudents,
    );
  }

  @override
  Future<Either<Failures, List<PackagesResponseEntity>>> getPackagesForSpecificCourse({
    required int courseId,
    required List<StudentsDm> myStudents,
  }) async {
    return await packagesRemoteDataSource.getPackagesForSpecificCourse(
      courseId: courseId,
      myStudents: myStudents,
    );
  }
}