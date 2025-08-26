import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/domain/use_case/send_code_to_student_use_case.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/send_code_states.dart';
@injectable
class SendCodeCubit extends Cubit<SendCodeStates>{
  SendCodeUseCase sendCodeUseCase;
  SendCodeCubit({required this.sendCodeUseCase}):super(SendCodeInitialState());

  void sendCode(int studentId) async {
    emit(SendCodeLoadingState());
    final result = await sendCodeUseCase.invoke(studentId);

    result.fold(
          (failure) => emit(SendCodeErrorState(errors: failure)),
          (response) => emit(SendCodeSuccessState(sendCodeResponseEntity: response)),
    );
  }
}