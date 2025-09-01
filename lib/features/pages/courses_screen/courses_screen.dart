import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/domain/entities/courses_response_entity.dart';
import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
import '../../../core/utils/app_colors.dart';
import 'cubit/courses_cubit.dart';
import 'cubit/courses_states.dart';

class CoursesScreen extends StatefulWidget {
  final bool isLiveSession;

  const CoursesScreen({super.key, this.isLiveSession = false});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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

  List<CourseEntity> _filterCourses(List<CourseEntity> courses) {
    if (_searchQuery.isEmpty) return courses;
    return courses.where((course) {
      return (course.courseName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (course.courseDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
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

            final filteredCourses = _filterCourses(allCourses);

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildSearchBar(),
                  if (state.coursesResponseEntity.paymentMethods?.isNotEmpty ?? false)
                    _buildPaymentMethodsSection(state.coursesResponseEntity.paymentMethods!),
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

  Widget _buildPaymentMethodsSection(List<PaymentMethodsEntity> paymentMethods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Available Payment Methods ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: paymentMethods.length,
            itemBuilder: (context, index) {
              final paymentMethod = paymentMethods[index];
              return Container(
                width: 100.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (paymentMethod.logoLink != null)
                      Image.network(
                        paymentMethod.logoLink!,
                        height: 32.h,
                        width: 32.w,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.payment, size: 32.sp, color: AppColors.primaryColor),
                      )
                    else
                      Icon(Icons.payment, size: 32.sp, color: AppColors.primaryColor),
                    SizedBox(height: 4.h),
                    Text(
                      paymentMethod.payment ?? '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
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
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$courseCount  Courses',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
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
      color: AppColors.primaryColor,
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
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            widget.isLiveSession
                ? 'Loading Live Classes...'
                : 'Loading Courses',
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
              '"An error occurred',
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
                backgroundColor: AppColors.primaryColor,
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
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 48.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.isLiveSession
                  ? 'No live sessions available'
                  : 'No courses available',
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
          // Handle bar
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
                  // Course Image
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48.sp,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // Course Name
                  Text(
                    course.courseName ?? 'course name',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Course Description
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

                  // Course Statistics
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
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _buildDetailChip('Videos', '${course.videosCount ?? 0}', Icons.video_library, AppColors.red),
                            _buildDetailChip('chapters', '${course.chaptersCount ?? 0}', Icons.menu_book, AppColors.blue),
                            _buildDetailChip('lessons', '${course.lessonsCount ?? 0}', Icons.school, AppColors.green),
                            _buildDetailChip('Questions', '${course.questionsCount ?? 0}', Icons.quiz, AppColors.orange),
                            _buildDetailChip('Quizzes', '${course.quizsCount ?? 0}', Icons.assignment, AppColors.purple),
                            _buildDetailChip('Pdfs', '${course.pdfsCount ?? 0}', Icons.picture_as_pdf, AppColors.yellow),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Chapters
                  if (course.chapters?.isNotEmpty ?? false) ...[
                    Text(
                      'Course Chapters',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...course.chapters!.map((chapter) =>
                        _buildChapterTile(chapter)
                    ).toList(),
                  ],

                  SizedBox(height: 20.h),

                  // Price Section
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
                            'course price',
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

  Widget _buildChapterTile(ChaptersEntity chapter) {
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
          chapter.chapterName ?? 'lesson Name',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        subtitle: chapter.chapterPrice != null
            ? Text(
          'The:  ${chapter.chapterPrice}  EGP',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.grey[600],
          ),
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
                    'Chapter Lessons: ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...chapter.lessons!.map((lesson) =>
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                lesson.lessonName ?? 'lesson name',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ).toList(),
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

  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
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
                    color: AppColors.primaryColor,
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
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.school, size: 40.sp, color: AppColors.primaryColor),
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
                widget.course.courseName ?? ' course name',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
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
         backgroundColor: AppColors.lightGray,
           text: "Buy Course", onPressed: (){
             Navigator.pushNamed(context, AppRoutes.packagesScreen);
       },
           textStyle: TextStyle(fontSize: 12.sp,color:AppColors.primaryColor))
      ],
    );
  }

  Widget _buildCourseStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.bookmark_outline,
          text: '${widget.course.chaptersCount ?? 0} Chapters ',
          color: AppColors.primaryColor,
        ),
        SizedBox(width: 4.w),
        _buildStatItem(
          icon: Icons.play_circle_outline,
          text: '${widget.course.lessonsCount ?? 0} lessons',
          color: AppColors.grey[600]!,
        ),
        SizedBox(width: 4.w),
        _buildStatItem(
          icon: Icons.video_library,
          text: '${widget.course.videosCount ?? 0} videos',
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
          maxLines: 1,
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
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
            '${widget.course.price}  EGP',
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
        color: AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: AppColors.primaryColor,
      ),
    );
  }
}