import 'package:dartz/dartz.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/confirm_code_response_entity.dart';

abstract class ConfirmCodeRepository{
  Future<Either<Failures,ConfirmCodeResponseEntity>> confirmCode(int code);
}