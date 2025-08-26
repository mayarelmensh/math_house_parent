import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/repository/data_sources/confirm_code_data_source.dart';
import 'package:math_house_parent/domain/repository/getStudents/confirm_code_repository.dart';
import '../../domain/entities/confirm_code_response_entity.dart';
@Injectable(as :ConfirmCodeRepository)
class ConfirmCodeRepositoryImpl implements ConfirmCodeRepository{
  ConfirmCodeDataSource confirmCodeDataSource;
  ConfirmCodeRepositoryImpl({required this.confirmCodeDataSource});
  @override
  Future<Either<Failures, ConfirmCodeResponseEntity>> confirmCode(int code) async{
   var either =await confirmCodeDataSource.confirmCode(code);
   return either.fold((error)=>Left(error), (response)=>(Right(response)));
  }

}