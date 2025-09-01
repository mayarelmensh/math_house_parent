import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/get_students_response_entity.dart';
import 'package:math_house_parent/domain/repository/data_sources/remote_data_source/get_students_data_source.dart';
import 'package:math_house_parent/domain/repository/getStudents/get_students_repository.dart';

@Injectable(as:GetStudentsRepository )
class GetStudentsRepositoryImpl implements GetStudentsRepository{
GetStudentsRemoteDataSource getStudentsDataSource;
GetStudentsRepositoryImpl({required this.getStudentsDataSource});
  @override
  Future<Either<Failures, List<StudentsEntity>>> getStudents() async{
   var either =await getStudentsDataSource.getStudents();
   return either.fold((error)=>Left(error),
           (response)=>Right(response));
  }

  @override
  Future<Either<Failures, List<StudentsEntity>>> getMyStudents()async {
var either=await getStudentsDataSource.getMyStudents();
return either.fold((error)=>Left(error),
    (response)=>Right(response));
  }
}