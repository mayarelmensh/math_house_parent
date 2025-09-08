import 'package:dartz/dartz.dart' as selectedPackage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import '../../../core/di/di.dart';
import '../../../data/models/student_selected.dart';
import '../../../domain/entities/courses_response_entity.dart';
import '../courses_screen/cubit/courses_cubit.dart';
import '../courses_screen/cubit/courses_states.dart';
import 'cubit/packages_cubit.dart';
import 'cubit/packages_states.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  _PackagesScreenState createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  CourseEntity? selectedCourse;
  String? selectedModuleFilter;

  final packagesCubit = getIt<PackagesCubit>();
  final coursesCubit = getIt<CoursesCubit>();

  @override
  void initState() {
    super.initState();
    coursesCubit.getCoursesList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    packagesCubit.close();
    super.dispose();
  }

  void _loadPackages() {
    final studentId = SelectedStudent.studentId;
    print(studentId);

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a student first', style: TextStyle(fontSize: 14.sp))),
      );
      return;
    }

    if (selectedCourse != null) {
      packagesCubit.getPackagesForCourse(
        courseId: selectedCourse!.id!,
        userId: studentId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a course first', style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  List filterPackagesByModule(List packages) {
    if (selectedModuleFilter == null || selectedModuleFilter == 'All')
      return packages;
    return packages.where((p) => p.module == selectedModuleFilter).toList();
  }

  Widget _buildCompactSelectionRow() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          // Course and Filter Selection Row
          Row(
            children: [
              // Course Selection
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1.r,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: BlocBuilder<CoursesCubit, CoursesStates>(
                    bloc: coursesCubit,
                    builder: (context, state) {
                      if (state is CoursesLoadingState) {
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          child: Center(
                            child: SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 2.w,
                              ),
                            ),
                          ),
                        );
                      } else if (state is CoursesSuccessState) {
                        final courses = state.coursesResponseEntity.categories!
                            .expand((cat) => cat.course!)
                            .toList();
                        return DropdownButtonFormField<CourseEntity>(
                          isExpanded: true, // عشان يمنع الأوفرفلو
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            hintText: "Select Course",
                            prefixIcon: Icon(
                              Icons.school,
                              color: AppColors.primaryColor,
                              size: 20.sp,
                            ),
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14.sp),
                          ),
                          value: selectedCourse,
                          items: courses.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c.courseName ?? "",
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedCourse = val);
                          },
                        );
                      }
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        child: Text("Error", style: TextStyle(fontSize: 14.sp)),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Module Filter
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1.r,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // عشان يمنع الأوفرفلو
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      hintText: "Filter",
                      prefixIcon: Icon(
                        Icons.filter_list,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14.sp),
                    ),
                    value: selectedModuleFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text("All", style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'Live', child: Text("Live", style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'Question', child: Text("Question", style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'Exam', child: Text("Exam", style: TextStyle(fontSize: 14))),
                    ],
                    onChanged: (val) {
                      setState(() => selectedModuleFilter = val);
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Load Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: _loadPackages,
              icon: Icon(Icons.refresh, color: Colors.white, size: 20.sp),
              label: Text(
                "Load Packages",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPackageCard(dynamic package) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1.r,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with package name and module badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.name ?? "Unnamed Package",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getModuleGradientColors(package.module),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: _getModuleColor(package.module).withOpacity(0.3),
                        spreadRadius: 1.r,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getModuleIcon(package.module),
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _getModuleText(package.module),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Price and Duration with enhanced styling
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Price Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.green.shade700,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Price",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${package.price ?? 0} EGP",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 40.h,
                    width: 1.w,
                    color: Colors.grey.shade300,
                  ),

                  // Duration Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Duration",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${package.duration ?? 0} mins",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.blue.shade700,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Enhanced Buy Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  if (SelectedStudent.studentId != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.paymentMethodsScreen,
                      arguments: {
                        'packageId': package.id,
                        'packageName': package.name,
                        'packagePrice': package.price,
                        'packageModule': package.module,
                        'packageDuration': package.duration,
                      },
                    );
                    debugPrint(
                      "🛒 Buy package: ${package.id}, for student: ${SelectedStudent.studentId} ",
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a student first', style: TextStyle(fontSize: 14.sp)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.primaryColor.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Buy Package',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModuleColor(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return Colors.red.shade500;
      case 'question':
        return Colors.blue.shade500;
      case 'exam':
        return Colors.purple.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  List<Color> _getModuleGradientColors(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return [Colors.red.shade400, Colors.red.shade600];
      case 'question':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 'exam':
        return [Colors.purple.shade400, Colors.purple.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  IconData _getModuleIcon(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return Icons.live_tv;
      case 'question':
        return Icons.quiz;
      case 'exam':
        return Icons.assignment;
      default:
        return Icons.help;
    }
  }

  String _getModuleText(String? module) {
    switch (module?.toLowerCase()) {
      case 'live':
        return 'Live';
      case 'question':
        return 'Question';
      case 'exam':
        return 'Exam';
      default:
        return module ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // حجم التصميم الأساسي
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => coursesCubit),
            BlocProvider(create: (_) => packagesCubit),
          ],
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: CustomAppBar(title: "Packages"),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Compact Selection Row
                  _buildCompactSelectionRow(),

                  // Packages List
                  Expanded(
                    child: BlocBuilder<PackagesCubit, PackagesStates>(
                      builder: (context, state) {
                        if (state is PackagesLoadingState) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                  strokeWidth: 3.w,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "Loading packages...",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is PackagesSpecificCourseSuccessState) {
                          var packages = filterPackagesByModule(
                            state.packagesResponseList,
                          );
                          if (packages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(50.r),
                                    ),
                                    child: Icon(
                                      Icons.inbox_outlined,
                                      size: 60.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    "No packages available",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Try changing the filter or selecting another course",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: packages.length,
                            itemBuilder: (_, i) {
                              final pkg = packages[i];
                              return _buildEnhancedPackageCard(pkg);
                            },
                          );
                        }
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Icon(
                                  Icons.touch_app_outlined,
                                  size: 60.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                "Select course first",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Then press 'Load Packages' button",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}