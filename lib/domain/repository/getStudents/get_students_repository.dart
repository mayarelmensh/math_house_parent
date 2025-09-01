import 'package:dartz/dartz.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/get_students_response_entity.dart';

abstract class GetStudentsRepository {
  Future<Either<Failures, List<StudentsEntity>>> getStudents();
  Future<Either<Failures, List<StudentsEntity>>> getMyStudents();
}
