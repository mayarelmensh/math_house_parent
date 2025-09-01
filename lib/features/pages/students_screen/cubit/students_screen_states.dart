import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/get_students_response_entity.dart';

abstract class GetStudentsStates{}
class GetStudentsInitialState extends GetStudentsStates{}
class GetStudentsLoadingState extends GetStudentsStates{}
class GetStudentsErrorState extends GetStudentsStates{
 final Failures error;
  GetStudentsErrorState({required this.error });
}
class GetStudentsSuccessState extends GetStudentsStates{
 final List<StudentsEntity> students;
  GetStudentsSuccessState ({required this.students});
}
class GetMyStudents extends GetStudentsStates{
 final List<StudentsEntity> myStudents;
 GetMyStudents ({required this.myStudents});
}
class StudentSelected extends GetStudentsStates {
 final int selectedStudentId;
 StudentSelected(this.selectedStudentId);
}