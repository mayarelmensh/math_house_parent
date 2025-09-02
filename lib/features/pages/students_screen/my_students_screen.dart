import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/students_screen_cubit.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/students_screen_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';

import '../../../data/models/student_selected.dart';

class MyStudentsScreen extends StatefulWidget {
  const MyStudentsScreen({Key? key}) : super(key: key);

  @override
  State<MyStudentsScreen> createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends State<MyStudentsScreen> {
  GetStudentsCubit studentsCubit = getIt<GetStudentsCubit>();

  @override
  void initState() {
    super.initState();
    studentsCubit.getMyStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Students"),
      body: Column(
        children: [
          BlocBuilder<GetStudentsCubit, GetStudentsStates>(
            bloc: studentsCubit,
            builder: (context, state) {
              if (state is GetStudentsLoadingState) {
                return Center(
                  heightFactor: 17.333,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              } else if (state is GetStudentsErrorState) {
                return Center(child: Text("Error: ${state.error}"));
              } else if (state is GetMyStudents) {
                if (state.myStudents.isEmpty) {
                  return const Center(child: Text("No students found"));
                }

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.myStudents.length,
                    itemBuilder: (context, index) {
                      final student = state.myStudents[index];
                      final selectedId = context.watch<GetStudentsCubit>().selectedStudentId;
                      final isSelected = student.id == selectedId;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isSelected
                              ? BorderSide(color: AppColors.primaryColor, width: 2)
                              : BorderSide(color: Colors.transparent),
                        ),
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withOpacity(0.5),
                            child: Text(
                              student.nickName?.substring(0, 1).toUpperCase() ?? "?",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            student.nickName ?? "Unknown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                              isSelected ? AppColors.primaryColor : Colors.black,
                            ),
                          ),
                          subtitle: Text(student.email ?? ""),
                          // 👇 خلي الكارد كله قابل للضغط
                          onTap: () {
                            final cubit = context.read<GetStudentsCubit>();
                            cubit.selectStudent(student.id!);
                            debugPrint("✅ Selected Student ID: ${student.id}");
                          },
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: CustomElevatedButton(
              text: 'Go TO Home',
              onPressed: () {
                final selectedId = context.read<GetStudentsCubit>().selectedStudentId;

                if (selectedId != null) {
                  // نخزن الـ studentId في المكان الثابت
                  SelectedStudent.studentId = selectedId;

                  // نروح مباشرة للـ HomeTab
                  Navigator.pushNamed(context, AppRoutes.homeTab);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primaryColor,
                      content: const Text("Please select a student first"),
                    ),
                  );
                }
              },
              backgroundColor: AppColors.primaryColor,
              textStyle: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
