// widgets/promo_code_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_colors.dart';
import '../../../data/models/promo_code_model.dart';
import 'cubit/promo_code_cubit.dart';
import 'cubit/promo_code_states.dart';

class PromoCodeWidget extends StatefulWidget {
  final int courseId;
  final int userId;
  final double originalPrice;
  final Function(PromoCodeResponse) onPromoApplied;
  final Function()? onPromoRemoved;

  const PromoCodeWidget({
    super.key,
    required this.courseId,
    required this.userId,
    required this.originalPrice,
    required this.onPromoApplied,
    this.onPromoRemoved,
  });

  @override
  State<PromoCodeWidget> createState() => _PromoCodeWidgetState();
}

class _PromoCodeWidgetState extends State<PromoCodeWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promoController = TextEditingController();
  final FocusNode _promoFocusNode = FocusNode();
  bool _isExpanded = false;
  PromoCodeResponse? _appliedPromo;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool get isTablet => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _promoController.dispose();
    _promoFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _promoFocusNode.requestFocus();
      });
    } else {
      _animationController.reverse();
      _promoFocusNode.unfocus();
    }
  }

  void _applyPromoCode() {
    // تصحيح الخطأ: نحتاج نحصل على القيمة من الـ TextField
    if (_promoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final int? promoCode = int.tryParse(_promoController.text);
    if (promoCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid numeric promo code'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    context.read<PromoCodeCubit>().applyPromoCode(
      promoCode: promoCode,
      courseId: widget.courseId,
      userId: widget.userId,
      originalAmount: widget.originalPrice,
    );
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromo = null;
      _promoController.clear();
    });
    if (widget.onPromoRemoved != null) {
      widget.onPromoRemoved!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PromoCodeCubit, PromoCodeStates>(
      listener: (context, state) {
        if (state is PromoCodeSuccessState) {
          setState(() {
            _appliedPromo = state.response;
          });
          widget.onPromoApplied(state.response);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Promo code applied successfully!'),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state is PromoCodeErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey[200]!),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: _toggleExpansion,
              child: Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: _appliedPromo != null ? AppColors.green : AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Promo Code',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: _appliedPromo != null ? AppColors.green : AppColors.primary,
                      ),
                    ),
                    Spacer(),
                    if (_appliedPromo != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Applied',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(width: 8.w),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Content
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  children: [
                    // Input and Apply Button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            focusNode: _promoFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter promo code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 12.h),
                              suffixIcon: _promoController.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear, size: 18.sp),
                                onPressed: () {
                                  _promoController.clear();
                                  setState(() {});
                                },
                              )
                                  : null,
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        BlocBuilder<PromoCodeCubit, PromoCodeStates>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: (state is PromoCodeLoadingState ||
                                  _promoController.text.isEmpty)
                                  ? null
                                  : _applyPromoCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                              child: state is PromoCodeLoadingState
                                  ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                'Apply',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Applied Promo Display
                    if (_appliedPromo != null && _appliedPromo!.newPrice != null) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.green, size: 16.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'You save ${(widget.originalPrice - _appliedPromo!.newPrice!).toStringAsFixed(0)} EGP',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _removePromoCode,
                              icon: Icon(Icons.close, size: 16.sp, color: AppColors.red),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}