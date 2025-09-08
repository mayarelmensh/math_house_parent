import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/my_package_model.dart';
import 'cubit/my_package_cubit.dart';

class MyPackageScreen extends StatelessWidget {
  final MyPackageCubit packageCubit = getIt<MyPackageCubit>();

  MyPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          packageCubit..fetchMyPackageData(userId: SelectedStudent.studentId),
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: 'My Packages'),
        body: BlocBuilder<MyPackageCubit, MyPackageState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (state is MyPackageInitial) {
                  return _buildInitialState();
                } else if (state is MyPackageLoading) {
                  return _buildLoadingState();
                } else if (state is MyPackageLoaded) {
                  if (state.package.exams == 0 &&
                      state.package.questions == 0 &&
                      state.package.lives == 0) {
                    return _buildEmptyState(context);
                  }
                  return _buildPackageContent(context, state.package);
                } else if (state is MyPackageError) {
                  return _buildErrorState(context, state.message);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Text(
        'Preparing your packages...',
        style: TextStyle(
          color: AppColors.darkGray,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4.w),
          SizedBox(height: 16.h),
          Text(
            'Loading Packages...',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageContent(BuildContext context, MyPackageModel package) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3.h),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: AppColors.primary,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Your Active Package',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildDetailCard(
              icon: Icons.quiz,
              label: 'Exams',
              value: '${package.exams ?? 0}',
              color: AppColors.primary,
            ),
            SizedBox(height: 12.h),
            _buildDetailCard(
              icon: Icons.question_answer,
              label: 'Questions',
              value: '${package.questions ?? 0}',
              color: AppColors.blue,
            ),
            SizedBox(height: 12.h),
            _buildDetailCard(
              icon: Icons.live_tv,
              label: 'Lives',
              value: '${package.lives ?? 0}',
              color: AppColors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 70.sp,
            color: AppColors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Active Packages',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You don\'t have any active packages.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<MyPackageCubit>().fetchMyPackageData(
                userId: SelectedStudent.studentId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70.sp, color: AppColors.red),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Packages',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<MyPackageCubit>().fetchMyPackageData(
                userId: SelectedStudent.studentId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
