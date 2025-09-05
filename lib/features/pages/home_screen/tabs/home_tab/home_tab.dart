import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import 'package:math_house_parent/core/widgets/build_card_home.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate crossAxisCount based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 180.w).floor(); // Adjust for ~180px per card
    final childAspectRatio = screenWidth > 600 ? 1.2 : 1.0; // Taller cards on larger screens

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        // Ensure CustomAppBar is responsive (adjust if needed)
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 25.h, // Responsive vertical padding
          horizontal: 10.w, // Responsive horizontal padding
        ),
        child: GridView.count(
          crossAxisCount: crossAxisCount.clamp(2, 4), // Minimum 2, max 4 columns
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 10.w, // Responsive spacing between cards
          mainAxisSpacing: 10.h, // Responsive spacing between rows
          padding: EdgeInsets.all(8.r), // Responsive padding
          children: [
            HomeCard(
              icon: Icons.person,
              title: "Students",
              subtitle: "Select your son",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.getStudent);
              },
            ),
            HomeCard(
              icon: Icons.attach_money,
              title: "Packages",
              subtitle: "View students",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.packagesScreen);
              },
            ),
            HomeCard(
              icon: Icons.settings,
              title: "Courses",
              subtitle: "Go to Courses",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.buyCourse);
              },
            ),
            HomeCard(
              icon: Icons.credit_score,
              title: "Score Sheet",
              subtitle: "Go to Score Sheet",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.scoreSheet);
              },
            ),
            HomeCard(
              icon: Icons.notifications,
              title: "Notifications",
              subtitle: "View alerts",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.notificationsScreen);
              },
            ),
            HomeCard(
              icon: Icons.logout_outlined,
              title: "Log Out",
              subtitle: "Log out",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.logOutScreen);
              },
            ),
            HomeCard(
              icon: Icons.person,
              title: "Profile",
              subtitle: "Go to profile",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profileScreen);
              },
            ),
            HomeCard(
              icon: Icons.history,
              title: "Payment History",
              subtitle: "Go to payment history",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.paymentHistory);
              },
            ),
            HomeCard(
              icon: Icons.account_balance_wallet,
              title: "Recharge Wallet",
              subtitle: "Add funds",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.rechargeWallet);
              },
            ),
            HomeCard(
              icon: Icons.account_balance,
              title: "Wallet History",
              subtitle: "View wallet transactions",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.walletHistory);
              },
            ),
            HomeCard(
              icon: Icons.card_membership,
              title: "My Packages",
              subtitle: "View your packages",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.myPackagesScreen);
              },
            ), HomeCard(
              icon: Icons.card_membership,
              title: "My Courses",
              subtitle: "View your courses",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.myCourse);
              },
            ),
          ],
        ),
      ),
    );
  }
}