import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'reset_password_states.dart';

@injectable
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ApiManager apiManager;

  ResetPasswordCubit({required this.apiManager})
    : super(ResetPasswordInitialState());

  Future<void> resetPassword(String email, String password, int code) async {
    emit(ResetPasswordLoadingState());
    try {
      final response = await apiManager.postData(
        endPoint: EndPoints.resetPassword,
        queryParameters: {"user": email, "code": code, "password": password},
      );
      print('ResetPassword Response statusCode: ${response.statusCode}');
      print('ResetPassword Response data: ${response.data}');
      print('ResetPassword Response type: ${response.data.runtimeType}');

      // التحقق من إن response.data مش null أو فاضي
      if (response.data == null ||
          (response.data is String && response.data.isEmpty)) {
        emit(ResetPasswordErrorState('No response data received from server'));
        return;
      }

      // تحليل response.data إذا كان String
      final responseData = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      // التحقق من إن responseData هو Map
      if (responseData is! Map<String, dynamic>) {
        emit(ResetPasswordErrorState('Invalid response format from server'));
        return;
      }

      // التحقق من success بدل status
      if (response.statusCode == 200 && responseData['success'] != 'failed') {
        emit(
          ResetPasswordSuccessState(
            responseData['success'] ?? 'Password reset successfully',
          ),
        );
      } else {
        emit(
          ResetPasswordErrorState(
            responseData['message'] ?? 'Failed to reset password',
          ),
        );
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      emit(ResetPasswordErrorState('An error occurred: $e'));
    }
  }
}
