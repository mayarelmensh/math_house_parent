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

  Future<void> pickImage(ImageSource source, BuildContext bottomSheetContext) async {
    try {
      Navigator.pop(bottomSheetContext); // Close the image source bottom sheet

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
      showTopSnackBar(context, 'Error selecting image: ${e.toString()}');
    }
  }

  void showImageSourceBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
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
                          Icon(Icons.camera_alt, size: 40.sp, color: AppColors.primaryColor),
                          SizedBox(height: 8.h),
                          Text('Camera'),
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
                          Icon(Icons.photo_library, size: 40.sp, color: AppColors.primaryColor),
                          SizedBox(height: 8.h),
                          Text('Gallery'),
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

  void _showPaymentMethodsBottomSheet() {
    setState(() {
      imageBytes = null;
      base64String = null;
      selectedMethod = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
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
              showTopSnackBar(context, state.message);
            }
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomSheetSetState) {
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
                    // amount: packagePrice ?? 0.0,
                    userId: SelectedStudent.studentId,
                    // duration: packageDuration ?? 30,
                    image: imageData,
                  );
                } catch (e) {
                  showTopSnackBar(context, 'Error confirming purchase: ${e.toString()}');
                }
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(top: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Column(
                          children: [
                            Text(
                              'Package: $packageName',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Price: \$${packagePrice ?? 0}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.green,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Duration: ${packageDuration ?? 30} days',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedMethod?.id != 'Wallet')
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: Column(
                            children: [
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
                                    child: Image.memory(
                                      imageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  height: 150.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.grey[200],
                                  ),
                                  child: const Icon(Icons.image, size: 40),
                                ),
                              SizedBox(height: 8.h),
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
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
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
                                        bottomSheetSetState(() {});
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      Expanded(
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
                              final methods = [
                                _walletPaymentMethod,
                                ...?state.paymentMethodsResponse.paymentMethods,
                              ];
                              return ListView.builder(
                                padding: EdgeInsets.all(16.w),
                                itemCount: methods.length,
                                itemBuilder: (context, index) {
                                  final method = methods[index];
                                  final isSelected = selectedMethod?.id == method.id;
                                  return GestureDetector(
                                    onTap: () {
                                      bottomSheetSetState(() {
                                        selectedMethod = method;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isSelected
                                              ? [
                                            AppColors.primaryColor.withOpacity(0.3),
                                            AppColors.primaryColor.withOpacity(0.1)
                                          ]
                                              : [AppColors.white, AppColors.grey.shade50],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primaryColor : AppColors.grey[300]!,
                                          width: isSelected ? 3.w : 1.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.grey.withOpacity(isSelected ? 0.3 : 0.15),
                                            spreadRadius: 1,
                                            blurRadius: 8,
                                            offset: Offset(0, 3.h),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(20.w),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 60.w,
                                                  height: 60.h,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.grey.withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2.h),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    child: method.logo != null && method.logo!.isNotEmpty
                                                        ? Image.network(
                                                      method.logo!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, _, __) => Container(
                                                        color: AppColors.grey.shade200,
                                                        child: Icon(
                                                          Icons.payment,
                                                          color: AppColors.primaryColor,
                                                        ),
                                                      ),
                                                    )
                                                        : Container(
                                                      color: AppColors.grey.shade200,
                                                      child: Icon(
                                                        method.paymentType?.toLowerCase() == 'wallet'
                                                            ? Icons.account_balance_wallet
                                                            : Icons.payment,
                                                        color: AppColors.primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        method.payment ?? "Unknown Payment",
                                                        style: TextStyle(
                                                          fontSize: 18.sp,
                                                          fontWeight: FontWeight.bold,
                                                          color: isSelected
                                                              ? AppColors.primaryColor
                                                              : AppColors.grey[800],
                                                        ),
                                                      ),
                                                      SizedBox(height: 4.h),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 4.h,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _getPaymentTypeColor(method.paymentType),
                                                          borderRadius: BorderRadius.circular(12.r),
                                                        ),
                                                        child: Text(
                                                          _getPaymentTypeText(method.paymentType),
                                                          style: TextStyle(
                                                            color: AppColors.white,
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
                                                    color: AppColors.primaryColor,
                                                    size: 24.sp,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (method.description != null && method.description!.isNotEmpty)
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                                              child: Container(
                                                padding: EdgeInsets.all(16.w),
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12.r),
                                                  border: Border.all(color: AppColors.grey.shade200),
                                                ),
                                                child: Text(
                                                  method.description!,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: AppColors.grey[800],
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (method.paymentType?.toLowerCase() == 'phone' && method.description != null)
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  await Clipboard.setData(ClipboardData(text: method.description!));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Payment number copied to clipboard'),
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
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.r),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                                ),
                                              ),
                                            ),
                                          if ((method.paymentType?.toLowerCase() == 'link' ||
                                              method.paymentType?.toLowerCase() == 'integration') &&
                                              method.description != null)
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  final url = method.description!;
                                                  final uri = Uri.tryParse(url);

                                                  if (uri != null) {
                                                    final canLaunch = await canLaunchUrl(uri);

                                                    if (canLaunch) {
                                                      // افتح في أبلكيشن خارجي لو متاح
                                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                    } else {
                                                      // لو مفيش، افتحه جوه الأبلكيشن
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
                                                }
                                                ,
                                                icon: Icon(Icons.link, size: 16.sp, color: AppColors.white),
                                                label: Text(
                                                  'Open Payment Link',
                                                  style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.purple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.r),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (state is PaymentMethodsErrorState) {
                              return Center(
                                child: Text(
                                  'Failed to load payment methods',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.grey[600],
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: CustomElevatedButton(
                          backgroundColor: AppColors.primaryColor,
                          textStyle: TextStyle(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                          text: "Confirm Purchase",
                          onPressed: (selectedMethod != null &&
                              (selectedMethod!.id == 'Wallet' || base64String != null))
                              ? confirmPurchase
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
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

  Widget _buildPaymentMethodCard(PaymentMethodEntity method) {
    final isSelected = selectedMethod?.id == method.id;

    return GestureDetector(
      onTap: () {
        _showPaymentMethodsBottomSheet();
        setState(() {
          selectedMethod = method;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2.w) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
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
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.payment ?? "Unknown Payment",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getPaymentTypeColor(method.paymentType),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _getPaymentTypeText(method.paymentType),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => paymentMethodsCubit,
      child: Scaffold(
        backgroundColor: AppColors.grey.shade50,
        appBar: CustomAppBar(title: "Payment Methods"),
        body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
          bloc: paymentMethodsCubit,
          builder: (context, state) {
            if (state is PaymentMethodsLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              );
            } else if (state is PaymentMethodsSuccessState) {
              final methods = [
                _walletPaymentMethod,
                ...?state.paymentMethodsResponse.paymentMethods
              ];

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName ?? "",
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Text("Module: ${packageModule ?? ""}"),
                        Text("Duration: ${packageDuration ?? ""} Days"),
                        Text("Price: \$${packagePrice ?? ""}"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: methods.length,
                        itemBuilder: (context, index) => _buildPaymentMethodCard(methods[index]),
                      ),
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
