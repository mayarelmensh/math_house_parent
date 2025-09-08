import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/utils/flutter_toast.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'cubit/reset_password_cubit.dart';
import 'cubit/reset_password_states.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ResetPasswordCubit cubit = getIt<ResetPasswordCubit>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String userInput = arguments['userInput'] as String;
    final int code = arguments['code'] as int;

    return BlocProvider(
      create: (context) => cubit,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: "Reset Password"),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                      bloc: cubit,
                      listener: (context, state) {
                        if (state is ResetPasswordSuccessState) {
                          ToastMessage.toastMessage(
                            state.message,
                            AppColors.green,
                            AppColors.white,
                          );
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil(AppRoutes.loginRoute,(Route<dynamic> route) => false,);
                        } else if (state is ResetPasswordErrorState) {
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
                              Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Enter your new password below.',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              TextFormField(
                                controller: _passwordController,
                                validator: _validatePassword,
                                obscureText: _isPasswordObscure,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: AppColors.primaryColor),
                                  labelText: 'New Password',
                                  hintText: 'Enter your new password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordObscure =
                                            !_isPasswordObscure;
                                      });
                                    },
                                    icon: Icon(
                                      _isPasswordObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grey.shade700,
                                      size: 22.sp,
                                    ),
                                  ),
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
                                    borderSide: BorderSide(
                                      color: AppColors.red,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.h,
                                    horizontal: 15.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              TextFormField(
                                controller: _confirmPasswordController,
                                validator: _validateConfirmPassword,
                                obscureText: _isConfirmPasswordObscure,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: AppColors.primaryColor),
                                  labelText: 'Confirm Password',
                                  hintText: 'Confirm your new password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordObscure =
                                            !_isConfirmPasswordObscure;
                                      });
                                    },
                                    icon: Icon(
                                      _isConfirmPasswordObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grey.shade700,
                                      size: 22.sp,
                                    ),
                                  ),
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
                                    borderSide: BorderSide(
                                      color: AppColors.red,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.h,
                                    horizontal: 15.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              if (state is ResetPasswordErrorState)
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  margin: EdgeInsets.only(bottom: 20.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.red.shade50,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: AppColors.red.shade200,
                                    ),
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
                              if (state is ResetPasswordSuccessState)
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  margin: EdgeInsets.only(bottom: 20.h),
                                  // decoration: BoxDecoration(
                                  // color: AppColors.green,
                                  // borderRadius: BorderRadius.circular(8.r),
                                  // border: Border.all(color: AppColors.green.shade200),
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
                                  onPressed: state is ResetPasswordLoadingState
                                      ? null
                                      : () {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }
                                          context
                                              .read<ResetPasswordCubit>()
                                              .resetPassword(
                                                userInput,
                                                _passwordController.text,
                                                code,
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    disabledBackgroundColor: AppColors
                                        .primaryColor
                                        .withOpacity(0.6),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: state is ResetPasswordLoadingState
                                      ? SizedBox(
                                          height: 20.h,
                                          width: 20.h,
                                          child:
                                              const CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Text(
                                          'Reset Password',
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
