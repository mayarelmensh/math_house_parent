import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();

  /// ترجع String Base64 للصورة المختارة أو null لو المستخدم ألغى
  Future<String?> pickImageAsBase64(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        // المستخدم ألغى الاختيار
        return null;
      }

      final File file = File(pickedFile.path);

      // تحقق من وجود الملف
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected file does not exist')),
        );
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      // إرجاع Base64 string
      return base64Image;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
      return null;
    }
  }
}

