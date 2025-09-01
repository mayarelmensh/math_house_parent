import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/domain/use_case/courses_list_use_case.dart';
import 'courses_states.dart';
@injectable
class CoursesCubit extends Cubit<CoursesStates>{
  CoursesListUseCase coursesListUseCase;
  CoursesCubit({required this.coursesListUseCase}):super(CoursesInitialState());

  void getCoursesList() async {
    emit(CoursesLoadingState());
   final result=await coursesListUseCase.invoke();
    result.fold((error)=>emit(CoursesErrorState(error: error)),
        (response)=>emit(CoursesSuccessState(coursesResponseEntity: response)));
  }
}