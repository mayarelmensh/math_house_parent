import 'package:dartz/dartz.dart' as selectedPackage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        const SnackBar(content: Text('Please select a student first')),
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
          content: const Text('Please select a course first'),
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

  Widget _buildSelectionCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPackageCard(dynamic package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.name ?? "Unnamed Package",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getModuleColor(package.module),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getModuleText(package.module),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  "${package.price ?? 0} EGP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 4),
                Text(
                  "${package.duration ?? 0} mins",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (SelectedStudent.studentId != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.paymentMethodsScreen,
                      arguments: {
                        'packageId': package.id,
                         'packageName':package.name,
                          'packagePrice':package.price,
                          'packageModule':package.module,
                        'packageDuration':package.duration,
                        // هنا استخدم package.id وليس selectedPackage.id
                      },

                    );
                    debugPrint(
                      "🛒 Buy package: ${package.id}, for student: ${SelectedStudent.studentId} ",
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a student first'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Buy Package',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => coursesCubit),
        BlocProvider(create: (_) => packagesCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CustomAppBar(title: "Packages"),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Course Selection
              _buildSelectionCard(
                title: "Select Course",
                icon: Icons.school,
                child: BlocBuilder<CoursesCubit, CoursesStates>(
                  bloc: coursesCubit,
                  builder: (context, state) {
                    if (state is CoursesLoadingState) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    } else if (state is CoursesSuccessState) {
                      final courses = state.coursesResponseEntity.categories!
                          .expand((cat) => cat.course!)
                          .toList();
                      return DropdownButtonFormField<CourseEntity>(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          hintText: "Choose a course",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        value: selectedCourse,
                        items: courses.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              c.courseName ?? "",
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => selectedCourse = val);
                        },
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text("Error loading courses"),
                    );
                  },
                ),
              ),

              // Module Filter
              _buildSelectionCard(
                title: "Filter by Type",
                icon: Icons.filter_list,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: "Choose content type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  value: selectedModuleFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text("All")),
                    DropdownMenuItem(value: 'Live', child: Text("Live")),
                    DropdownMenuItem(
                      value: 'Question',
                      child: Text("Questions"),
                    ),
                    DropdownMenuItem(value: 'Exam', child: Text("Exams")),
                  ],
                  onChanged: (val) {
                    setState(() => selectedModuleFilter = val);
                  },
                ),
              ),

              // Load Button
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _loadPackages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Load Packages",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Packages List
              Expanded(
                flex: 3,
                child: BlocBuilder<PackagesCubit, PackagesStates>(
                  builder: (context, state) {
                    if (state is PackagesLoadingState) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Loading packages...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
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
                              Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No packages available",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try changing the filter or selecting another course",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: packages.length,
                        itemBuilder: (_, i) {
                          final pkg = packages[i];
                          return _buildPackageCard(pkg);
                        },
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Select course first",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Then press 'Load Packages' button",
                            style: TextStyle(
                              fontSize: 14,
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
  }
}
