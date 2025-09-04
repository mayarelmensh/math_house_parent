import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/buy_package_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/di.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/student_selected.dart';
import '../../../domain/entities/payment_methods_response_entity.dart';
import '../../widgets/custom_elevated_button.dart';
import 'cubit/payment_methods_cubit.dart';
import 'cubit/payment_methods_states.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final buyPackageCubit = getIt<BuyPackageCubit>();

  int? packageId;
  String? packageName;
  String? packageModule;
  int? packageDuration;
  double? packagePrice;

  PaymentMethodEntity? selectedMethod;

  final PaymentMethodEntity _walletPaymentMethod = PaymentMethodEntity(
    id: "Wallet",
    payment: 'Wallet',
    paymentType: 'Wallet',
    description: 'Pay using your wallet balance',
    logo: '',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      setState(() {
        packageId = args?['packageId'] as int?;
        packageName = args?['packageName'] as String?;
        packageModule = args?['packageModule'] as String?;
        packageDuration = args?['packageDuration'] as int?;
        packagePrice = args?['packagePrice'] as double?;
      });

      paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
    });
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    super.dispose();
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: method.logo != null && method.logo!.isNotEmpty
                          ? Image.network(
                        method.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(Icons.payment, color: AppColors.primaryColor),
                        ),
                      )
                          : Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          method.paymentType?.toLowerCase() == 'wallet'
                              ? Icons.account_balance_wallet
                              : Icons.payment,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Payment info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.payment ?? "Unknown Payment",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPaymentTypeColor(method.paymentType),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPaymentTypeText(method.paymentType),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action button
                  _buildActionButton(method),
                ],
              ),
            ),
            if (method.description != null && method.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    method.description!,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(PaymentMethodEntity method) {
    switch (method.paymentType?.toLowerCase()) {
      case 'phone':
        return IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: method.description ?? ''));
            setState(() {
              selectedMethod = method;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Phone number copied!'), backgroundColor: Colors.green),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.phone, color: Colors.green.shade700, size: 20),
          ),
        );
      case 'link':
        return IconButton(
          onPressed: () async {
            setState(() {
              selectedMethod = method;
            });
            final url = method.description ?? '';
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied!')),
              );
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.open_in_new, color: Colors.blue.shade700, size: 20),
          ),
        );
      default:
        if (method.paymentType?.toLowerCase() == 'wallet') {
          return IconButton(
            onPressed: () {
              setState(() {
                selectedMethod = method;
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.account_balance_wallet, color: Colors.orange.shade700, size: 20),
            ),
          );
        } else {
          return IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: method.description ?? ''));
              setState(() {
                selectedMethod = method;
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.copy, color: Colors.grey.shade700, size: 20),
            ),
          );
        }
    }
  }

  Color _getPaymentTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return Colors.green.shade500;
      case 'link':
        return Colors.blue.shade500;
      case 'integration':
        return Colors.purple.shade500;
      case 'text':
        return Colors.orange.shade500;
      case 'wallet':
        return Colors.orange.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  String _getPaymentTypeText(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return 'Phone';
      case 'link':
        return 'Link';
      case 'integration':
        return 'Online';
      case 'text':
        return 'Manual';
      case 'wallet':
        return 'Wallet';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => paymentMethodsCubit,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomAppBar(title: "Payment Methods"),
        body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
          bloc: paymentMethodsCubit,
          builder: (context, state) {
            if (state is PaymentMethodsLoadingState) {
              return  Center(child: CircularProgressIndicator(
                color:AppColors.primaryColor,
              ));
            } else if (state is PaymentMethodsSuccessState) {
              final methods = [
                _walletPaymentMethod,
                ...?state.paymentMethodsResponse.paymentMethods
              ];

              return Column(
                children: [
                  // Package details
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(packageName ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Module: ${packageModule ?? ""}"),
                          Text("Duration: ${packageDuration ?? ""} Days"),
                          Text("Price: \$${packagePrice ?? ""}"),
                        ],
                      ),
                    ),
                  ),

                  // Payment methods list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: methods.length,
                        itemBuilder: (context, index) => _buildPaymentMethodCard(methods[index]),
                      ),
                    ),
                  ),

                  // Buy package button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomElevatedButton(
                      backgroundColor: AppColors.primaryColor,
                      textStyle: TextStyle(color: AppColors.white),
                      text: "Buy Package",
                      onPressed: selectedMethod != null
                          ? () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.buyPackageScreen,
                          arguments: {
                            'packageId': packageId,
                            'paymentMethodId': selectedMethod!.id,
                            'paymentMethodName': selectedMethod!.paymentType?.toLowerCase() == 'wallet'
                                ? 'wallet'
                                : null,
                          },
                        );
                      }
                          : null,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
