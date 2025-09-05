import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/students_screen_cubit.dart';
import 'package:math_house_parent/features/pages/students_screen/cubit/students_screen_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
import 'package:math_house_parent/data/models/student_selected.dart';

class MyStudentsScreen extends StatefulWidget {
  const MyStudentsScreen({super.key});

  @override
  State<MyStudentsScreen> createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends State<MyStudentsScreen> {
  final GetStudentsCubit studentsCubit = getIt<GetStudentsCubit>();

  @override
  void initState() {
    super.initState();
    studentsCubit.getMyStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "My Students",

      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<GetStudentsCubit, GetStudentsStates>(
              bloc: studentsCubit,
              builder: (context, state) {
                if (state is GetStudentsLoadingState) {
                  return Center(
                    heightFactor: 17.333,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 3.w, // Responsive stroke width
                    ),
                  );
                } else if (state is GetStudentsErrorState) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r), // Responsive padding
                      child: Text(
                        "Error: ${state.error}",
                        style: TextStyle(
                          fontSize: 16.sp, // Responsive font size
                          color: AppColors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (state is GetMyStudents) {
                  if (state.myStudents.isEmpty) {
                    return Center(
                      child: Text(
                        "No students found",
                        style: TextStyle(
                          fontSize: 18.sp, // Responsive font size
                          color: AppColors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.r), // Responsive padding
                    itemCount: state.myStudents.length,
                    itemBuilder: (context, index) {
                      final student = state.myStudents[index];
                      final selectedId = context.watch<GetStudentsCubit>().selectedStudentId;
                      final isSelected = student.id == selectedId;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r), // Responsive radius
                          side: isSelected
                              ? BorderSide(color: AppColors.primaryColor, width: 2.w)
                              : BorderSide(color: Colors.transparent),
                        ),
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.white,
                        margin: EdgeInsets.only(bottom: 12.h), // Responsive margin
                        elevation: 3,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ), // Responsive padding
                          leading: CircleAvatar(
                            radius: 24.r, // Responsive radius
                            backgroundColor: isSelected
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withOpacity(0.5),
                            child: Text(
                              student.nickName?.substring(0, 1).toUpperCase() ?? "?",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18.sp, // Responsive font size
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            student.nickName ?? "Unknown",
                            style: TextStyle(
                              fontSize: 18.sp, // Responsive font size
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primaryColor : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            student.email ?? "",
                            style: TextStyle(
                              fontSize: 14.sp, // Responsive font size
                              color: AppColors.grey[600],
                            ),
                          ),
                          onTap: () {
                            final cubit = context.read<GetStudentsCubit>();
                            cubit.selectStudent(student.id!);
                            debugPrint("✅ Selected Student ID: ${student.id}");
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 16.w), // Responsive padding
            child: CustomElevatedButton(
              text: 'Go TO Home',
              onPressed: () {
                final selectedId = context.read<GetStudentsCubit>().selectedStudentId;

                if (selectedId != null) {
                  SelectedStudent.studentId = selectedId;
                  Navigator.pushNamed(context, AppRoutes.homeTab);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primaryColor,
                      content: Text(
                        "Please select a student first",
                        style: TextStyle(
                          fontSize: 14.sp, // Responsive font size
                          color: AppColors.white,
                        ),
                      ),
                      padding: EdgeInsets.all(12.r), // Responsive padding
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r), // Responsive radius
                      ),
                    ),
                  );
                }
              },
              backgroundColor: AppColors.primaryColor,
              textStyle: TextStyle(
                color: AppColors.white,
                fontSize: 16.sp, // Responsive font size
                fontWeight: FontWeight.w600,
              ),
              // padding: EdgeInsets.symmetric(
              //   horizontal: 32.w,
              //   vertical: 12.h,
              // ), // Responsive padding
              // borderRadius: BorderRadius.circular(8.r), // Responsive radius
            ),
          ),
        ],
      ),
    );
  }
}
