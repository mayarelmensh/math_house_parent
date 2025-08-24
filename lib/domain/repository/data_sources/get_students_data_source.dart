import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/get_students_response_entity.dart';

abstract class GetStudentsDataSource{
  Future<Either<Failures,List<StudentsEntity>>>getStudents();
  }
