import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/features/auth/login/login_cubit/login_cubit.dart';
import 'package:math_house_parent/features/auth/login/login_cubit/login_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
import 'package:math_house_parent/features/widgets/custom_text_form_field.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/dialog_utils.dart';
import 'package:math_house_parent/core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginCubit loginCubit = getIt<LoginCubit>();

  @override
  void dispose() {
    loginCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginStates>(
      bloc: loginCubit,
      listener: (context, state) {
        if (state is LoginLoadingState) {
          DialogUtils.showLoading(context: context, message: 'Loading...');
        } else if (state is LoginErrorState) {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(
            context: context,
            message: 'Email or password is invalid',
            title: 'Error',
            posActionName: 'Ok',
            posAction: () {
              // No need to hide loading again here
            },
          );
        } else if (state is LoginSuccessState) {
          DialogUtils.hideLoading(context);
          DialogUtils.showMessage(
            context: context,
            message: 'Login successfully.',
            title: 'Success',
            posActionName: 'Ok',
            posAction: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.myStudentScreen);
            },
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Logo Section
                Padding(
                  padding: EdgeInsets.only(
                    top: 120.h,
                    bottom: 10.h,
                    left: 97.w,
                    right: 97.w,
                  ),
                  child: Center(
                    child: Text(
                      'Math House',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                // Form Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: Form(
                          key: loginCubit.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Field
                              Text(
                                "E-mail address",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextFormField(
                                borderColor: AppColors.darkGrey,
                                controller: loginCubit.email,
                                hintText: "Enter your email address",
                                keyboardType: TextInputType.emailAddress,
                                validator: AppValidators.validateEmail,
                                filledColor: AppColors.white,
                                textStyle: TextStyle(fontSize: 16.sp),
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grey[500],
                                ),
                                // borderRadius: BorderRadius.circular(8.r),
                                // contentPadding: EdgeInsets.symmetric(
                                //   horizontal: 16.w,
                                //   vertical: 12.h,
                                // ),
                              ),
                              SizedBox(height: 20.h),
                              // Password Field
                              Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextFormField(
                                borderColor: AppColors.darkGrey,
                                controller: loginCubit.password,
                                hintText: "Enter your password",
                                isObscureText: loginCubit.isPasswordObscure,
                                validator: AppValidators.validatePassword,
                                filledColor: AppColors.white,
                                keyboardType: TextInputType.visiblePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    loginCubit.changePasswordVisibility();
                                  },
                                  icon: Icon(
                                    loginCubit.isPasswordObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.darkGrey,
                                    size: 20.sp,
                                  ),
                                ),
                                textStyle: TextStyle(fontSize: 16.sp),
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grey[500],
                                ),
                                // borderRadius: BorderRadius.circular(8.r),
                                // contentPadding: EdgeInsets.symmetric(
                                //   horizontal: 16.w,
                                //   vertical: 12.h,
                                // ),
                              ),
                              SizedBox(height: 10.h),
                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.forgetPasswordRoute,
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.primaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 35.h),
                              // Login Button
                              CustomElevatedButton(
                                text: state is LoginLoadingState ? 'login......' : 'Login',
                                onPressed: () {
                                  loginCubit.login();
                                },
                                backgroundColor: AppColors.primaryColor,
                                textStyle: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                // padding: EdgeInsets.symmetric(
                                //   horizontal: 32.w,
                                //   vertical: 12.h,
                                // ),
                                // borderRadius: BorderRadius.circular(8.r),
                              ),
                              // Register Link
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.registerRoute,
                                        );
                                      },
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryColor,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}