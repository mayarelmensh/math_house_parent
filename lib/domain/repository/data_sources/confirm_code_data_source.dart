import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/confirm_code_response_entity.dart';

abstract class ConfirmCodeDataSource{
  Future<Either<Failures,ConfirmCodeResponseEntity>> confirmCode(int code);

}