import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/flutter_toast.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/features/auth/forget_password_screen/reset_password_screen.dart';

import 'cubit/confirm_code_password_cubit.dart';
import 'cubit/confirm_code_password_states.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpVerificationCubit cubit = getIt<OtpVerificationCubit>();
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String getOtpCode() {
    return controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final String userInput =
        ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (context) => cubit,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: "Verification Code"),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(20.w),
              child: BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
                bloc: cubit,
                listener: (context, state) {
                  if (state is OtpVerificationSuccessState) {
                    ToastMessage.toastMessage(
                      state.message,
                      AppColors.green,
                      AppColors.white,
                    );
                    final codeString = getOtpCode();
                    final code = int.tryParse(codeString) ?? 0;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const ResetPasswordScreen(),
                        settings: RouteSettings(
                          arguments: {'userInput': userInput, 'code': code},
                        ),
                      ),
                    );
                  } else if (state is OtpVerificationErrorState) {
                    ToastMessage.toastMessage(
                      state.errorMessage,
                      AppColors.red,
                      AppColors.white,
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Enter Verification Code',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'A 6-digit code was sent to $userInput',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50.w,
                            height: 60.h,
                            child: TextFormField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGrey,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: AppColors.red),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.length == 1 && index < 5) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(focusNodes[index + 1]);
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(focusNodes[index - 1]);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 20.h),
                      if (state is OtpVerificationErrorState)
                        Container(
                          padding: EdgeInsets.all(12.w),
                          margin: EdgeInsets.only(bottom: 20.h),
                          decoration: BoxDecoration(
                            color: AppColors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.red.shade700,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  state.errorMessage,
                                  style: TextStyle(
                                    color: AppColors.red.shade700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (state is OtpVerificationSuccessState)
                        Container(
                          padding: EdgeInsets.all(12.w),
                          margin: EdgeInsets.only(bottom: 20.h),
                          // decoration: BoxDecoration(
                          //   color: AppColors.green,
                          //   borderRadius: BorderRadius.circular(8.r),
                          //   border: Border.all(color: AppColors.green),
                          // ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColors.green,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  state.message,
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 30.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is OtpVerificationLoadingState
                              ? null
                              : () {
                                  final codeString = getOtpCode();
                                  if (codeString.length < 6) {
                                    ToastMessage.toastMessage(
                                      "Please enter all 6 digits",
                                      AppColors.red,
                                      AppColors.white,
                                    );
                                    return;
                                  }
                                  final code = int.tryParse(codeString) ?? 0;
                                  cubit.verifyCode(code, userInput);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            disabledBackgroundColor: AppColors.primaryColor
                                .withOpacity(0.6),
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: state is OtpVerificationLoadingState
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Back to Login',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
