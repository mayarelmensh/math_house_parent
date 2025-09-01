import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/data/models/login_response_dm.dart';
import 'package:math_house_parent/domain/entities/login_response_entity.dart';
import 'package:math_house_parent/domain/entities/register_response_entity.dart';
import 'package:math_house_parent/domain/repository/auth/auth_repository.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/auth_data_source.dart';

import '../../domain/repository/data_sources/offline_data_source/profile_offline_data_source.dart';
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository{
  AuthDataSource authDataSource;
  final ProfileLocalDataSource profileLocalDataSource;

  AuthRepositoryImpl({required this.authDataSource,required this.profileLocalDataSource});
  @override
  Future<Either<Failures, RegisterResponseEntity>> register(String name, String email,
  String phone, String password, String confPassword) async{
    var either=await authDataSource.register(name, email, phone, password, confPassword);
    return either.fold((error)=>Left(error),
        (response)=>Right(response));
  }

  @override
  Future<Either<Failures, LoginResponseEntity>> login(String email, String password) async {
    var either = await authDataSource.login(email, password);


    return await either.fold(
          (error) async => Left(error),
          (response) async {

        if (response.parent != null) {
          final parentDm = ParentLoginDm(
            id: response.parent!.id,
            name: response.parent!.name,
            email: response.parent!.email,
            phone: response.parent!.phone,
            role: response.parent!.role,
            status: response.parent!.status,
            createdAt: response.parent!.createdAt,
            students: response.parent!.students?.map(
                  (s) => StudentsDm(
                id: s.id,
                nickName: s.nickName,
                imageLink: s.imageLink,
              ),
            ).toList(),
          );
          await profileLocalDataSource.cacheParent(parentDm);
        }
        return Right(response);
      },
    );
  }

}

