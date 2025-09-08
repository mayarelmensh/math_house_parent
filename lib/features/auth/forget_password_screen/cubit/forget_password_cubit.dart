import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'forget_password_states.dart';

@injectable
class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ApiManager apiManager;

  ForgetPasswordCubit({required this.apiManager})
    : super(ForgetPasswordInitialState());

  Future<void> sendVerificationCode(String userInput) async {
    if (userInput.isEmpty) {
      emit(ForgetPasswordErrorState('Please enter an email or phone number'));
      return;
    }

    emit(ForgetPasswordLoadingState());
    try {
      final response = await apiManager.postData(
        endPoint: EndPoints.forgetPassword,
        queryParameters: {"user": userInput},
      );
      print('ForgetPassword Response statusCode: ${response.statusCode}');
      print('ForgetPassword Response data: ${response.data}');
      print('ForgetPassword Response type: ${response.data.runtimeType}');

      // التحقق من إن response.data مش null أو فاضي
      if (response.data == null ||
          (response.data is String && response.data.isEmpty)) {
        emit(ForgetPasswordErrorState('No response data received from server'));
        return;
      }

      // تحليل response.data إذا كان String
      final responseData = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      // التحقق من إن responseData هو Map
      if (responseData is! Map<String, dynamic>) {
        emit(ForgetPasswordErrorState('Invalid response format from server'));
        return;
      }

      // التحقق من success بدل status
      if (response.statusCode == 200 && responseData['success'] != 'failed') {
        emit(
          ForgetPasswordSuccessState(
            responseData['success'] ?? 'Verification code sent successfully',
          ),
        );
      } else {
        emit(
          ForgetPasswordErrorState(
            responseData['message'] ?? 'Failed to send verification code',
          ),
        );
      }
    } catch (e) {
      print('Error in sendVerificationCode: $e');
      emit(ForgetPasswordErrorState('An error occurred: $e'));
    }
  }
}
