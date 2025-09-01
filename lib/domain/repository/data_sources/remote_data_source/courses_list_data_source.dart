import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../entities/courses_response_entity.dart';

abstract class CoursesListDataSource{
  Future<Either<Failures,CoursesResponseEntity>>getCoursesList();
}