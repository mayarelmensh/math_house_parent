import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/register_response_entity.dart';
import 'package:math_house_parent/domain/repository/auth/auth_repository.dart';
@injectable
class RegisterUseCase{
AuthRepository authRepository;
RegisterUseCase({required this.authRepository});
Future<Either<Failures,RegisterResponseEntity>> invoke(String name , String email,
   String phone , String password, String confPassword){
  return authRepository.register( name ,email,phone , password , confPassword );
 }
}