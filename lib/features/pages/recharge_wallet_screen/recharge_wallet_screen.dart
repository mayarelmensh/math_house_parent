import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'package:math_house_parent/domain/entities/payment_methods_response_entity.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/payment_methods_states.dart';
import 'package:math_house_parent/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_cubit.dart';
import 'package:math_house_parent/features/pages/recharge_wallet_screen/cuibt/recharge_wallet_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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
            content: Text('Payment proof uploaded successfully', style: TextStyle(fontSize: 14.sp)),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e', style: TextStyle(fontSize: 14.sp)),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void showImageSourceBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => pickImage(ImageSource.camera, context),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 40.sp, color: AppColors.primary),
                          SizedBox(height: 8.h),
                          Text('Camera', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: InkWell(
                    onTap: () => pickImage(ImageSource.gallery, context),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 40.sp, color: AppColors.primary),
                          SizedBox(height: 8.h),
                          Text('Gallery', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void showPaymentMethodsBottomSheet(BuildContext context, List<PaymentMethodEntity> methods) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: methods.length,
                  itemBuilder: (context, index) {
                    final method = methods[index];
                    final isSelected = selectedMethod?.id == method.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethod = method;
                          imageBytes = null;
                          base64String = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)]
                                : [AppColors.white, AppColors.lightGray],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(isSelected ? 0.3 : 0.15),
                              spreadRadius: 1.r,
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1.r,
                                        blurRadius: 4.r,
                                        offset: Offset(0, 2.h),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: method.logo != null && method.logo!.isNotEmpty
                                        ? Image.network(
                                      method.logo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, _, __) => Container(
                                        color: AppColors.lightGray,
                                        child: Icon(Icons.payment, color: AppColors.primary, size: 24.sp),
                                      ),
                                    )
                                        : Container(
                                      color: AppColors.lightGray,
                                      child: Icon(Icons.payment, color: AppColors.primary, size: 24.sp),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.payment ?? "Unknown Payment",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.primary : AppColors.darkGray,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: _getPaymentTypeColor(method.paymentType),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          _getPaymentTypeText(method.paymentType),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
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
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                            if (method.description != null && method.description!.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGray,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: AppColors.grey[200]!),
                                ),
                                child: Text(
                                  method.description!,
                                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey[800], height: 1.4),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              if (method.paymentType?.toLowerCase() == 'phone')
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: method.description!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment number copied to clipboard', style: TextStyle(fontSize: 14.sp)),
                                        backgroundColor: AppColors.green,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.copy, size: 16.sp, color: AppColors.white),
                                  label: Text(
                                    'Copy Payment Number',
                                    style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  ),
                                ),
                              if (method.paymentType?.toLowerCase() == 'link' || method.paymentType?.toLowerCase() == 'integration')
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final url = method.description!;
                                    final uri = Uri.tryParse(url);

                                    if (uri != null) {
                                      final canLaunch = await canLaunchUrl(uri);
                                      if (canLaunch) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      } else {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.inAppWebView,
                                          webViewConfiguration: const WebViewConfiguration(
                                            enableJavaScript: true,
                                          ),
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Invalid URL'),
                                            backgroundColor: AppColors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.link, size: 16.sp, color: AppColors.white),
                                  label: Text(
                                    'Open Payment Link',
                                    style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.purple,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
                  content: Text(state.response.success ?? 'Wallet recharged successfully!', style: TextStyle(fontSize: 14.sp)),
                  backgroundColor: AppColors.green,
                ),
              );
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
                  content: Text(state.error, style: TextStyle(fontSize: 14.sp)),
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
                  child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 3.w),
                );
              } else if (state is PaymentMethodsSuccessState) {
                final methods = state.paymentMethodsResponse.paymentMethods
                    ?.where((method) => method.paymentType?.toLowerCase() != 'wallet')
                    .toList() ?? [];

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Amount input section
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter Recharge Amount",
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Enter amount in EGP',
                                prefixIcon: Icon(Icons.monetization_on, color: AppColors.primary, size: 20.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: AppColors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              ),
                              style: TextStyle(fontSize: 16.sp),
                              onChanged: (value) {
                                setState(() {
                                  rechargeAmount = double.tryParse(value);
                                });
                              },
                            ),
                            if (rechargeAmount != null && rechargeAmount! > 0) ...[
                              SizedBox(height: 8.h),
                              Text(
                                "Amount: ${rechargeAmount!.toStringAsFixed(2)} EGP",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Selected Payment Method
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: ElevatedButton(
                          onPressed: () => showPaymentMethodsBottomSheet(context, methods),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            selectedMethod == null ? 'Select Payment Method' : selectedMethod!.payment ?? 'Unknown Payment',
                            style: TextStyle(fontSize: 16.sp, color: Colors.white),
                          ),
                        ),
                      ),

                      // Image upload section
                      if (selectedMethod != null)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 3.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upload Payment Proof",
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16.h),
                              if (imageBytes != null)
                                Container(
                                  width: double.infinity,
                                  height: 150.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  height: 150.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.grey[200],
                                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image, size: 40.sp, color: Colors.grey[600]),
                                        SizedBox(height: 8.h),
                                        Text('No image selected', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => showImageSourceBottomSheet(context),
                                      icon: Icon(Icons.upload_file, color: AppColors.white, size: 20.sp),
                                      label: Text('Upload Invoice Image', style: TextStyle(fontSize: 14.sp, color: AppColors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                      ),
                                    ),
                                  ),
                                  if (imageBytes != null) ...[
                                    SizedBox(width: 8.w),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          imageBytes = null;
                                          base64String = null;
                                        });
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red, size: 24.sp),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                      // Recharge wallet button
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: BlocBuilder<WalletRechargeCubit, WalletRechargeStates>(
                          builder: (context, rechargeState) {
                            final isLoading = rechargeState is WalletRechargeLoadingState;
                            final canRecharge = selectedMethod != null && rechargeAmount != null && rechargeAmount! > 0 && base64String != null;

                            return CustomElevatedButton(
                              backgroundColor: canRecharge && !isLoading ? AppColors.primaryColor : AppColors.grey[400]!,
                              textStyle: TextStyle(fontSize: 16.sp, color: AppColors.white),
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
                  ),
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