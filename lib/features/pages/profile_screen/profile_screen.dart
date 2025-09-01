import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import 'package:math_house_parent/domain/entities/login_response_entity.dart';
import 'package:math_house_parent/domain/entities/get_students_response_entity.dart';
import '../../../core/utils/app_colors.dart';
import '../students_screen/cubit/students_screen_cubit.dart';
import '../students_screen/cubit/students_screen_states.dart';
import 'cubit/profile_screen_cubit.dart';
import 'cubit/profile_screen_states.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

ProfileCubit profileCubit = getIt<ProfileCubit>();
GetStudentsCubit getStudentsCubit = getIt<GetStudentsCubit>();

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    profileCubit.loadProfile();
    getStudentsCubit.getMyStudents();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => profileCubit..loadProfile(),
        ),
        BlocProvider(
          create: (_) => getStudentsCubit,
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: "Profile",
          actions: [
            IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: AppColors.white),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // -------------------- Parent Profile Card --------------------
              BlocBuilder<ProfileCubit, ProfileStates>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return _buildLoadingCard();
                  } else if (state is ProfileLoaded) {
                    return _buildParentInfoCard(state.parent);
                  } else if (state is ProfileError) {
                    return _buildErrorCard(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // -------------------- Students Section --------------------
              BlocBuilder<GetStudentsCubit, GetStudentsStates>(
                builder: (context, state) {
                  if (state is GetStudentsLoadingState) {
                    return _buildStudentsLoadingCard();
                  } else if (state is GetMyStudents) {
                    return _buildChildrenSection(state.myStudents, context);
                  } else if (state is GetStudentsErrorState) {
                    return _buildStudentsErrorCard(state.error.errorMsg);
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // -------------------- Action Buttons --------------------
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // =======================
  // 🟢 Parent Profile Card
  // =======================
  Widget _buildParentInfoCard(ParentLoginEntity parent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // const SizedBox(height: 16),
            // Parent Name
            Text(
              parent.name ?? 'unselected name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Contact Info
            _buildContactInfo(
              icon: Icons.email,
              label: parent.email ?? 'unselected email',
            ),
            const SizedBox(height: 12),
            _buildContactInfo(
              icon: Icons.phone,
              label: parent.phone ?? 'unselected phone',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  // 🟢 Loading States
  // =======================
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildStudentsLoadingCard() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              "Loading students's data...",
              style: TextStyle(
                color: AppColors.gray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // 🟢 Error States
  // =======================
  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            "حدث خطأ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsErrorCard(String error) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              "Failed to load students",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.gray,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // 🟢 Students Section
  // =======================
  Widget _buildChildrenSection(List<StudentsEntity> students, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "My Students",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${students.length}",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Students List
            if (students.isEmpty)
              _buildEmptyStudentsState()
            else
              ...students.map((student) => _buildChildCard(student, context)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStudentsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No students registered",
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   "يمكنك إضافة طلاب جدد من خلال التطبيق",
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: AppColors.grey.withOpacity(0.6),
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ],
      ),
    );
  }

  Widget _buildChildCard(StudentsEntity student, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<GetStudentsCubit>().selectStudent(student.id!);
            _showChildDetails(student, context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Student Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      student.nickName?.isNotEmpty == true
                          ? student.nickName![0].toUpperCase()
                          : "S",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.nickName ?? "unselected student",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "students number: ${student.id}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================
  // 🟢 Action Buttons
  // =======================
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Edit Profile Button
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       // TODO: Navigate to edit profile screen
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text("قريباً: تحرير الملف الشخصي"),
          //           backgroundColor: AppColors.blue,
          //         ),
          //       );
          //     },
          //     icon: const Icon(Icons.edit, color: AppColors.white),
          //     label: const Text(
          //       "تحرير الملف الشخصي",
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: AppColors.white,
          //       ),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.blue,
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       elevation: 2,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 12),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: AppColors.red),
              label: const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  // 🟢 Dialog Methods
  // =======================
  void _showChildDetails(StudentsEntity student, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.nickName?.isNotEmpty == true
                      ? student.nickName![0].toUpperCase()
                      : "S",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              student.nickName ?? "Student",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Student's Number", "${student.id}"),
              const SizedBox(height: 8),
              _buildDetailRow("Nick Name", student.nickName ?? "Unselected"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.darkGray,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Log Out",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are You Sure To Log Out",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.gray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SharedPreferenceUtils.removeData(key: 'CACHED_PARENT');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Log Out",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
