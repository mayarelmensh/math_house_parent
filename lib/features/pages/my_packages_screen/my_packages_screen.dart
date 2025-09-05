import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/data/models/student_selected.dart';

import '../../../core/utils/app_colors.dart';
import '../../../data/models/my_package_model.dart';
import 'cubit/my_package_cubit.dart';


class MyPackageScreen extends StatelessWidget {
  final MyPackageCubit packageCubit = getIt<MyPackageCubit>();

  MyPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => packageCubit
        ..fetchMyPackageData(userId: SelectedStudent.studentId ),
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'My Package',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
          elevation: 0,
        ),
        body: BlocBuilder<MyPackageCubit, MyPackageState>(
          builder: (context, state) {
            if (state is MyPackageInitial) {
              return const Center(
                child: Text(
                  'Initializing...',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 16,
                  ),
                ),
              );
            } else if (state is MyPackageLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            } else if (state is MyPackageLoaded) {
              return _buildPackageContent(context, state.package);
            } else if (state is MyPackageError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPackageContent(BuildContext context, MyPackageModel package) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package Details Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowGrey,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Package Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.quiz,
                  label: 'Exams',
                  value: '${package.exams ?? 0}',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.question_answer,
                  label: 'Questions',
                  value: '${package.questions ?? 0}',
                  color: AppColors.blue,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.live_tv,
                  label: 'Lives',
                  value: '${package.lives ?? 0}',
                  color: AppColors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGray,
            ),
          ),
        ),
      ],
    );
  }
}