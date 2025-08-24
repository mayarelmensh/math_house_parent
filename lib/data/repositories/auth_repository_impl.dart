import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/data/data_sources/online_data_source/auth_remote_data_source_impl.dart';
import 'package:math_house_parent/domain/entities/login_response_entity.dart';
import 'package:math_house_parent/domain/entities/register_response_entity.dart';
import 'package:math_house_parent/domain/repository/auth/auth_repository.dart';
import 'package:math_house_parent/domain/repository/data_sources/auth_data_source.dart';
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository{
  AuthDataSource authDataSource;
  AuthRepositoryImpl({required this.authDataSource});
  @override
  Future<Either<Failures, RegisterResponseEntity>> register(String name, String email,
  String phone, String password, String confPassword) async{
    var either=await authDataSource.register(name, email, phone, password, confPassword);
    return either.fold((error)=>Left(error),
        (response)=>Right(response));
  }

  @override
  Future<Either<Failures, LoginResponseEntity>> login(String email, String password)async {
    var either=await authDataSource.login(email, password);
      return either.fold((error)=>Left(error),
              (response)=>Right(response));
     }
  }

