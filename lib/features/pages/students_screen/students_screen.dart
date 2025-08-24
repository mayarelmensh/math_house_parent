import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/dialog_utils.dart';
import 'package:math_house_parent/features/widgets/custom_text_form_field.dart';
import 'cubit/students_screen_cubit.dart';
import 'cubit/students_screen_states.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final GetStudentsCubit cubit = getIt<GetStudentsCubit>();

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
      appBar: AppBar(title:  Text("Search for Student",style: TextStyle(color: AppColors.primaryColor),)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextFormField(
              prefixIcon: Icon(Icons.search),
              borderColor: AppColors.darkGrey,
              controller: cubit.controller,
              hintText: "Enter the name or email of Student",
              hintStyle: TextStyle(color: AppColors.grey),
              onChanged: (value){
                cubit.searchStudents(value);
              },
            )
          ),
    Expanded(
    child: BlocConsumer<GetStudentsCubit, GetStudentsStates>(
    bloc: cubit,
    listener: (context, state) {
    if (state is GetStudentsLoadingState) {
    DialogUtils.showLoading(
    context: context, message: "Loading students...");
    } else if (state is GetStudentsErrorState) {
    DialogUtils.showMessage(
    context: context,
    message: state.error.errorMsg,
    title: "Error",
    posActionName: "Ok",
    posAction: () => DialogUtils.hideLoading(context),);}},


    builder: (context, state) {
    if (state is GetStudentsLoadingState) {
    return  Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor,));
    }
    else if (state is GetStudentsSuccessState) {
    final students = state.students;
    if (students.isEmpty) {
    return const Center(child: Text("No students found"));
    }
    return ListView.builder(
    itemCount: students.length,
    itemBuilder: (context, index) {
    final student = students[index];
    return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
    title: Text(student.nickName ?? "No Name"),
    subtitle: Text(student.email ?? "No Email"),
    trailing: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor),
    onPressed: () {
    print("Send code to ${student.nickName}");
    },
    child: Text(
    "Send Code",
    style: TextStyle(color: AppColors.white),),
         ),
       ),
      );
     },
    );
    } else if (state is GetStudentsErrorState) {
    return Center(child: Text("Error: ${state.error.errorMsg}"));
    }
    return const SizedBox();
    },
    ),
    ),
        ],
      ),
    );
  }
}
