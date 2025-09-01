import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/send_code_response_entity.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/send_code_data_source.dart';
import 'package:math_house_parent/domain/repository/getStudents/send_code_to_student_repository.dart';
@Injectable(as:SendCodeToStudentRepository )
class SendCodeRepositoryImpl implements SendCodeToStudentRepository{
  SendCodeDataSource sendCodeDataSource;
  SendCodeRepositoryImpl({required this.sendCodeDataSource});
  @override
  Future<Either<Failures, SendCodeResponseEntity>> sendCode(int id)async  {
   var either= await sendCodeDataSource.sendCode(id);
   return either.fold((error)=>Left(error), (response)=>Right(response));
  }
}