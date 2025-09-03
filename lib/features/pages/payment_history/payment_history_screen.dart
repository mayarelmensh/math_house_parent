import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'package:math_house_parent/features/pages/payment_history/cubit/payment_history_cubit.dart';
import '../../../core/utils/app_colors.dart';
import '../../../data/models/payment_history_response_dm.dart';
import '../payment_invoice/cubit/paymnt_invoice_cubit.dart';
import '../payment_invoice/payment_invoice_screen.dart';
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
      create: (context) => GetIt.instance<PaymentHistoryCubit>()..getPayments(userId: userId),
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
      appBar: CustomAppBar(title: "Payment History",
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentHistoryCubit>().refreshPayments(userId: userId);
            },
            icon: const Icon(Icons.refresh, color: AppColors.white),
          ),
        ],),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: BlocBuilder<PaymentHistoryCubit, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                } else if (state is PaymentError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PaymentHistoryCubit>().getPayments(userId: userId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is PaymentSuccess) {
                  if (state.payments.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 64,
                            color: AppColors.lightGray,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No payments found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.shadowGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<PaymentHistoryCubit>().refreshPayments(userId: userId);
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.payments.length,
                      itemBuilder: (context, index) {
                        final payment = state.payments[index];
                        return _buildPaymentCard(payment);
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Filter: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pending', 'Pending'),
                  const SizedBox(width: 8),
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
          color: isSelected ? AppColors.primary : AppColors.darkGrey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
        context.read<PaymentHistoryCubit>().filterPaymentsByStatus(value);
      },
      selectedColor: AppColors.primaryLight,
      backgroundColor: AppColors.lightGray,
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightGray,
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.paymentInvoice,
          arguments:  {
        'paymentId': payment.id,

        // هنا استخدم package.id وليس selectedPackage.id
        },
          // MaterialPageRoute(
          //   builder: (_) => BlocProvider(
          //     create: (context) => GetIt.instance<PaymentInvoiceCubit>()..getInvoice(paymentId: payment.id),
          //     child: PaymentInvoiceScreen(paymentId: payment.id),
          //   ),
          // ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        color: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${payment.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.shadowGrey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: payment.isApproved
                          ? AppColors.green.withOpacity(0.1)
                          : AppColors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: payment.isApproved ? AppColors.green : AppColors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      payment.status,
                      style: TextStyle(
                        color: payment.isApproved ? AppColors.green : AppColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.calendar_today,
                'Date',
                payment.date,
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                Icons.payment,
                'Payment Method',
                payment.paymentMethod,
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                Icons.monetization_on,
                'Amount',
                payment.formattedPrice,
                valueColor: AppColors.green,
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                Icons.business_center,
                'Service',
                payment.service,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.lightGray,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor ?? AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}