import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/domain/use_case/login_use_case.dart';
import '../../../../core/cashe/shared_preferences_utils.dart';
import 'login_states.dart';
@injectable
class LoginCubit extends Cubit<LoginStates>{
  LoginUseCase loginUseCase;
  LoginCubit({required this.loginUseCase}):super(LoginInitialState());
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  var formKey=GlobalKey<FormState>();
  bool isPasswordObscure =false;
  bool isLoading= false;

 void login()async{
   if(formKey.currentState?.validate()==true) {
     emit(LoginInitialState());
     var either = await loginUseCase.invoke(email.text, password.text);
     return either.fold((error) {
      emit(LoginErrorState(errors: error));
     },  (response)  async {
       await SharedPreferenceUtils.saveData(
         key: 'token',
         value: response.token,
       );
       emit(LoginSuccessState(loginResponseEntity: response));
     });
 }
  }


  void changePasswordVisibility() {
    isPasswordObscure !=isPasswordObscure;
   emit( ChangePasswordVisibilityState());
  }

  void setLoading(bool loading) {
    isLoading = loading;

  }
}