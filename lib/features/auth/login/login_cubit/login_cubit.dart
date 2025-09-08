import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/domain/use_case/login_use_case.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
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

     emit(LoginInitialState());
     var either = await loginUseCase.invoke(email.text, password.text);
     return either.fold((error) {
      emit(LoginErrorState(errors: error));
     },  (response)  async {
       await SharedPreferenceUtils.saveData(
         key: 'token',
         value: response.token,
       );
       // await SharedPreferenceUtils.saveData(
       //   key: 'user',
       //   value: jsonEncode(response.parent), // parent toJson()
       // );
       //
       // await SharedPreferenceUtils.saveData(
       //   key: 'students',
       //   value: jsonEncode(response.parent?.students?.map((s) => {
       //     'id': s.id,
       //     'nick_name': s.nickName,
       //     'image_link': s.imageLink,
       //     'parent_id': s.pivot?.parentId,
       //     'user_id': s.pivot?.userId,
       //   }).toList()),
       // );

       emit(LoginSuccessState(loginResponseEntity: response));
     });
 }



  void changePasswordVisibility() {
    isPasswordObscure =! isPasswordObscure;
   emit( ChangePasswordVisibilityState());
  }

  Future<void> logout() async {
    await SharedPreferenceUtils.removeData(key: 'cached_parent');
    await SharedPreferenceUtils.removeData(key: 'token');
    emit(LoginInitialState());
  }

  // void setLoading(bool loading) {
  //   isLoading = loading;
  //
  // }
}