import 'package:flutter/material.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';

class DialogUtils {
  static void showLoading({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  message,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext dialogContext) {
    if (Navigator.canPop(dialogContext)) {
      Navigator.pop(dialogContext);
    }
  }

  static void showMessage({
    required BuildContext context,
    required String message,
    String? title,
    String? posActionName,
    Function? posAction,
    String? negActionName,
    Function? negAction,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        List<Widget> actions = [];

        if (posActionName != null) {
          actions.add(
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                posAction?.call();
              },
              child: Text(
                posActionName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
            ),
          );
        }

        if (negActionName != null) {
          actions.add(
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                negAction?.call();
              },
              child: Text(
                negActionName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
            ),
          );
        }

        return AlertDialog(
          content: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
          title: Text(
            title ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
          actions: actions,
        );
      },
    );
  }
}
