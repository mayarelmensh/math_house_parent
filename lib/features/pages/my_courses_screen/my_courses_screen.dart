import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/custom_snack_bar.dart';
import 'package:math_house_parent/data/models/my_course_model.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cuibt/my_courses_cuibt.dart';
import 'cuibt/my_courses_states.dart';




class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  MyCoursesCubit myCoursesCubit=getIt<MyCoursesCubit>();

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
      _fetchCourses();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _fetchCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      if (token.isNotEmpty && userId != 0) {
        myCoursesCubit.fetchMyCourses(userId);
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
            content: Text('No token or user ID found. Please log in.'),
          ),
        );
      }
    } catch (e) {
      showTopSnackBar(context as BuildContext, 'Error loading courses: $e');
    }
  }

  // Future<void> _fetchCourses() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token') ?? '';
  //   final userId = prefs.getInt('user_id') ?? 0;
  //   if (token.isNotEmpty && userId != 0) {
  //     .fetchMyCourses(userId);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No token or user ID found. Please log in.')),
  //     );
  //   }
  // }

  List<Chapter> _filterChapters(List<Chapter> chapters) {
    return chapters.where((chapter) {
      return chapter.chapterName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: BlocBuilder<MyCoursesCubit, MyCoursesState>(
        bloc: myCoursesCubit,
        builder: (context, state) {
          if (state is MyCoursesLoading) {
            return _buildLoadingState();
          } else if (state is MyCoursesError) {
            return _buildErrorState(state.message, _fetchCourses);
          } else if (state is MyCoursesLoaded) {
            final course = state.courses.isNotEmpty ? state.courses[0] : null;
            if (course == null) {
              return _buildEmptyState();
            }
            final filteredChapters = _filterChapters(
              course.chapters.map((c) => Chapter.fromJson(c.toJson())).toList(),
            );
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCoursesHeader(1),
                  Expanded(
                    child: _buildCoursesList(course, filteredChapters),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
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
          hintText: 'Search For Chapters',
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

  Widget _buildCoursesHeader(int courseCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Courses',
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
              '$courseCount Course${courseCount > 1 ? 's' : ''}',
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

  Widget _buildCoursesList(MyCoursesModel course, List<Chapter> filteredChapters) {
    return RefreshIndicator(
      onRefresh: _fetchCourses,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 1,
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
                  curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
                ),
              );
              return Transform.translate(
                offset: Offset(0, 50.h * (1 - delayedAnimation.value.clamp(0.0, 1.0))),
                child: Opacity(
                  opacity: delayedAnimation.value.clamp(0.0, 1.0),
                  child: CourseCard(
                    course: course,
                    chapters: filteredChapters,
                    onTap: () {
                      _navigateToCourseDetails(course);
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
            'Loading Courses',
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
              offset: Offset(0, 2.h),
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
              offset: Offset(0, 2.h),
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
              'No courses available',
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

  void _navigateToCourseDetails(MyCoursesModel course) {
    showModalBottomSheet(
      context: context as BuildContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCourseDetailsBottomSheet(course),
    );
  }

  Widget _buildCourseDetailsBottomSheet(MyCoursesModel course) {
    return Container(
      height: MediaQuery.of(context as BuildContext).size.height * 0.8,
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
                  if (course.image != null)
                    Hero(
                      tag: 'course_image_${course.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          course.image!,
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
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
                  Text(
                    course.courseName,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    course.courseDescription,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Course Chapters',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...course.chapters
                      .map((chapter) => _buildChapterTile(Chapter.fromJson(chapter.toJson())))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterTile(Chapter chapter) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        title: Text(
          chapter.chapterName,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: AppColors.primaryColor,
        ),
        onTap: () {
          // Navigate to chapter details or content
        },
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final MyCoursesModel course;
  final List<Chapter> chapters;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.chapters,
    required this.onTap,
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
          child: widget.course.image?.isNotEmpty == true
              ? Image.network(
            widget.course.image!,
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
                widget.course.courseName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
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
        Text(
          widget.course.courseDescription,
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
      ],
    );
  }

  Widget _buildCourseStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.bookmark_outline,
          text: '${widget.chapters.length} Chapters',
          color: AppColors.primaryColor,
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