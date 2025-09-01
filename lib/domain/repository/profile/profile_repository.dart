import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/login_response_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failures, ParentLoginEntity>> getCachedParent();
  Future<Either<Failures, ParentLoginEntity>> cacheParent(ParentLoginEntity parent);
  // Future<Either<Failures, Unit>> clearParentCache();
  // Future<Either<Failures, ParentLoginEntity>> addStudentToCache(StudentsLoginEntity student);

}