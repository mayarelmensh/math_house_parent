// إضافة المتغيرات في أعلى الكلاس
import 'dart:convert';
import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent/core/utils/custom_snack_bar.dart';

import '../utils/app_colors.dart';

class PickerImage extends State<StatefulWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? imageBytes; // لعرض الصورة
  String? base64String; // للإرسال للـ API
  String? selectedPaymentMethodId;

  // باقي المتغيرات...

  // الميثود المحدثة لاختيار الصورة
  Future<void> pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
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
          imageBytes = Uint8List.fromList(imageFileBytes); // للعرض
          base64String = imageBase64; // للـ API
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment proof uploaded successfully'),
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
      showTopSnackBar(context, 'Error selecting image: ${e.toString()}',AppColors.primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
