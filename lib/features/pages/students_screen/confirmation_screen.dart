import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/core/utils/flutter_toast.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/confirm_code_cubit.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/confirm_code_states.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final ConfirmCodeCubit confirmCodeCubit = getIt<ConfirmCodeCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Confirmation Code"),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Text(
              "The confirmation Code was sent to mayar@gmail.com",
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 150),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: confirmCodeCubit.controllers[index],
                    focusNode: confirmCodeCubit.focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context)
                            .requestFocus(confirmCodeCubit.focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(confirmCodeCubit.focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            BlocConsumer<ConfirmCodeCubit, ConfirmCodeStates>(
              bloc: confirmCodeCubit,
              listener: (context, state) {
                if (state is ConfirmCodeSuccessState) {
                  ToastMessage.toastMessage(
                    "The code is correct!",
                    AppColors.green,
                    AppColors.white,
                  );
                  Navigator.pop(context);
                } else if (state is ConfirmCodeErrorState) {
                  ToastMessage.toastMessage(
                    state.errors.errorMsg ?? "The code is wrong",
                    AppColors.red,
                    AppColors.white,
                  );
                }
              },
              builder: (context, state) {
                if (state is ConfirmCodeLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final codeString = confirmCodeCubit.getOtpCode();
                      if (codeString.length < 6) {
                        ToastMessage.toastMessage(
                          "Please enter all 6 digits",
                          AppColors.red,
                          AppColors.white,
                        );
                        return;
                      }
                      final code = int.tryParse(codeString) ?? 0;
                      confirmCodeCubit.confirmCode(code);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
