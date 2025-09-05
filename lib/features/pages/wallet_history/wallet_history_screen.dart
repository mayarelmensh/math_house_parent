import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/data/models/wallet_history.dart';

import '../../../core/utils/app_colors.dart';
import '../../../data/models/student_selected.dart';
import 'cubit/wallet_history_cubit.dart';
import 'cubit/wallet_history_states.dart';


class WalletHistoryScreen extends StatelessWidget {
  final WalletHistoryCubit walletCubit = getIt<WalletHistoryCubit>();

  WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => walletCubit
        ..fetchWalletData(userId: SelectedStudent.studentId),
      child: Scaffold(
        backgroundColor: AppColors.lightGray, // Consistent background
        appBar: CustomAppBar(title: "Wallet History"),
        body: BlocBuilder<WalletHistoryCubit, WalletState>(
          builder: (context, state) {
            if (state is WalletInitial) {
              return const Center(
                child: Text(
                  'Initializing...',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 16,
                  ),
                ),
              );
            } else if (state is WalletLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            } else if (state is WalletLoaded) {
              return _buildWalletContent(context, state.response);
            } else if (state is WalletError) {
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

  Widget _buildWalletContent(BuildContext context, WalletResponse response) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  '${response.money ?? 0} EGP',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Wallet History Section
          const Text(
            'Wallet History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          if (response.wallet_history != null && response.wallet_history!.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: response.wallet_history!.length,
              itemBuilder: (context, index) {
                final history = response.wallet_history![index];
                return Card(
                  color: AppColors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Amount: ${history.wallet ?? 0} EGP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${history.date ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray,
                          ),
                        ),
                        Text(
                          'State: ${history.state ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: history.state == 'Approve'
                                ? AppColors.green
                                : history.state == 'Pendding'
                                ? AppColors.yellow
                                : AppColors.red,
                          ),
                        ),
                        if (history.payment_method != null)
                          Text(
                            'Payment Method: ${history.payment_method}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gray,
                            ),
                          ),
                        if (history.rejected_reason != null)
                          Text(
                            'Rejected Reason: ${history.rejected_reason}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.notAttendColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No wallet history available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray,
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Payment Methods Section
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          if (response.payment_methods != null && response.payment_methods!.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: response.payment_methods!.length,
              itemBuilder: (context, index) {
                final method = response.payment_methods![index];
                return Card(
                  color: AppColors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: method.logo_link != null
                        ? Image.network(
                      method.logo_link!,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(
                        Icons.payment,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    )
                        : const Icon(
                      Icons.payment,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    title: Text(
                      method.payment ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      ),
                    ),
                    subtitle: Text(
                      method.description ?? 'No description',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No payment methods available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}