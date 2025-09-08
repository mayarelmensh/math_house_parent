import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import '../../../core/utils/app_colors.dart';
import '../../../data/models/score_sheet_model.dart';
import 'cubit/get_courses_for_score_sheet_cubit.dart';
import 'cubit/get_courses_for_score_sheet_states.dart';
import 'cubit/score_sheet_cubit.dart';
import 'cubit/score_sheet_states.dart';

class ScoreSheetScreen extends StatefulWidget {
  const ScoreSheetScreen({Key? key}) : super(key: key);

  @override
  State<ScoreSheetScreen> createState() => _ScoreSheetScreenState();
}

class _ScoreSheetScreenState extends State<ScoreSheetScreen> with SingleTickerProviderStateMixin {
  final CoursesForScoreSheetCubit coursesForScoreSheetCubit = getIt<CoursesForScoreSheetCubit>();
  final ScoreSheetCubit scoreSheetCubit = getIt<ScoreSheetCubit>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    coursesForScoreSheetCubit.fetchCourses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => coursesForScoreSheetCubit),
        BlocProvider(create: (context) => scoreSheetCubit),
      ],
      child: Scaffold(
        appBar:CustomAppBar(title: "Score Sheets"),
        body: BlocBuilder<CoursesForScoreSheetCubit, CoursesForScoreSheetState>(
          bloc: coursesForScoreSheetCubit,
          builder: (context, coursesState) {
            print('Courses state: $coursesState');
            if (coursesState is CoursesForScoreSheetLoadingState) {
              return  Center(child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ));
            } else if (coursesState is CoursesForScoreSheetErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coursesState.message,
                      style: TextStyle(color: AppColors.red),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => coursesForScoreSheetCubit.fetchCourses(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (coursesState is CoursesForScoreSheetSuccessState) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Dropdown for Courses
                    Container(
                      margin: EdgeInsets.all(20.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.grey, width: 1.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: DropdownButton<int>(
                        hint: Text(
                          'Select Course',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        value: coursesState.selectedCourse?.id,
                        isExpanded: true,
                        underline: SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                          size: 24.sp,
                        ),
                        items: coursesState.courses
                            .map(
                              (course) => DropdownMenuItem(
                            value: course.id,
                            child: Text(
                              course.courseName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final selectedCourse = coursesState.courses
                                .firstWhere((course) => course.id == value);
                            coursesForScoreSheetCubit.selectCourse(selectedCourse);
                            scoreSheetCubit.fetchScoreSheet(value);
                          }
                        },
                      ),
                    ),
                    // Score Sheet Section
                    Expanded(
                      child: BlocBuilder<ScoreSheetCubit, ScoreSheetState>(
                        bloc: scoreSheetCubit,
                        builder: (context, scoreSheetState) {
                          print('Score sheet state: $scoreSheetState');
                          if (scoreSheetState is ScoreSheetLoadingState) {
                            return  Center(child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ));
                          } else if (scoreSheetState is ScoreSheetErrorState) {
                            return Center(
                              child: Text(
                                scoreSheetState.message,
                                style: TextStyle(color: AppColors.red),
                              ),
                            );
                          } else if (scoreSheetState is ScoreSheetSuccessState) {
                            final scoreSheet = scoreSheetState.scoreSheet;
                            if (scoreSheet.chapters.isEmpty) {
                              return const Center(child: Text('No score sheets available'));
                            }
                            return _buildScoreSheetContent(scoreSheet);
                          }
                          return const Center(child: Text('Select a course to view score sheet'));
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to initialize. Please try again.'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => coursesForScoreSheetCubit.fetchCourses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreSheetContent(ScoreSheetResponseModel scoreSheet) {
    return Container(
      color: AppColors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: scoreSheet.chapters.length,
        itemBuilder: (context, index) {
          return _buildChapterSection(scoreSheet.chapters[index]);
        },
      ),
    );
  }

  Widget _buildChapterSection(Chapter chapter) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.notAttendColor.withOpacity(0.5),
                  AppColors.primaryColor,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Text(
              chapter.chapterName,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
          ...chapter.lessons.map((lesson) => _buildLessonItem(lesson)).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonItem(Lesson lesson) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: lesson.liveAttend == "Attend"
                      ? AppColors.blue.withOpacity(0.1)
                      : AppColors.notAttendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  lesson.liveAttend,
                  style: TextStyle(
                    color: lesson.liveAttend == "Attend"
                        ? AppColors.blue
                        : AppColors.notAttendColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.quiz, color: AppColors.darkGrey, size: 20.sp),
              SizedBox(width: 4.w),
              Text(
                '${lesson.quizzes.length} Quiz${lesson.quizzes.length > 1 ? "es" : ""}',
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            lesson.lessonName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              height: 1.4.h,
            ),
          ),
          SizedBox(height: 12.h),
          ...lesson.quizzes.map((quiz) => _buildQuizItem(quiz)).toList(),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildQuizItem(Quiz quiz) {
    bool hasStudentScore = quiz.studentScoreQuiz != null;
    bool isPassed = hasStudentScore && quiz.studentScoreQuiz!.score >= quiz.passScore;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasStudentScore
              ? (isPassed ? AppColors.blue : AppColors.notAttendColor)
              : AppColors.darkGrey,
          width: 1.h,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: hasStudentScore
                      ? (isPassed ? AppColors.blue: AppColors.notAttendColor)
                      : AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  hasStudentScore
                      ? '${quiz.studentScoreQuiz!.score}/${quiz.score}'
                      : 'Not Taken',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (hasStudentScore) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: AppColors.darkGrey),
                SizedBox(width: 4.w),
                Text(
                  'Time: ${quiz.studentScoreQuiz!.time}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.darkGrey),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: AppColors.darkGrey,
                ),
                SizedBox(width: 4.w),
                Text(
                  quiz.studentScoreQuiz!.date,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.darkGrey),
                ),
              ],
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            'Pass Score: ${quiz.passScore}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}