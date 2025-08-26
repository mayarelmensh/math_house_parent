import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/core/widgets/custom_search_filter_bar.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/send_code_cubit.dart';
import '../../../core/utils/flutter_toast.dart';
import 'cubit/send_code_states.dart';
import 'cubit/students_screen_cubit.dart';
import 'cubit/students_screen_states.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final GetStudentsCubit cubit = getIt<GetStudentsCubit>();
  final SendCodeCubit sendCodeCubit = getIt<SendCodeCubit>();

  @override
  void initState() {
    super.initState();
    cubit.getStudents();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Son'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchFilterBar(
              showFilter: false,
              onSearchChanged: (value) {
                cubit.searchStudents(value);
              },
              hintText: "Enter email or name",
            ),
          ),
          Expanded(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<GetStudentsCubit>.value(value: cubit),
                BlocProvider<SendCodeCubit>.value(value: sendCodeCubit),
              ],
              child: BlocListener<SendCodeCubit, SendCodeStates>(
                listener: (context, state) {
                  if (state is SendCodeSuccessState) {
                    ToastMessage.toastMessage(
                      "The code has been sent successfully",
                      AppColors.green,
                      AppColors.white,
                    );
                    Navigator.pushNamed(
                        context, AppRoutes.confirmationScreen);
                  } else if (state is SendCodeErrorState) {
                    ToastMessage.toastMessage(
                      "Failed to send code",
                      AppColors.primaryColor,
                      AppColors.white,
                    );
                  }
                },
                child: BlocBuilder<GetStudentsCubit, GetStudentsStates>(
                  builder: (context, state) {
                    if (state is GetStudentsLoadingState) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    } else if (state is GetStudentsSuccessState) {
                      final students = state.students;
                      if (students.isEmpty) {
                        return const Center(child: Text("No students found"));
                      }
                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(student.nickName ?? "No Name"),
                              subtitle: Text(student.email ?? "No Email"),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  sendCodeCubit.sendCode(student.id!);
                                },
                                child: Text(
                                  "Send Code",
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is GetStudentsErrorState) {
                      return Center(
                          child: Text("Error: ${state.error.errorMsg}"));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
