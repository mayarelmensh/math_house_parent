import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/features/auth/register/register_cubit/register_cubit.dart';
import 'package:math_house_parent/features/auth/register/register_cubit/register_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
import 'package:math_house_parent/features/widgets/custom_text_form_field.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
   RegisterCubit registerCubit = getIt<RegisterCubit>();


  @override
  void dispose() {
    registerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterStates>(
      bloc: registerCubit,
      listener: (context, state) {
        if (state is RegisterLoadingState) {
          DialogUtils.showLoading(context: context,  msg: 'Loading...');
        } else if (state is RegisterErrorState) {
          DialogUtils.hideLoading(context: context);
          DialogUtils.showMsg(
            context: context,
            msg: state.errors.errorMsg,
            title: 'Error',
            posActionName: 'Ok',
          );
        } else if (state is RegisterSuccessState) {
          DialogUtils.hideLoading(context: context);
          DialogUtils.showMsg(
            context: context,
            msg: 'Register successfully.',
            title: 'Success',
            posActionName: 'Ok',
            posAction: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.loginRoute);
            },
          );
        }
      },
      builder:(context,state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Logo Section
                Padding(
                  padding: EdgeInsets.only(
                    top: 91.h,
                    bottom: 10.h,
                    left: 97.w,
                    right: 97.w,
                  ),
                  child: Center(
                    child: Text(
                      'Math House',
                      style: TextStyle(
                        fontSize: 20.sp,
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
                          key: registerCubit.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Full Name Field
                              Text(
                                "Full Name",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextFormField(
                                borderColor: AppColors.darkGrey,
                                controller: registerCubit.name,
                                hintText: "Enter your full name",
                                keyboardType: TextInputType.name,
                                validator: AppValidators.validateFullName,
                                filledColor: AppColors.white,
                              ),
                              SizedBox(height: 20.h),

                              // Mobile Number Field
                              Text(
                                "Mobile Number",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextFormField(
                                borderColor: AppColors.darkGrey,
                                controller: registerCubit.phone,
                                hintText: "Enter your mobile number",
                                keyboardType: TextInputType.phone,
                                validator: AppValidators.validatePhoneNumber,
                                filledColor: AppColors.white,
                              ),
                              SizedBox(height: 20.h),

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
                                controller: registerCubit.email,
                                hintText: "Enter your email address",
                                keyboardType: TextInputType.emailAddress,
                                validator: AppValidators.validateEmail,
                                filledColor: AppColors.white,
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
                                controller: registerCubit.password,
                                hintText: "Enter your password",
                                isObscureText: !(registerCubit.passwordVisibility["password"] ?? false),
                                validator: AppValidators.validatePassword,
                                filledColor: AppColors.white,
                                keyboardType: TextInputType.visiblePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    registerCubit.changePasswordVisibility("password");
                                  },
                                  icon: Icon(
                                    registerCubit.passwordVisibility["password"]==true
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Re-Password Field
                              Text(
                                "Re-Password",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextFormField(
                                borderColor: AppColors.darkGrey,
                                controller: registerCubit.confPassword,
                                hintText: "Enter your re-password",
                                isObscureText:  !(registerCubit.passwordVisibility["rePassword"] ?? false),
                                validator: (value) =>
                                    AppValidators.validateConfirmPassword(
                                      value,
                                      registerCubit.password.text,
                                    ),
                                filledColor: AppColors.white,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    registerCubit.changePasswordVisibility("rePassword");
                                  },
                                  icon: Icon(
                                    registerCubit.passwordVisibility["rePassword"]==true
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ),
                              SizedBox(height: 35.h),
                              // Sign Up Button
                              CustomElevatedButton(
                                text: "Sign up",
                                onPressed: () {
                                  registerCubit.register();
                                },
                                backgroundColor: AppColors.primaryColor,
                                textStyle: TextStyle(color: AppColors.white),
                              ),

                              // Login Link
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 30.h, bottom: 30.h),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.loginRoute,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          'Already have an account? Login',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.white,
                                            decoration: TextDecoration
                                                .underline,
                                            decorationColor: AppColors.white,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
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
      }
    );
  }
}