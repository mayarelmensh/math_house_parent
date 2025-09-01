import 'package:dartz/dartz.dart';
import 'package:math_house_parent/domain/entities/login_response_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../../entities/register_response_entity.dart';

abstract class AuthDataSource{
  Future<Either<Failures,RegisterResponseEntity>> register(String name , String email,
      String phone , String password, String confPassword);

  Future<Either<Failures,LoginResponseEntity>>login(String email, String password);
}