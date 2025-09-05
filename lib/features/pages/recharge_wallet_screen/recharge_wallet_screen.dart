// wallet_recharge_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_cubit.dart';
import 'package:math_house_parent/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_states.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'package:math_house_parent/domain/entities/payment_methods_response_entity.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/payment_methods_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';

import '../../../core/utils/custom_snack_bar.dart';


class WalletRechargeScreen extends StatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  State<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends State<WalletRechargeScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final walletRechargeCubit = getIt<WalletRechargeCubit>();
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  double? rechargeAmount;
  PaymentMethodEntity? selectedMethod;

  // Image variables
  String? base64String;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
    });
  }

  @override
  void dispose() {
    paymentMethodsCubit.close();
    _amountController.dispose();
    super.dispose();
  }

  // Image picker function
  Future<void> pickImage(ImageSource source, BuildContext bottomSheetContext) async {
    try {
      Navigator.pop(bottomSheetContext);

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final List<int> imageFileBytes = await imageFile.readAsBytes();
        final String imageBase64 = base64Encode(imageFileBytes);

        setState(() {
          imageBytes = Uint8List.fromList(imageFileBytes);
          base64String = imageBase64;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment proof uploaded successfully'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      showTopSnackBar(context, 'Error selecting image: ${e.toString()}');
    }
  }

  // Show image source bottom sheet
  void showImageSourceBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => pickImage(ImageSource.camera, context),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Camera'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => pickImage(ImageSource.gallery, context),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 40, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          // Reset image when changing payment method
          imageBytes = null;
          base64String = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)]
                : [AppColors.white, AppColors.lightGray],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(isSelected ? 0.3 : 0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
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
                          color: AppColors.lightGray,
                          child: Icon(
                            Icons.payment,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                          : Container(
                        color: AppColors.lightGray,
                        child: Icon(
                          Icons.payment,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.payment ?? "Unknown Payment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.darkGray,
                          ),
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
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
            if (method.description != null && method.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey[200]!),
                  ),
                  child: Text(
                    method.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            if (method.paymentType?.toLowerCase() == 'phone' && method.description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: method.description!));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment number copied to clipboard'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.copy, size: 16, color: AppColors.white),
                  label: Text(
                    'Copy Payment Number',
                    style: TextStyle(fontSize: 14, color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            if ((method.paymentType?.toLowerCase() == 'link' || method.paymentType?.toLowerCase() == 'integration') &&
                method.description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = method.description!;
                    final uri = Uri.tryParse(url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open payment link'),
                            backgroundColor: AppColors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.link, size: 16, color: AppColors.white),
                  label: Text(
                    'Open Payment Link',
                    style: TextStyle(fontSize: 14, color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return AppColors.green;
      case 'link':
        return AppColors.blue;
      case 'integration':
        return AppColors.purple;
      case 'text':
        return AppColors.orange;
      case 'wallet':
        return AppColors.yellow;
      default:
        return AppColors.grey[500]!;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: paymentMethodsCubit),
        BlocProvider.value(value: walletRechargeCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomAppBar(title: "Recharge Wallet"),
        body: BlocListener<WalletRechargeCubit, WalletRechargeStates>(
          listener: (context, state) {
            if (state is WalletRechargeSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.success ?? 'Wallet recharged successfully!'),
                  backgroundColor: AppColors.green,
                ),
              );
              // Reset form after success
              setState(() {
                _amountController.clear();
                rechargeAmount = null;
                selectedMethod = null;
                imageBytes = null;
                base64String = null;
              });
            } else if (state is WalletRechargeErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          child: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
            bloc: paymentMethodsCubit,
            builder: (context, state) {
              if (state is PaymentMethodsLoadingState) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              } else if (state is PaymentMethodsSuccessState) {
                // Exclude wallet from payment methods for recharging
                final methods = state.paymentMethodsResponse.paymentMethods
                    ?.where((method) => method.paymentType?.toLowerCase() != 'wallet')
                    .toList() ?? [];

                return Column(
                  children: [
                    // Amount input section
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter Recharge Amount",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Enter amount in EGP',
                              prefixIcon: Icon(Icons.monetization_on, color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.primary, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                rechargeAmount = double.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (rechargeAmount != null && rechargeAmount! > 0)
                            Text(
                              "Amount: ${rechargeAmount!.toStringAsFixed(2)} EGP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.green,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Image upload section (only show if payment method selected and not wallet)
                    if (selectedMethod != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload Payment Proof",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (imageBytes != null)
                              Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    imageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image, size: 40, color: Colors.grey[600]),
                                      SizedBox(height: 8),
                                      Text(
                                        'No image selected',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showImageSourceBottomSheet(context);
                                    },
                                    icon: Icon(Icons.upload_file, color: AppColors.white),
                                    label: Text(
                                      'Upload Invoice Image',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ),
                                if (imageBytes != null) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        imageBytes = null;
                                        base64String = null;
                                      });
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
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

                    // Recharge wallet button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<WalletRechargeCubit, WalletRechargeStates>(
                        builder: (context, rechargeState) {
                          final isLoading = rechargeState is WalletRechargeLoadingState;
                          final canRecharge = selectedMethod != null &&
                              rechargeAmount != null &&
                              rechargeAmount! > 0 &&
                              base64String != null;

                          return CustomElevatedButton(
                            backgroundColor: canRecharge && !isLoading
                                ? AppColors.primaryColor
                                : AppColors.grey[400]!,
                            textStyle: TextStyle(color: AppColors.white),
                            text: isLoading ? "Processing..." : "Recharge Wallet",
                            onPressed: canRecharge && !isLoading
                                ? () async {
                              String imageData = 'data:image/jpeg;base64,$base64String';

                              await walletRechargeCubit.rechargeWallet(
                                userId: SelectedStudent.studentId,
                                wallet: rechargeAmount!,
                                paymentMethodId: selectedMethod!.id!,
                                image: imageData,
                              );
                            }
                                : null,
                          );
                        },
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
      ),
    );
  }
}