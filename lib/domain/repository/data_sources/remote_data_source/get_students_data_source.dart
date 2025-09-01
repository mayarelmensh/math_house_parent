import 'package:dartz/dartz.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import '../../../entities/get_students_response_entity.dart';

abstract class GetStudentsRemoteDataSource {
  Future<Either<Failures,List<StudentsEntity>>> getStudents();
  Future<Either<Failures,List<StudentsEntity>>> getMyStudents();
}

