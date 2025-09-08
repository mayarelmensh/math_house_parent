import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/flutter_toast.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'confirm_code_forget_password_screen.dart';
import 'cubit/forget_password_cubit.dart';
import 'cubit/forget_password_states.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ForgetPasswordScreenState createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _userInputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ForgetPasswordCubit forgetPasswordCubit = getIt<ForgetPasswordCubit>();

  @override
  void dispose() {
    _userInputController.dispose();
    super.dispose();
  }

  String? _validateUserInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^\d{10,11}$');
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return 'Please enter a valid email or phone number';
    }
    return null;
  }

  void _handleSendResetCode(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final userInput = _userInputController.text.trim();
    await forgetPasswordCubit.sendVerificationCode(userInput);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => forgetPasswordCubit,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: 'Forgot Password'),
        body: Padding(
          padding: EdgeInsets.all(20.w),
          child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
            bloc: forgetPasswordCubit,
            listener: (context, state) {
              if (state is ForgetPasswordSuccessState) {
                ToastMessage.toastMessage(
                  state.message,
                  AppColors.green,
                  AppColors.white,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const OtpVerificationScreen(),
                    settings: RouteSettings(
                      arguments: _userInputController.text.trim(),
                    ),
                  ),
                );
              } else if (state is ForgetPasswordErrorState) {
                print(state.errorMessage);
                ToastMessage.toastMessage(
                  state.errorMessage,
                  AppColors.red,
                  AppColors.white,
                );
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'Enter your email address or phone number to receive a verification code.',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    TextFormField(
                      controller: _userInputController,
                      validator: _validateUserInput,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                        labelText: 'Email or Phone Number',
                        hintText: 'Enter your email or phone number',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: AppColors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 15.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    if (state is ForgetPasswordErrorState)
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
                    if (state is ForgetPasswordSuccessState)
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
                        onPressed: state is ForgetPasswordLoadingState
                            ? null
                            : () => _handleSendResetCode(context),
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
                        child: state is ForgetPasswordLoadingState
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child:  CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Send Verification Code',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
