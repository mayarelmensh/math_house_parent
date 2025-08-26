import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/repository/getStudents/confirm_code_repository.dart';
import '../entities/confirm_code_response_entity.dart';
@injectable
class ConfirmCodeUseCase {
  ConfirmCodeRepository confirmCodeRepository;
  ConfirmCodeUseCase({required this.confirmCodeRepository});

 Future<Either<Failures,ConfirmCodeResponseEntity>> invoke(int code){
    return confirmCodeRepository.confirmCode(code);
  }
}