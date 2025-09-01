import 'package:dartz/dartz.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/courses_response_entity.dart';

abstract class CoursesListRepository{
  Future<Either<Failures,CoursesResponseEntity>>getCoursesList();
}