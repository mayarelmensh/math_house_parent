import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import '../../../core/utils/app_colors.dart';
import 'cubit/payment_invoice_states.dart';
import 'cubit/paymnt_invoice_cubit.dart';

class PaymentInvoiceScreen extends StatefulWidget {

  const PaymentInvoiceScreen({Key? key}) : super(key: key);

  @override
  State<PaymentInvoiceScreen> createState() => _PaymentInvoiceScreenState();
}

class _PaymentInvoiceScreenState extends State<PaymentInvoiceScreen> {
   int paymentId=0;
   PaymentInvoiceCubit paymentInvoiceCubit=getIt<PaymentInvoiceCubit>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      setState(() {
        paymentId = args?['paymentId'] as int;
      });
       paymentInvoiceCubit.getInvoice(paymentId: paymentId);
      // paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<PaymentInvoiceCubit, PaymentInvoiceState>(
        bloc: paymentInvoiceCubit,
        builder: (context, state) {
          if (state is PaymentInvoiceLoading) {
            return  Center(child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          } else if (state is PaymentInvoiceError) {
            return Center(child: Text(state.message));
          } else if (state is PaymentInvoiceSuccess) {
            print("//////////////////////////////$paymentId");
            final invoice = state.invoice.invoice;
            if (invoice == null) {
              return const Center(child: Text('No invoice data available'));
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  invoice.receipt != null?
                    Image.network(invoice.receipt!, height: 200, fit: BoxFit.contain):
                     Text("There's no receipt"),
                  const SizedBox(height: 16),
                  _buildInfoRow('Service', invoice.service),
                  _buildInfoRow('Payment Method', invoice.paymentMethod),
                  _buildInfoRow('Total', invoice.total?.toString() ?? ''),
                  _buildInfoRow('Package', invoice.package),
                  _buildInfoRow('Category', invoice.category),
                  _buildInfoRow('Course', invoice.course),
                  if (invoice.chapters != null)
                    _buildInfoRow('Chapters', invoice.chapters.toString()),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}