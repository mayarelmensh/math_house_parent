import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/send_code_response_entity.dart';

abstract class SendCodeDataSource{
  Future<Either<Failures,SendCodeResponseEntity>> sendCode(int id);
}