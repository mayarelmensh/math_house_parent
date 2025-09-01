import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/courses_response_entity.dart';

class CoursesStates{}
class CoursesInitialState extends CoursesStates{}
class CoursesLoadingState extends CoursesStates{}
class CoursesErrorState extends CoursesStates{
  Failures error;
  CoursesErrorState({required this.error});
}
class CoursesSuccessState extends CoursesStates{
  CoursesResponseEntity coursesResponseEntity;
  CoursesSuccessState({required this.coursesResponseEntity});
}