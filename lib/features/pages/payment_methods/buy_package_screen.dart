import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/di/di.dart';
import 'cubit/buy_package_cubit.dart';
import 'cubit/buy_package_states.dart';

class BuyPackageScreen extends StatefulWidget {
  final int? packageId;
  final int? paymentMethodId;
  final String? paymentMethodName;

  const BuyPackageScreen({
    Key? key,
    this.packageId,
    this.paymentMethodId,
    this.paymentMethodName,
  }) : super(key: key);

  @override
  _BuyPackageScreenState createState() => _BuyPackageScreenState();
}

class _BuyPackageScreenState extends State<BuyPackageScreen> {
  final buyPackageCubit = getIt<BuyPackageCubit>();

  int? packageId;
  int? paymentMethodId;
  String? paymentMethodName;

  File? _invoiceImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    packageId = widget.packageId ?? args?['packageId'] as int?;
    paymentMethodId = widget.paymentMethodId ?? args?['paymentMethodId'] as int?;
    paymentMethodName = widget.paymentMethodName?.toLowerCase() ??
        (args?['paymentMethodName'] as String?)?.toLowerCase();

    if (packageId == null || paymentMethodId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing package or payment method data'),
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _invoiceImage = File(pickedFile.path);
      });
    }
  }

  void _confirmPurchase() {
    if (packageId == null || paymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing package or payment method data'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String imageData;
    if (paymentMethodName == 'wallet'||paymentMethodName == 'Wallet') {
      imageData = 'wallet';
      paymentMethodId=2;
      print(imageData);
    } else {
      if (_invoiceImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload the invoice image first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      imageData = _invoiceImage!.path;
    }

    buyPackageCubit.buyPackage(
      userId: SelectedStudent.studentId,
      packageId: packageId!,
      paymentMethodId: paymentMethodId!,
      image: imageData,
    );
  }

  @override
  void dispose() {
    buyPackageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => buyPackageCubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(title: "Buy Package"),
        body: BlocConsumer<BuyPackageCubit, BuyPackageState>(
          bloc: buyPackageCubit,
          listener: (context, state) {
            if (state is BuyPackageError) {
              print(state.message);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is BuyPackageSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.success),
                  backgroundColor: AppColors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BuyPackageLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    if (paymentMethodName != 'wallet')
                      Column(
                        children: [
                          _invoiceImage == null
                              ? const Text('Please upload the invoice image')
                              : Image.file(_invoiceImage!, height: 200),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon:  Icon(Icons.upload_file,color: AppColors.white,),
                            label:  Text('Upload Invoice Image',style: TextStyle(color: AppColors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Payment method is wallet. No invoice image needed.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (paymentMethodName == 'wallet' ||
                          _invoiceImage != null)
                          ? _confirmPurchase
                          : null,

                      child:  Text('Confirm Purchase',
                        style: TextStyle(color: AppColors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
