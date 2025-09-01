import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/di.dart';
import '../../../domain/entities/payment_methods_response_entity.dart';
import 'cubit/payment_methods_cubit.dart';
import 'cubit/payment_methods_states.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();

  @override
  void initState() {
    super.initState();
    paymentMethodsCubit.getPaymentMethods(userId: 2);
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    super.dispose();
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity paymentMethod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          // Header with logo and payment name
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
                    child: paymentMethod.logo != null
                        ? Image.network(
                      paymentMethod.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.payment,
                            size: 30,
                            color: AppColors.primaryColor,
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.payment,
                        size: 30,
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
                        paymentMethod.payment ?? "Unknown Payment",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPaymentTypeColor(paymentMethod.paymentType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPaymentTypeText(paymentMethod.paymentType),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action button
                _buildActionButton(paymentMethod),
              ],
            ),
          ),
          // Description
          if (paymentMethod.description != null &&
              paymentMethod.description!.isNotEmpty)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Payment Details",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paymentMethod.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(PaymentMethodEntity paymentMethod) {
    switch (paymentMethod.paymentType?.toLowerCase()) {
      case 'phone':
        return IconButton(
          onPressed: () => _copyToClipboard(
            paymentMethod.description ?? '',
            'Phone number copied!',
          ),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.phone,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
        );
      case 'link':
        return IconButton(
          onPressed: () => _launchURL(paymentMethod.description ?? ''),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.open_in_new,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
        );
      case 'integration':
        return IconButton(
          onPressed: () => _showIntegrationDialog(paymentMethod),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.credit_card,
              color: Colors.purple.shade700,
              size: 20,
            ),
          ),
        );
      default:
        return IconButton(
          onPressed: () => _copyToClipboard(
            paymentMethod.description ?? '',
            'Information copied!',
          ),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.copy,
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
        );
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
      default:
        return 'Other';
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _copyToClipboard(url, 'Link copied to clipboard!');
    }
  }

  void _showIntegrationDialog(PaymentMethodEntity paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.credit_card,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  paymentMethod.payment ?? "Payment",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paymentMethod.description ?? "No description available",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "This payment method supports online integration with various payment options.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle integration payment logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Opening ${paymentMethod.payment} integration..."),
                    backgroundColor: AppColors.primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Proceed",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => paymentMethodsCubit,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomAppBar(title: "Payment Methods"),
        body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
          builder: (context, state) {
            if (state is PaymentMethodsLoadingState) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Loading payment methods...",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else if (state is PaymentMethodsSuccessState) {
              final paymentMethods = state.paymentMethodsResponse.paymentMethods;

              if (paymentMethods == null || paymentMethods.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No payment methods available",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please contact support for assistance",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  paymentMethodsCubit.getPaymentMethods(userId: 2);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    return _buildPaymentMethodCard(paymentMethods[index]);
                  },
                ),
              );
            } else if (state is PaymentMethodsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error loading payment methods",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        paymentMethodsCubit.getPaymentMethods(userId: 2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}