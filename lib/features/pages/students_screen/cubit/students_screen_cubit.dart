import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/domain/use_case/send_code_to_student_use_case.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/students_screen_states.dart';
import '../../../../domain/entities/get_students_response_entity.dart';
import '../../../../domain/use_case/get_students_use_case.dart';
@injectable
class GetStudentsCubit extends Cubit<GetStudentsStates> {
  final GetStudentsUseCase getStudentsUseCase;
  final SendCodeUseCase sendCodeUseCase;
  TextEditingController controller = TextEditingController();

  List<StudentsEntity> allStudents = [];
  List<StudentsEntity> myStudents = [];
  int? selectedStudentId;

  GetStudentsCubit(this.getStudentsUseCase,this.sendCodeUseCase) : super(GetStudentsInitialState());

  void getStudents() async {
    emit(GetStudentsLoadingState());
    final result = await getStudentsUseCase.getAllStudents();
    result.fold(
          (failure) => emit(GetStudentsErrorState(error: failure)),
          (students) {
        allStudents = students;
        emit(GetStudentsSuccessState(students: students));
      },
    );
  }

  void searchStudents(String query) {
    if (query.isEmpty) {
      emit(GetStudentsSuccessState(students: allStudents));
    } else {
      final filtered = allStudents.where((s) {
        return (s.nickName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (s.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      emit(GetStudentsSuccessState(students: filtered));
    }
  }

  void getMyStudents() async {
    emit(GetStudentsLoadingState());
    final result = await getStudentsUseCase.getMyStudents();
    result.fold(
          (failure) => emit(GetStudentsErrorState(error: failure)),
          (myStudents) {
        myStudents = myStudents;
        emit(GetMyStudents(myStudents: myStudents));
      },
    );
  }


  void selectStudent(int id) {
    selectedStudentId = id;
    emit(StudentSelected(id));
  }

}





