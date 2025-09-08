import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'package:math_house_parent/features/pages/payment_history/cubit/payment_history_cubit.dart';
import '../../../core/utils/app_colors.dart';
import '../../../data/models/payment_history_response_dm.dart';
import 'cubit/payment_history_states.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

int userId = SelectedStudent.studentId;

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<PaymentHistoryCubit>()..getPayments(userId: userId),
      child: const PaymentScreenView(),
    );
  }
}

class PaymentScreenView extends StatefulWidget {
  const PaymentScreenView({Key? key}) : super(key: key);

  @override
  State<PaymentScreenView> createState() => _PaymentScreenViewState();
}

class _PaymentScreenViewState extends State<PaymentScreenView> {
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Payment History",
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentHistoryCubit>().refreshPayments(
                userId: userId,
              );
            },
            icon: Icon(Icons.refresh, color: AppColors.white, size: 24.sp),
          ),
        ],
      ),
      backgroundColor: AppColors.lightGray,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: BlocBuilder<PaymentHistoryCubit, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 4.w,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Loading Payments...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is PaymentError) {
                      return _buildErrorState(context, state.message);
                    } else if (state is PaymentSuccess) {
                      if (state.payments.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<PaymentHistoryCubit>()
                              .refreshPayments(userId: userId);
                        },
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: EdgeInsets.all(12.w),
                          itemCount: state.payments.length,
                          itemBuilder: (context, index) {
                            final payment = state.payments[index];
                            return _buildPaymentCard(context, payment);
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Filter: ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('pending', 'Pending'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('approved', 'Approved'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
        context.read<PaymentHistoryCubit>().filterPaymentsByStatus(value);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.lightGray,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.grey,
        width: 1.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentModel payment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 2.h),
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.paymentInvoice,
            arguments: {'paymentId': payment.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${payment.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.darkGray,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: payment.isApproved
                        ? AppColors.green.withOpacity(0.1)
                        : AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: payment.isApproved
                          ? AppColors.green
                          : AppColors.red,
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    payment.status,
                    style: TextStyle(
                      color: payment.isApproved
                          ? AppColors.green
                          : AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: payment.date,
                ),
                _buildInfoItem(
                  icon: Icons.payment,
                  label: 'Method',
                  value: payment.paymentMethod,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.monetization_on,
                  label: 'Amount',
                  value: payment.formattedPrice,
                  valueColor: AppColors.green,
                ),
                _buildInfoItem(
                  icon: Icons.business_center,
                  label: 'Service',
                  value: payment.service,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: valueColor ?? AppColors.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 70.sp, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            'No Payments Found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You haven\'t made any payments yet.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<PaymentHistoryCubit>().refreshPayments(
                userId: userId,
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
                color: AppColors.white,
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
            'Error Loading Payments',
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
              context.read<PaymentHistoryCubit>().getPayments(userId: userId);
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
                color: AppColors.white,
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
