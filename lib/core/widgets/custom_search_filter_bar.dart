import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

class CustomSearchFilterBar extends StatefulWidget {
  final VoidCallback? onFilterTap;
  final Function(String)? onSearchChanged;
  final VoidCallback? onClearSearch;
  final String? hintText;
  final TextEditingController? controller;
  final bool showFilter;
  final Icon? prefixIcon;
  final double? fontSize;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;
  final TextStyle? hintStyle;

  const CustomSearchFilterBar({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
    this.onClearSearch,
    this.hintText,
    this.controller,
    this.showFilter = true,
    this.prefixIcon,
    this.fontSize,
    this.contentPadding,
    this.borderRadius,
    this.hintStyle,
  });

  @override
  State<CustomSearchFilterBar> createState() => _CustomSearchFilterBarState();
}

class _CustomSearchFilterBarState extends State<CustomSearchFilterBar> {
  late TextEditingController _searchController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _searchController = widget.controller!;
      _isInternalController = false;
    } else {
      _searchController = TextEditingController();
      _isInternalController = true;
    }
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(_searchController.text);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    if (_isInternalController) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    if (widget.onClearSearch != null) {
      widget.onClearSearch!();
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.primaryColor, width: 1.w),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          widget.prefixIcon ??
              Icon(
                Icons.search,
                color: AppColors.grey[700],
                size: 20.sp,
              ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle: widget.hintStyle ??
                    TextStyle(
                      color: AppColors.grey[700],
                      fontSize: widget.fontSize ?? 16.sp,
                    ),
                border: InputBorder.none,
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(horizontal: 0, vertical: 12.h),
              ),
              style: TextStyle(
                fontSize: widget.fontSize ?? 16.sp,
                color: AppColors.black,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            IconButton(
              icon: Icon(Icons.clear, color: AppColors.grey[500], size: 20.sp),
              onPressed: _clearSearch,
              tooltip: 'Clear search',
              splashRadius: 20.r,
            ),
          ],
          if (widget.showFilter) ...[
            Container(
              width: 48.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.filter_list, color: AppColors.white, size: 20.sp),
                onPressed: widget.onFilterTap,
                tooltip: 'Filter',
                splashRadius: 20.r,
              ),
            ),
          ],
        ],
      ),
    );
  }
}