import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/buy_package_states.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../../core/di/di.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../data/models/student_selected.dart';
import '../../../domain/entities/payment_methods_response_entity.dart';
import '../../widgets/custom_elevated_button.dart';
import 'cubit/payment_methods_cubit.dart';
import 'cubit/payment_methods_states.dart';
import 'cubit/buy_package_cubit.dart';
import '../../../core/utils/custom_snack_bar.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
  final buyPackageCubit = getIt<BuyPackageCubit>();
  final ImagePicker _picker = ImagePicker();

  int? packageId;
  String? packageName;
  String? packageModule;
  int? packageDuration;
  double? packagePrice;

  String? base64String;
  Uint8List? imageBytes;
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
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
    buyPackageCubit.close();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
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
            content: const Text('Payment proof uploaded successfully'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      showTopSnackBar(context, 'Error selecting image: ${e.toString()}', AppColors.primaryColor);
    }
  }

  void showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 32.sp, color: AppColors.primaryColor),
                          SizedBox(height: 6.h),
                          Text('Camera'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 32.sp, color: AppColors.primaryColor),
                          SizedBox(height: 6.h),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPackageInfoCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2.h),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: AppColors.primaryColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageName ?? "N/A",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      packageModule ?? "N/A",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _getModuleColor(packageModule),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${packageDuration ?? 0} Days",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "\$${packagePrice ?? 0}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, color: color, size: 14.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void confirmPurchase() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String imageData;

    if (selectedMethod!.id == 'Wallet') {
      imageData = 'wallet';
    } else {
      if (base64String == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload the invoice image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      imageData = 'data:image/jpeg;base64,$base64String';
    }

    try {
      await buyPackageCubit.buyPackage(
        packageId: packageId!,
        paymentMethodId: selectedMethod!.id!,
        userId: SelectedStudent.studentId,
        image: imageData,
      );
    } catch (e) {
      showTopSnackBar(context, 'Error confirming purchase: ${e.toString()}', AppColors.primaryColor);
    }
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

  Color _getModuleColor(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return Colors.red.shade500;
      case 'question':
        return Colors.blue.shade500;
      case 'exam':
        return Colors.purple.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          if (method.id == 'Wallet') {
            imageBytes = null;
            base64String = null;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
              AppColors.primaryColor.withOpacity(0.15),
              AppColors.primaryColor.withOpacity(0.05)
            ]
                : [AppColors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: isSelected ? 6 : 3,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: method.logo != null && method.logo!.isNotEmpty
                          ? Image.network(
                        method.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Icon(
                          Icons.payment,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                      )
                          : Icon(
                        method.paymentType?.toLowerCase() == 'wallet'
                            ? Icons.account_balance_wallet
                            : Icons.payment,
                        color: AppColors.primaryColor,
                        size: 20.sp,
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getPaymentTypeColor(method.paymentType),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _getPaymentTypeText(method.paymentType),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    )
                  else
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected && method.description != null && method.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        method.description!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (method.paymentType?.toLowerCase() == 'phone') ...[
                        SizedBox(height: 6.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: method.description!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Payment number copied to clipboard'),
                                  backgroundColor: AppColors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: Icon(Icons.copy, size: 12.sp, color: AppColors.white),
                            label: Text(
                              'Copy Payment Number',
                              style: TextStyle(fontSize: 11.sp, color: AppColors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              minimumSize: Size(0, 28.h),
                            ),
                          ),
                        ),
                      ],
                      if (method.paymentType?.toLowerCase() == 'link' ||
                          method.paymentType?.toLowerCase() == 'integration') ...[
                        SizedBox(height: 6.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
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
                            icon: Icon(Icons.link, size: 12.sp, color: AppColors.white),
                            label: Text(
                              'Open Payment Link',
                              style: TextStyle(fontSize: 11.sp, color: AppColors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              minimumSize: Size(0, 28.h),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProofSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Proof',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey[800],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Upload a screenshot or photo of your payment confirmation',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          if (imageBytes != null)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: 100.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.primaryColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade100,
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 28.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'No image selected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: showImageSourceBottomSheet,
                  icon: Icon(Icons.upload_file, color: AppColors.white, size: 16.sp),
                  label: Text(
                    'Upload Image',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              if (imageBytes != null) ...[
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        imageBytes = null;
                        base64String = null;
                      });
                    },
                    icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: paymentMethodsCubit),
        BlocProvider.value(value: buyPackageCubit),
      ],
      child: BlocListener<BuyPackageCubit, BuyPackageState>(
        listener: (context, state) {
          if (state is BuyPackageSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Package "$packageName" purchased successfully!'),
                backgroundColor: AppColors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is BuyPackageError) {
            showTopSnackBar(context, state.message, AppColors.primaryColor);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: CustomAppBar(title: "Payment Methods"),
          body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
            bloc: paymentMethodsCubit,
            builder: (context, state) {
              if (state is PaymentMethodsLoadingState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Loading payment methods...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is PaymentMethodsSuccessState) {
                final methods = [
                  _walletPaymentMethod,
                  ...?state.paymentMethodsResponse.paymentMethods,
                ];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        _buildCompactPackageInfoCard(),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              paymentMethodsCubit.getPaymentMethods(
                                  userId: SelectedStudent.studentId);
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.all(12.w),
                              itemCount: methods.length,
                              itemBuilder: (context, index) => _buildPaymentMethodCard(methods[index]),
                            ),
                          ),
                        ),
                        if (selectedMethod != null) ...[
                          if (selectedMethod?.id != 'Wallet') _buildPaymentProofSection(),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, -2.h),
                                ),
                              ],
                            ),
                            child: CustomElevatedButton(
                              backgroundColor: (selectedMethod != null &&
                                  (selectedMethod!.id == 'Wallet' || base64String != null))
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade400,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              text: "Confirm Purchase",
                              onPressed: (selectedMethod != null &&
                                  (selectedMethod!.id == 'Wallet' || base64String != null))
                                  ? confirmPurchase
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: Colors.red.shade400,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Failed to load payment methods',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Please check your connection and try again',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          paymentMethodsCubit.getPaymentMethods(
                              userId: SelectedStudent.studentId);
                        },
                        icon: Icon(Icons.refresh, color: Colors.white, size: 16.sp),
                        label: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}