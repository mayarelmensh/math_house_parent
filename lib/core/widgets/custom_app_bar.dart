import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onAddPressed;
  final bool showAddIcon;
  final bool showArrowBack;
  final List<Widget>? actions;


  const CustomAppBar({
    super.key,
    required this.title,
    this.onAddPressed,
    this.showAddIcon = false,
    this.actions,
    this.showArrowBack=true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 0,
      leading:   showArrowBack?  Padding(
        padding: const EdgeInsets.only(left: 12),
        child: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: IconButton(
            icon:  Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ):
          SizedBox(),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
      actions: _buildActions(),
    );
  }

  List<Widget>? _buildActions() {
    List<Widget> actionsList = [];

    // Add custom actions first
    if (actions != null) {
      actionsList.addAll(actions!);
    }

    // Add the add icon if needed
    if (showAddIcon) {
      actionsList.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: onAddPressed,
            ),
          ),
        ),
      );
    }

    return actionsList.isEmpty ? null : actionsList;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}