import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/domain/use_case/confirm_code_use_case.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/confirm_code_states.dart';

class ConfirmCodeCubit extends Cubit<ConfirmCodeStates>{
  ConfirmCodeUseCase confirmCodeUseCase;
  ConfirmCodeCubit({required this.confirmCodeUseCase}):super(ConfirmCodeInitialState());

  void confirmCode(int code) async{
    emit(ConfirmCodeLoadingState());
    final result =await confirmCodeUseCase.invoke(code);
    result.fold((error)=>emit(ConfirmCodeErrorState(errors: error)),
            (response)=>emit(ConfirmCodeSuccessState(confirmCodeEntity: response)));
  }
}