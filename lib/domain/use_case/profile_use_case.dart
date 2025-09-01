import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/login_response_entity.dart';
import '../repository/profile/profile_repository.dart';
@injectable
class ProfileUseCase {
  final ProfileRepository repository;

  ProfileUseCase({required this.repository});

  Future<Either<Failures, ParentLoginEntity>> getCached() {
    return repository.getCachedParent();
  }


  Future<Either<Failures, ParentLoginEntity>> cache(ParentLoginEntity parent) async {
    return await repository.cacheParent(parent);
  }


  // Future<Either<Failures, Unit>> clear() async {
  //   return await repository.clearParentCache();
  // }
  // Future<Either<Failures, ParentLoginEntity>> updateStudents(StudentsLoginEntity newStudent) {
  //   return repository.addStudentToCache(newStudent);
  // }
}
