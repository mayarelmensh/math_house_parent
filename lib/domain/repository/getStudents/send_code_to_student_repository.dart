import 'package:dartz/dartz.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/send_code_response_entity.dart';

abstract class SendCodeToStudentRepository{
 Future<Either<Failures,SendCodeResponseEntity>> sendCode(int id);
}
