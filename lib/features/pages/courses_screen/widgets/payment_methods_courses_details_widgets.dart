// // Payment Methods Bottom Sheet
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' hide Uint8List;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/di.dart';
// import '../../../../core/utils/app_colors.dart';
// import '../../../../core/utils/custom_snack_bar.dart';
// import '../../../../data/models/buy_cource_model.dart';
// import '../../../../data/models/promo_code_model.dart';
// import '../../../../data/models/student_selected.dart';
// import '../../../../domain/entities/courses_response_entity.dart' hide CourseEntity;
// import '../../payment_methods/cubit/payment_methods_cubit.dart';
// import '../../promo_code_screen/cubit/promo_code_cubit.dart';
// import '../../promo_code_screen/cubit/promo_code_states.dart';
// import '../cubit/buy_chapter_cubit.dart';
// import '../cubit/buy_chapter_states.dart';
// import '../cubit/buy_course_cubit.dart';
// import '../cubit/buy_course_states.dart';
//
// class PaymentMethodsBottomSheet extends StatefulWidget {
//   final CourseEntity course;
//   final ChaptersEntity? chapter;
//   final bool isTablet;
//   final bool isDesktop;
//   final Uint8List? imageBytes;
//   final String? base64String;
//   final Function(Uint8List?, String?) onImagePicked;
//   final VoidCallback onImageCleared;
//
//   const PaymentMethodsBottomSheet({
//     super.key,
//     required this.course,
//     this.chapter,
//     required this.isTablet,
//     required this.isDesktop,
//     required this.imageBytes,
//     required this.base64String,
//     required this.onImagePicked,
//     required this.onImageCleared,
//   });
//
//   @override
//   State<PaymentMethodsBottomSheet> createState() => _PaymentMethodsBottomSheetState();
// }
//
// class _PaymentMethodsBottomSheetState extends State<PaymentMethodsBottomSheet> {
//   final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
//   final buyCourseCubit = getIt<BuyCourseCubit>();
//   final buyChapterCubit = getIt<BuyChapterCubit>();
//   final promoCodeCubit = getIt<PromoCodeCubit>();
//
//   dynamic selectedPaymentMethodId = 'Wallet';
//   PromoCodeResponse? appliedPromo;
//   final TextEditingController promoController = TextEditingController();
//   bool isPromoExpanded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: paymentMethodsCubit),
//         BlocProvider.value(value: buyCourseCubit),
//         BlocProvider.value(value: buyChapterCubit),
//         BlocProvider.value(value: promoCodeCubit),
//       ],
//       child: MultiBlocListener(
//         listeners: [
//           BlocListener<BuyCourseCubit, BuyCourseStates>(
//             listener: (context, state) {
//               if (state is BuyCourseSuccessState) {
//                 showTopSnackBar(
//                   context,
//                   'Course "${state.response.course?.courseName ?? 'Unknown'}" purchased successfully!',
//                   AppColors.green,
//                 );
//                 Navigator.pop(context);
//               } else if (state is BuyCourseErrorState) {
//                 showTopSnackBar(
//                   context,
//                   'Please Check the balance of wallet or select invalid payment method',
//                   AppColors.primaryColor,
//                 );
//               }
//             },
//           ),
//           BlocListener<BuyChapterCubit, BuyChapterStates>(
//             listener: (context, state) {
//               if (state is BuyChapterSuccessState) {
//                 showTopSnackBar(
//                   context,
//                   'Chapter "${state.model.chapters?.first.chapterName ?? 'Unknown'}" purchased successfully!',
//                   AppColors.green,
//                 );
//                 Navigator.pop(context);
//               } else if (state is BuyChapterErrorState) {
//                 showTopSnackBar(
//                   context,
//                   "Please Check the balance of wallet or select invalid payment method",
//                   AppColors.primaryColor,
//                 );
//               }
//             },
//           ),
//           BlocListener<PromoCodeCubit, PromoCodeStates>(
//             listener: (context, state) {
//               if (state is PromoCodeSuccessState) {
//                 setState(() {
//                   appliedPromo = state.response;
//                 });
//                 showTopSnackBar(
//                   context,
//                   'Promo code applied successfully!',
//                   AppColors.green,
//                 );
//               } else if (state is PromoCodeErrorState) {
//                 showTopSnackBar(context, state.error, AppColors.red);
//               }
//             },
//           ),
//         ],
//         child: Container(
//           height: MediaQuery.of(context).size.height * (widget.isTablet ? 0.85 : 0.8),
//           width: widget.isDesktop ? 600 : double.infinity,
//           child: Material(
//             color: AppColors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20.r),
//               topRight: Radius.circular(20.r),
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Column(
//               children: [
//                 PaymentBottomSheetHandle(),
//                 PaymentBottomSheetHeader(),
//                 PaymentDetailsSection(
//                   course: widget.course,
//                   chapter: widget.chapter,
//                   appliedPromo: appliedPromo,
//                   promoController: promoController,
//                   isPromoExpanded: isPromoExpanded,
//                   isTablet: widget.isTablet,
//                   onPromoToggle: () {
//                     setState(() {
//                       isPromoExpanded = !isPromoExpanded;
//                     });
//                   },
//                   onPromoApply: _applyPromoCode,
//                   onPromoRemove: () {
//                     setState(() {
//                       appliedPromo = null;
//                       promoController.clear();
//                       promoCodeCubit.resetState();
//                     });
//                   },
//                 ),
//                 if (selectedPaymentMethodId != 'Wallet')
//                   ImageUploadSection(
//                     imageBytes: widget.imageBytes,
//                     onImageUpload: _showImageSourceBottomSheet,
//                     onImageRemove: widget.onImageCleared,
//                     isTablet: widget.isTablet,
//                   ),
//                 Expanded(
//                   child: PaymentMethodsList(
//                     selectedPaymentMethodId: selectedPaymentMethodId,
//                     onPaymentMethodSelected: (id) {
//                       setState(() {
//                         selectedPaymentMethodId = id;
//                       });
//                     },
//                     isTablet: widget.isTablet,
//                   ),
//                 ),
//                 PaymentConfirmButton(
//                   isEnabled: selectedPaymentMethodId != null &&
//                       (selectedPaymentMethodId == 'Wallet' || widget.base64String != null),
//                   onConfirm: _confirmPurchase,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _applyPromoCode() {
//     if (promoController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a promo code'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     final promoCode = int.tryParse(promoController.text);
//     if (promoCode == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid promo code'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     promoCodeCubit.applyPromoCode(
//       promoCode: promoCode,
//       courseId: widget.course.id!,
//       userId: SelectedStudent.studentId,
//       originalAmount: widget.chapter == null
//           ? (widget.course.price?.toDouble() ?? 0.0)
//           : (widget.chapter!.chapterPrice?.toDouble() ?? 0.0),
//     );
//   }
//
//   void _confirmPurchase() async {
//     if (selectedPaymentMethodId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a payment method'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//
//     String imageData;
//     if (selectedPaymentMethodId == 'Wallet') {
//       imageData = 'wallet';
//     } else {
//       if (widget.base64String == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please upload the invoice image'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       imageData = 'data:image/jpeg;base64,${widget.base64String}';
//     }
//
//     // Calculate final price with promo code discount
//     double originalPrice = widget.chapter == null
//         ? (widget.course.price?.toDouble() ?? 0.0)
//         : (widget.chapter!.chapterPrice?.toDouble() ?? 0.0);
//
//     double finalPrice = originalPrice;
//     if (appliedPromo != null && appliedPromo!.discountAmount != null) {
//       finalPrice = originalPrice - appliedPromo!.discountAmount!;
//       // Ensure final price is not negative
//       if (finalPrice < 0) finalPrice = 0;
//     }
//
//     try {
//       if (widget.chapter == null) {
//         await buyCourseCubit.buyPackage(
//           courseId: widget.course.id!,
//           paymentMethodId: selectedPaymentMethodId!,
//           amount: finalPrice,
//           userId: SelectedStudent.studentId,
//           duration: widget.course.allPrices?.isNotEmpty == true
//               ? widget.course.allPrices!.first.duration ?? 30
//               : 30,
//           image: imageData,
//           promoCode: appliedPromo?.promoCode,
//         );
//       } else {
//         await buyChapterCubit.buyChapter(
//           courseId: widget.course.id!,
//           paymentMethodId: selectedPaymentMethodId!,
//           amount: finalPrice,
//           userId: SelectedStudent.studentId,
//           chapterId: widget.chapter!.id!,
//           duration: widget.chapter!.chapterAllPrices?.isNotEmpty == true
//               ? widget.chapter!.chapterAllPrices!.first.duration ?? 30
//               : 30,
//           image: imageData,
//         );
//       }
//
//       showTopSnackBar(
//         context,
//         'Purchase confirmed successfully!',
//         AppColors.green,
//       );
//     } catch (e) {
//       showTopSnackBar(
//         context,
//         'Error confirming purchase: ${e.toString()}',
//         AppColors.primaryColor,
//       );
//     }
//   }
//
//   void _showImageSourceBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => ImageSourceBottomSheet(
//         isTablet: widget.isTablet,
//         onImagePicked: (bytes, base64) {
//           widget.onImagePicked(bytes, base64);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }
//
// // Payment Bottom Sheet Handle
// class PaymentBottomSheetHandle extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40.w,
//       height: 4.h,
//       margin: EdgeInsets.only(top: 12.h),
//       decoration: BoxDecoration(
//         color: AppColors.grey[300],
//         borderRadius: BorderRadius.circular(2.r),
//       ),
//     );
//   }
// }
//
// // Payment Bottom Sheet Header
// class PaymentBottomSheetHeader extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;
//
//     return Padding(
//       padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
//       child: Text(
//         'Select Payment Method',
//         style: TextStyle(
//           fontSize: isTablet ? 20.sp : 18.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.primary,
//         ),
//       ),
//     );
//   }
// }
//
// // Payment Details Section
// class PaymentDetailsSection extends StatelessWidget {
//   final CourseEntity course;
//   final ChaptersEntity? chapter;
//   final PromoCodeResponse? appliedPromo;
//   final TextEditingController promoController;
//   final bool isPromoExpanded;
//   final bool isTablet;
//   final VoidCallback onPromoToggle;
//   final VoidCallback onPromoApply;
//   final VoidCallback onPromoRemove;
//
//   const PaymentDetailsSection({
//     super.key,
//     required this.course,
//     this.chapter,
//     required this.appliedPromo,
//     required this.promoController,
//     required this.isPromoExpanded,
//     required this.isTablet,
//     required this.onPromoToggle,
//     required this.onPromoApply,
//     required this.onPromoRemove,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Calculate prices
//     double originalPrice = chapter == null
//         ? (course.price?.toDouble() ?? 0.0)
//         : (chapter!.chapterPrice?.toDouble() ?? 0.0);
//
//     double finalPrice = originalPrice;
//     if (appliedPromo != null && appliedPromo!.discountAmount != null) {
//       finalPrice = originalPrice - appliedPromo!.discountAmount!;
//       if (finalPrice < 0) finalPrice = 0;
//     }
//
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isTablet ? 20.w : 16.w,
//         vertical: 8.h,
//       ),
//       child: Column(
//         children: [
//           Text(
//             chapter == null
//                 ? 'Course: ${course.courseName ?? 'Unknown'}'
//                 : 'Chapter: ${chapter!.chapterName ?? 'Unknown'}',
//             style: TextStyle(
//               fontSize: isTablet ? 18.sp : 16.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColors.grey[800],
//             ),
//           ),
//           SizedBox(height: 8.h),
//
//           // Promo Code Section - Only for Courses, not Chapters
//           if (chapter == null)
//             PromoCodeSection(
//               promoController: promoController,
//               appliedPromo: appliedPromo,
//               isPromoExpanded: isPromoExpanded,
//               onPromoToggle: onPromoToggle,
//               onPromoApply: onPromoApply,
//               onPromoRemove: onPromoRemove,
//             ),
//
//           SizedBox(height: 12.h),
//
//           // Price Display
//           PriceDisplayWidget(
//             originalPrice: originalPrice,
//             finalPrice: finalPrice,
//             appliedPromo: appliedPromo,
//           ),
//
//           SizedBox(height: 8.h),
//           Text(
//             'Duration: ${chapter == null ? (course.allPrices?.isNotEmpty == true ? course.allPrices!.first.duration ?? 30 : 30) : (chapter!.chapterAllPrices?.isNotEmpty == true ? chapter!.chapterAllPrices!.first.duration ?? 30 : 30)} days',
//             style: TextStyle(
//               fontSize: isTablet ? 16.sp : 16.sp,
//               color: AppColors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Promo Code Section
// class PromoCodeSection extends StatelessWidget {
//   final TextEditingController promoController;
//   final PromoCodeResponse? appliedPromo;
//   final bool isPromoExpanded;
//   final VoidCallback onPromoToggle;
//   final VoidCallback onPromoApply;
//   final VoidCallback onPromoRemove;
//
//   const PromoCodeSection({
//     super.key,
//     required this.promoController,
//     required this.appliedPromo,
//     required this.isPromoExpanded,
//     required this.onPromoToggle,
//     required this.onPromoApply,
//     required this.onPromoRemove,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PromoCodeCubit, PromoCodeStates>(
//       builder: (context, promoState) {
//         return Container(
//           decoration: BoxDecoration(
//             color: AppColors.grey[50],
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.grey[200]!,
//             ),
//           ),
//           child: Column(
//             children: [
//               InkWell(
//                 onTap: onPromoToggle,
//                 child: Container(
//                   padding: EdgeInsets.all(16.w),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.local_offer,
//                         color: AppColors.primary,
//                         size: 20.sp,
//                       ),
//                       SizedBox(width: 12.w),
//                       Text(
//                         'Promo Code',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       Spacer(),
//                       if (appliedPromo != null)
//                         Text(
//                           'Applied',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: AppColors.green,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       SizedBox(width: 8.w),
//                       Icon(
//                         isPromoExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: AppColors.grey[600],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (isPromoExpanded)
//                 Container(
//                   padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: promoController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: 'Enter promo code',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.r),
//                                   borderSide: BorderSide(
//                                     color: AppColors.grey[300]!,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.r),
//                                   borderSide: BorderSide(
//                                     color: AppColors.primary,
//                                   ),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 12.w,
//                                   vertical: 12.h,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           ElevatedButton(
//                             onPressed: promoState is PromoCodeLoadingState
//                                 ? null
//                                 : onPromoApply,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 16.w,
//                                 vertical: 12.h,
//                               ),
//                             ),
//                             child: promoState is PromoCodeLoadingState
//                                 ? SizedBox(
//                               width: 20.w,
//                               height: 20.h,
//                               child: CircularProgressIndicator(
//                                 color: AppColors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                                 : Text(
//                               'Apply',
//                               style: TextStyle(
//                                 color: AppColors.white,
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (appliedPromo != null) ...[
//                         SizedBox(height: 12.h),
//                         Container(
//                           padding: EdgeInsets.all(12.w),
//                           decoration: BoxDecoration(
//                             color: AppColors.green.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8.r),
//                             border: Border.all(
//                               color: AppColors.green.withOpacity(0.3),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Discount:',
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: AppColors.grey[700],
//                                     ),
//                                   ),
//                                   Text(
//                                     '-${appliedPromo!.discountAmount?.toStringAsFixed(2) ?? '0'} EGP',
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: AppColors.green,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       appliedPromo!.message ??
//                                           'Promo code applied successfully',
//                                       style: TextStyle(
//                                         fontSize: 12.sp,
//                                         color: AppColors.green,
//                                       ),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: onPromoRemove,
//                                     icon: Icon(
//                                       Icons.close,
//                                       size: 18.sp,
//                                       color: AppColors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // Price Display Widget
// class PriceDisplayWidget extends StatelessWidget {
//   final double originalPrice;
//   final double finalPrice;
//   final PromoCodeResponse? appliedPromo;
//
//   const PriceDisplayWidget({
//     super.key,
//     required this.originalPrice,
//     required this.finalPrice,
//     required this.appliedPromo,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary.withOpacity(0.1),
//             AppColors.primary.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: AppColors.primary.withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         children: [
//           if (appliedPromo != null) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Original Price:',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: AppColors.grey[600],
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//                 Text(
//                   '${originalPrice.toStringAsFixed(2)} EGP',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: AppColors.grey[600],
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.h),
//           ],
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Final Price:',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.grey[800],
//                 ),
//               ),
//               Text(
//                 '${finalPrice.toStringAsFixed(2)} EGP',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: appliedPromo != null
//                       ? AppColors.green
//                       : AppColors.primary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Image Upload Section
// class ImageUploadSection extends StatelessWidget {
//   final Uint8List? imageBytes;
//   final VoidCallback onImageUpload;
//   final VoidCallback onImageRemove;
//   final bool isTablet;
//
//   const ImageUploadSection({
//     super.key,
//     required this.imageBytes,
//     required this.onImageUpload,
//     required this.onImageRemove,
//     required this.isTablet,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isTablet ? 20.w : 16.w,
//         vertical: 8.h,
//       ),
//       child: Column(
//         children: [
//           if (imageBytes != null)
//             Container(
//               width: double.infinity,
//               height: isTablet ? 180 : 150,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.r),
//                 color: Colors.grey[200],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: Image.memory(
//                   imageBytes!,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             )
//           else
//             Container(
//               width: double.infinity,
//               height: isTablet ? 180 : 150,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.r),
//                 color: Colors.grey[200],
//               ),
//               child: Icon(
//                 Icons.image,
//                 size: isTablet ? 50.sp : 40.sp,
//               ),
//             ),
//           SizedBox(height: 8.h),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: onImageUpload,
//                   icon: Icon(
//                     Icons.upload_file,
//                     color: AppColors.white,
//                   ),
//                   label: Text(
//                     'Upload Invoice Image',
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: isTablet ? 16.sp : 14.sp,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isTablet ? 28.w : 24.w,
//                       vertical: isTablet ? 16.h : 12.h,
//                     ),
//                   ),
//                 ),
//               ),
//               if (imageBytes != null) ...[
//                 SizedBox(width: 8.w),
//                 IconButton(
//                   onPressed: onImageRemove,
//                   icon: Icon(
//                     Icons.delete,
//                     color: Colors.red,
//                     size: isTablet ? 28.sp : 24.sp,
//                   ),
//                   style: IconButton.styleFrom(
//                     backgroundColor: Colors.red.withOpacity(0.1),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }