import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'confirm_code_password_states.dart';

@injectable
class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  final ApiManager apiManager;

  OtpVerificationCubit({required this.apiManager})
    : super(OtpVerificationInitialState());

  Future<void> verifyCode(int code, String email) async {
    emit(OtpVerificationLoadingState());
    try {
      final response = await apiManager.postData(
        endPoint: EndPoints.confirmPasswordCode,
        queryParameters: {"user": email, "code": code},
      );
      print('OtpVerification Response statusCode: ${response.statusCode}');
      print('OtpVerification Response data: ${response.data}');
      print('OtpVerification Response type: ${response.data.runtimeType}');

      // التحقق من إن response.data مش null أو فاضي
      if (response.data == null ||
          (response.data is String && response.data.isEmpty)) {
        emit(
          OtpVerificationErrorState('No response data received from server'),
        );
        return;
      }

      // تحليل response.data إذا كان String
      final responseData = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      // التحقق من إن responseData هو Map
      if (responseData is! Map<String, dynamic>) {
        emit(OtpVerificationErrorState('Invalid response format from server'));
        return;
      }

      // التحقق من success بدل status
      if (response.statusCode == 200 && responseData['success'] != 'failed') {
        emit(
          OtpVerificationSuccessState(
            responseData['success'] ?? 'Code verified successfully',
          ),
        );
      } else {
        emit(
          OtpVerificationErrorState(
            responseData['message'] ?? 'Invalid verification code',
          ),
        );
      }
    } catch (e) {
      print('Error in verifyCode: $e');
      emit(OtpVerificationErrorState('An error occurred: $e'));
    }
  }
}
