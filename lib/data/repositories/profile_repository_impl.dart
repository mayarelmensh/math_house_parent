import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/data/models/login_response_dm.dart';
import 'package:math_house_parent/domain/entities/extention_on_login_response.dart';
import 'package:math_house_parent/domain/entities/login_response_entity.dart';
import '../../domain/repository/data_sources/offline_data_source/profile_offline_data_source.dart';
import '../../domain/repository/profile/profile_repository.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failures, ParentLoginEntity>> getCachedParent() async {
    try {
      final parent =await localDataSource.getCachedParent();
      if (parent != null) {
        return Right(parent);
      } else {
        return Left(CacheFailure(errorMsg: 'No cached parent found'));
      }
    } catch (e) {
      return Left(CacheFailure(errorMsg: 'Failed to get cached parent'));
    }
  }

  @override
  Future<Either<Failures, ParentLoginEntity>> cacheParent(ParentLoginEntity parent) async {
    try {
      final parentDm = parent is ParentLoginDm
          ? parent
          : ParentLoginDm.fromEntity(parent);

      await localDataSource.cacheParent(parentDm);
      return Right(parentDm);
    } catch (e) {
      return Left(CacheFailure(errorMsg: 'Failed to cache parent: $e'));
    }
  }

  @override
  Future<Either<Failures, Unit>> clearParentCache() async {
    try {
      await localDataSource.clearCachedParent();
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure(errorMsg: 'Failed to clear cache'));
    }
  }

  @override
  Future<Either<Failures, ParentLoginEntity>> addStudentToCache(StudentsLoginEntity student) async{
    try {
      final parent = await localDataSource.getCachedParent();
      if (parent != null) {
        final updatedStudents = List<StudentsLoginEntity>.from(parent.students!)..add(student);
        final updatedParent = parent.copyWith(students: updatedStudents);

        await localDataSource.cacheParent(updatedParent);
        return Right(updatedParent);
      } else {
        return Left(CacheFailure(errorMsg: "No parent found in cache"));
      }
    } catch (e) {
      return Left(CacheFailure(errorMsg: e.toString()));
    }
  }
}
