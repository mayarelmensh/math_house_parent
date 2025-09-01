import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomSearchFilterBar extends StatefulWidget {
  final VoidCallback? onFilterTap;
  final Function(String)? onSearchChanged;
  final VoidCallback? onClearSearch;
  final String? hintText;
  final TextEditingController? controller;
  final bool showFilter;
  final Icon? icon;

  const CustomSearchFilterBar({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
    this.onClearSearch,
    this.hintText,
    this.controller,
    this.showFilter = true,
    this.icon,
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

    // Use provided controller or create internal one
    if (widget.controller != null) {
      _searchController = widget.controller!;
      _isInternalController = false;
    } else {
      _searchController = TextEditingController();
      _isInternalController = true;
    }

    // Add listener for search changes
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(_searchController.text);
    }
    // Trigger rebuild to show/hide clear button
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    // Only dispose if it's internal controller
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
    // Focus back to search field after clearing
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search, color: AppColors.darkGrey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          // Clear button - only show when there's text
          if (_searchController.text.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
              onPressed: _clearSearch,
              tooltip: 'Clear search',
              splashRadius: 20,
            ),
          ],
          // Filter button - only show if showFilter is true
          if (widget.showFilter) ...[
            Container(
              width: 50,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: widget.onFilterTap,
                tooltip: 'Filter',
                splashRadius: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}