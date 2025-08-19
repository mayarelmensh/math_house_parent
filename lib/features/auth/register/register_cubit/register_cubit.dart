import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/domain/use_case/register_use_case.dart';
import 'package:math_house_parent/features/auth/register/register_cubit/register_states.dart';
@injectable
class RegisterCubit extends Cubit<RegisterStates>{
  RegisterUseCase registerUseCase;
  RegisterCubit({required this.registerUseCase}):super(RegisterInitialState());

  TextEditingController name =TextEditingController();
  TextEditingController email =TextEditingController();
  TextEditingController phone =TextEditingController();
  TextEditingController password =TextEditingController();
  TextEditingController confPassword =TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool isPasswordVisible=true;

  void register() async {
   if(formKey.currentState?.validate()==true){
     emit(RegisterLoadingState());
     var either= await registerUseCase.invoke(
         name.text,
         email.text,
         phone.text,
         password.text,
         confPassword.text
     );
     return either.fold((error){
       emit(RegisterErrorState(errors: error));
     }, (response){
       emit(RegisterSuccessState(responseEntity: response));
     }
     );
   }
  }
  // void changePasswordVisibility(){
  //   isPasswordVisible =! isPasswordVisible;
  //   emit(ChangePasswordVisibilityState());
  // }

  // Map to hold visibility of multiple password fields
  Map<String, bool> passwordVisibility = {
    "password": false,
    "rePassword": false,
  };

  void changePasswordVisibility(String field) {
    passwordVisibility[field] = !(passwordVisibility[field] ?? false);
    emit(ChangePasswordVisibilityState());
  }
}