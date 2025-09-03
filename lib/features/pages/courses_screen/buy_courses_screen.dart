import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'package:math_house_parent/domain/entities/courses_response_entity.dart';
import 'package:math_house_parent/domain/entities/payment_methods_response_entity.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:math_house_parent/features/pages/payment_methods/cubit/payment_methods_states.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
import 'cubit/buy_course_cubit.dart';
import 'cubit/buy_course_states.dart';
import 'cubit/buy_chapter_cubit.dart';
import 'cubit/buy_chapter_states.dart';
import 'cubit/courses_cubit.dart';
import 'cubit/courses_states.dart';

class BuyCourseScreen extends StatefulWidget {
  final bool isLiveSession;

  const BuyCourseScreen({super.key, this.isLiveSession = false});

  @override
  State<BuyCourseScreen> createState() => _BuyCourseScreenState();
}

class _BuyCourseScreenState extends State<BuyCourseScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesCubit>().getCoursesList();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CourseEntity> _filterCourses(List<CourseEntity> courses, List<CategoriesEntity> categories) {
    List<CourseEntity> filteredCourses = courses.where((course) {
      return (course.courseName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (course.courseDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    if (_selectedCategoryId != null) {
      final selectedCategory = categories.firstWhere(
            (category) => category.id == _selectedCategoryId,
        orElse: () => CategoriesEntity(),
      );
      if (selectedCategory.course != null) {
        filteredCourses = filteredCourses.where((course) {
          return selectedCategory.course!.any((c) => c.id == course.id);
        }).toList();
      } else {
        filteredCourses = [];
      }
    }

    return filteredCourses;
  }

  List<CourseEntity> _getAllCourses(CoursesResponseEntity coursesResponse) {
    List<CourseEntity> allCourses = [];
    if (coursesResponse.categories != null) {
      for (var category in coursesResponse.categories!) {
        if (category.course != null) {
          allCourses.addAll(category.course!);
        }
      }
    }
    return allCourses;
  }

  void _showPaymentMethodsBottomSheet({
    required CourseEntity course,
    ChaptersEntity? chapter, // Null for course purchase, non-null for chapter purchase
  }) {
    final paymentMethodsCubit = getIt<PaymentMethodsCubit>();
    final buyCourseCubit = getIt<BuyCourseCubit>();
    final buyChapterCubit = getIt<BuyChapterCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: paymentMethodsCubit),
          BlocProvider.value(value: buyCourseCubit),
          BlocProvider.value(value: buyChapterCubit),
        ],
        child: BlocListener<BuyCourseCubit, BuyCourseStates>(
          listener: (context, state) {
            if (state is BuyCourseSuccessState) {
              print('Course purchase successful: ${state.response.course?.courseName}'); // Debug
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course "${state.response.course?.courseName ?? 'Unknown'}" purchased successfully!'),
                  backgroundColor: AppColors.green,
                ),
              );
              Navigator.pop(context); // Close bottom sheet
            } else if (state is BuyCourseErrorState) {
              print('Course purchase error: ${state.error}'); // Debug
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          child: BlocListener<BuyChapterCubit, BuyChapterStates>(
            listener: (context, state) {
              if (state is BuyChapterSuccessState) {
                print('Chapter purchase successful: ${state.model.chapters?.first.chapterName}'); // Debug
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chapter "${state.model.chapters?.first.chapterName ?? 'Unknown'}" purchased successfully!',
                    ),
                    backgroundColor: AppColors.green,
                  ),
                );
                Navigator.pop(context); // Close bottom sheet
              } else if (state is BuyChapterErrorState) {
                print('Chapter purchase error: ${state.error}'); // Debug
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomSheetSetState) {
                dynamic selectedPaymentMethodId = 'Wallet'; // Set Wallet as default
                File? invoiceImage;
                final picker = ImagePicker();

                Future<void> pickImage() async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    bottomSheetSetState(() {
                      invoiceImage = File(pickedFile.path);
                      print('Image selected: ${pickedFile.path}'); // Debug
                    });
                  }
                }

                void confirmPurchase() {
                  if (selectedPaymentMethodId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a payment method'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  String imageData;
                  if (selectedPaymentMethodId == 'Wallet') { // Check for Wallet
                    imageData = 'wallet';
                    print('Wallet payment selected, imageData: $imageData'); // Debug
                  } else {
                    if (invoiceImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please upload the invoice image first'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    imageData = invoiceImage!.path;
                    print('Non-wallet payment, imageData: $imageData'); // Debug
                  }

                  if (chapter == null) {
                    // Course purchase
                    print('Calling buyPackage with: courseId=${course.id}, paymentMethodId=$selectedPaymentMethodId, amount=${course.price?.toDouble() ?? 0.0}, userId=${SelectedStudent.studentId}, duration=${course.allPrices?.isNotEmpty == true ? course.allPrices!.first.duration ?? 30 : 30}, image=$imageData'); // Debug
                    buyCourseCubit.buyPackage(
                      courseId: course.id!,
                      paymentMethodId: selectedPaymentMethodId,
                      amount: course.price?.toDouble() ?? 0.0,
                      userId: SelectedStudent.studentId,
                      duration: course.allPrices?.isNotEmpty == true ? course.allPrices!.first.duration ?? 30 : 30,
                      image: imageData,
                    );
                  } else {
                    // Chapter purchase
                    print('Calling buyChapter with: courseId=${course.id}, paymentMethodId=$selectedPaymentMethodId, amount=${chapter.chapterPrice?.toDouble() ?? 0.0}, userId=${SelectedStudent.studentId}, chapterId=${chapter.id}, duration=${chapter.chapterAllPrices?.isNotEmpty == true ? chapter.chapterAllPrices!.first.duration ?? 30 : 30}, image=$imageData'); // Debug
                    buyChapterCubit.buyChapter(
                      courseId: course.id!,
                      paymentMethodId: selectedPaymentMethodId,
                      amount: chapter.chapterPrice?.toDouble() ?? 0.0,
                      userId: SelectedStudent.studentId,
                      chapterId: chapter.id!,
                      duration: chapter.chapterAllPrices?.isNotEmpty == true ? chapter.chapterAllPrices!.first.duration ?? 30 : 30,
                      image: imageData,
                    );
                  }
                }

                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
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
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Column(
                          children: [
                            Text(
                              chapter == null
                                  ? 'Course: ${course.courseName ?? 'Unknown'}'
                                  : 'Chapter: ${chapter.chapterName ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Price: ${chapter == null ? (course.price ?? 0) : (chapter.chapterPrice ?? 0)} EGP',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.green,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Duration: ${chapter == null ? (course.allPrices?.isNotEmpty == true ? course.allPrices!.first.duration ?? 30 : 30) : (chapter.chapterAllPrices?.isNotEmpty == true ? chapter.chapterAllPrices!.first.duration ?? 30 : 30)} days',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedPaymentMethodId != 'Wallet')
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: Column(
                            children: [
                              invoiceImage == null
                                  ? const Text('Please upload the invoice image')
                                  : Image.file(invoiceImage!, height: 100.h),
                              SizedBox(height: 8.h),
                              ElevatedButton.icon(
                                onPressed: pickImage,
                                icon: Icon(Icons.upload_file, color: AppColors.white),
                                label: Text(
                                  'Upload Invoice Image',
                                  style: TextStyle(color: AppColors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: BlocBuilder<PaymentMethodsCubit, PaymentMethodsStates>(
                          builder: (context, state) {
                            if (state is PaymentMethodsLoadingState) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            } else if (state is PaymentMethodsSuccessState) {
                              final methods = [
                                PaymentMethodEntity(
                                  id: 'Wallet', // Changed to string
                                  payment: 'Wallet',
                                  paymentType: 'Wallet',
                                  description: 'Pay using your wallet balance',
                                  logo: '',
                                ),
                                ...?state.paymentMethodsResponse.paymentMethods,
                              ];
                              return ListView.builder(
                                padding: EdgeInsets.all(16.w),
                                itemCount: methods.length,
                                itemBuilder: (context, index) {
                                  final method = methods[index];
                                  return _buildPaymentMethodCard(
                                    method,
                                    course,
                                    chapter,
                                    buyCourseCubit,
                                    buyChapterCubit,
                                    selectedPaymentMethodId,
                                    bottomSheetSetState,
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'Failed to load payment methods',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.grey[600],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: ElevatedButton(
                          onPressed: (selectedPaymentMethodId != null &&
                              (selectedPaymentMethodId == 'Wallet' || invoiceImage != null))
                              ? confirmPurchase
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          ),
                          child: Text(
                            'Confirm Purchase',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    paymentMethodsCubit.getPaymentMethods(userId: SelectedStudent.studentId);
  }

  Widget _buildPaymentMethodCard(
      PaymentMethodEntity method,
      CourseEntity course,
      ChaptersEntity? chapter,
      BuyCourseCubit buyCourseCubit,
      BuyChapterCubit buyChapterCubit,
      dynamic selectedPaymentMethodId,
      StateSetter bottomSheetSetState,
      ) {
    final isSelected = selectedPaymentMethodId == method.id;
    return GestureDetector(
      onTap: () {
        print('Tapped payment method: ${method.id} - ${method.payment}'); // Debug
        bottomSheetSetState(() {
          selectedPaymentMethodId = method.id;
          if (method.id != 'Wallet') {
            print('Selected non-wallet method, resetting invoice image'); // Debug
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)]
                : [AppColors.white, AppColors.lightGray],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey[300]!,
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
                          color: AppColors.lightGray,
                          child: Icon(
                            Icons.payment,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                          : Container(
                        color: AppColors.lightGray,
                        child: Icon(
                          method.paymentType?.toLowerCase() == 'wallet'
                              ? Icons.account_balance_wallet
                              : Icons.payment,
                          color: AppColors.primary,
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
                            color: isSelected ? AppColors.primary : AppColors.darkGray,
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
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                ],
              ),
            ),
            if (method.description != null && method.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.grey[200]!),
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
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: widget.isLiveSession ? 'Live Sessions' : 'Courses',
      ),
      body: BlocBuilder<CoursesCubit, CoursesStates>(
        builder: (context, state) {
          if (state is CoursesLoadingState) {
            return _buildLoadingState();
          } else if (state is CoursesErrorState) {
            return _buildErrorState(state.error.errorMsg, () {
              context.read<CoursesCubit>().getCoursesList();
            });
          } else if (state is CoursesSuccessState) {
            final allCourses = _getAllCourses(state.coursesResponseEntity);
            if (allCourses.isEmpty) return _buildEmptyState();

            final filteredCourses = _filterCourses(allCourses, state.coursesResponseEntity.categories ?? []);

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryFilter(state.coursesResponseEntity.categories ?? []),
                  _buildCoursesHeader(filteredCourses.length),
                  Expanded(child: _buildCoursesList(filteredCourses)),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search For Courses',
          hintStyle: TextStyle(color: AppColors.grey[500]),
          prefixIcon: Icon(Icons.search, color: AppColors.grey[500]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.grey[500]),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<CategoriesEntity> categories) {
    if (categories.isEmpty) return const SizedBox();
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(null, 'All'),
          ...categories
              .map((category) => _buildCategoryChip(category.id, category.categoryName ?? 'Category'))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int? categoryId, String label) {
    final isSelected = _selectedCategoryId == categoryId;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? AppColors.white : AppColors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.grey[300]!),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategoryId = selected ? categoryId : null;
          });
        },
      ),
    );
  }

  Widget _buildCoursesHeader(int courseCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isLiveSession ? 'Live Sessions' : 'Available Courses',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey[800],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$courseCount Courses',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List<CourseEntity> courses) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CoursesCubit>().getCoursesList();
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delayedAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.2).clamp(0.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
                ),
              );

              return Transform.translate(
                offset: Offset(
                  0,
                  50.h * (1 - delayedAnimation.value.clamp(0.0, 1.0)),
                ),
                child: Opacity(
                  opacity: delayedAnimation.value.clamp(0.0, 1.0),
                  child: CourseCard(
                    course: courses[index],
                    onTap: () {
                      _navigateToCourseDetails(courses[index]);
                    },
                    onBuy: () {
                      _showPaymentMethodsBottomSheet(course: courses[index]);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            widget.isLiveSession ? 'Loading Live Classes...' : 'Loading Courses',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32.r),
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48.r,
                color: AppColors.red,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'An error occurred',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32.r),
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 48.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.isLiveSession ? 'No live sessions available' : 'No courses available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for new courses',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCourseDetails(CourseEntity course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCourseDetailsBottomSheet(course),
    );
  }

  Widget _buildCourseDetailsBottomSheet(CourseEntity course) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.courseImage != null)
                    Hero(
                      tag: 'course_image_${course.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          course.courseImage!,
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 16.h),
                  Text(
                    course.courseName ?? 'Course Name',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (course.courseDescription != null)
                    Text(
                      course.courseDescription!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course Statistics',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _buildDetailChip(
                                'Videos', '${course.videosCount ?? 0}', Icons.video_library, AppColors.red),
                            _buildDetailChip('Chapters', '${course.chaptersCount ?? 0}',
                                Icons.menu_book, AppColors.blue),
                            _buildDetailChip(
                                'Lessons', '${course.lessonsCount ?? 0}', Icons.school, AppColors.green),
                            _buildDetailChip(
                                'Questions', '${course.questionsCount ?? 0}', Icons.quiz, AppColors.orange),
                            _buildDetailChip(
                                'Quizzes', '${course.quizsCount ?? 0}', Icons.assignment, AppColors.purple),
                            _buildDetailChip(
                                'Pdfs', '${course.pdfsCount ?? 0}', Icons.picture_as_pdf, AppColors.yellow),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (course.chapters?.isNotEmpty ?? false) ...[
                    Text(
                      'Course Chapters',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...course.chapters!.map((chapter) => _buildChapterTile(chapter, course)).toList(),
                  ],
                  SizedBox(height: 20.h),
                  if (course.price != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.green.withOpacity(0.1),
                            AppColors.green.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.green),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Course Price',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${course.price} EGP',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          CustomElevatedButton(
                            backgroundColor: AppColors.primaryLight,
                            text: "Buy Course",
                            onPressed: () {
                              _showPaymentMethodsBottomSheet(course: course);
                            },
                            textStyle: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterTile(ChaptersEntity chapter, CourseEntity course) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey[300]!),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        title: Text(
          chapter.chapterName ?? 'Chapter Name',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        subtitle: chapter.chapterPrice != null
            ? Text(
          'Price: ${chapter.chapterPrice} EGP',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.green,
          ),
        )
            : null,
        trailing: chapter.chapterPrice != null
            ? CustomElevatedButton(
          backgroundColor: AppColors.primaryLight,
          text: "Buy Chapter",
          onPressed: () {
            _showPaymentMethodsBottomSheet(course: course, chapter: chapter);
          },
          textStyle: TextStyle(fontSize: 12.sp, color: AppColors.primary),
        )
            : null,
        children: [
          if (chapter.lessons?.isNotEmpty ?? false)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter Lessons:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...chapter.lessons!
                      .map(
                        (lesson) => Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              lesson.lessonName ?? 'Lesson Name',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final VoidCallback onBuy;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onBuy,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: BorderRadius.circular(16.r),
              color: AppColors.white,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseImage(),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildCourseDetails()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseImage() {
    return Hero(
      tag: 'course_image_${widget.course.id}',
      child: Container(
        width: 85.w,
        height: 85.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: widget.course.courseImage?.isNotEmpty == true
              ? Image.network(
            widget.course.courseImage!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2.w,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          )
              : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.school, size: 40.sp, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.course.courseName ?? 'Course Name',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                  height: 1.2.h,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildArrowIcon(),
          ],
        ),
        SizedBox(height: 8.h),
        if (widget.course.courseDescription != null)
          Text(
            widget.course.courseDescription!,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey[600],
              height: 1.4.h,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: 12.h),
        _buildCourseStats(),
        SizedBox(height: 8.h),
        if (widget.course.price != null)
          _buildPriceSection(),
        SizedBox(height: 8.h),
        CustomElevatedButton(
          backgroundColor: AppColors.primaryLight,
          text: "Buy Course",
          onPressed: widget.onBuy,
          textStyle: TextStyle(fontSize: 12.sp, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCourseStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.bookmark_outline,
          text: '${widget.course.chaptersCount ?? 0} Chapters',
          color: AppColors.primary,
        ),
        SizedBox(width: 4.w),
        _buildStatItem(
          icon: Icons.play_circle_outline,
          text: '${widget.course.lessonsCount ?? 0} Lessons',
          color: AppColors.grey[600]!,
        ),
        SizedBox(width: 4.w),
        _buildStatItem(
          icon: Icons.video_library,
          text: '${widget.course.videosCount ?? 0} Videos',
          color: AppColors.blue,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 1.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            size: 16.sp,
            color: AppColors.green,
          ),
          SizedBox(width: 4.w),
          Text(
            '${widget.course.price} EGP',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: AppColors.primary,
      ),
    );
  }
}