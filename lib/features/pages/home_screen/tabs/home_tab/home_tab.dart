import 'package:flutter/material.dart';
import 'package:math_house_parent/core/utils/app_routes.dart';
import '../../../../../core/widgets/build_card_home.dart';
import '../../../../../core/widgets/custom_app_bar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'Home ',
        ),
        body: Padding(
          padding:  EdgeInsets.symmetric(vertical: 25,horizontal: 10),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1,
            children: [
              HomeCard(
            icon: Icons.person,
            title: "Students",
            subtitle: "select your son",
            onTap: () {
             Navigator.pushNamed(context, AppRoutes.getStudent);
            },
          ),
              HomeCard(
            icon: Icons.attach_money,
            title: "Packages ",
            subtitle: "View students",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.packagesScreen);
            },
          ),
              HomeCard(
            icon: Icons.settings,
            title: "Courses",
            subtitle: "go to Courses",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.buyCourse);
            },
          ),
              HomeCard(
            icon: Icons.credit_score,
            title: "Score sheet",
            subtitle: "go to Score sheet",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.scoreSheet);
            },
          ),
              HomeCard(
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "View alerts",
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),HomeCard(
            icon: Icons.logout_outlined,
            title: "Log Out",
            subtitle: "Log out",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.logOutScreen);
            },
          ),HomeCard(
            icon: Icons.person,
            title: "Profile ",
            subtitle: "     go to profile   ",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profileScreen);
            },
          ),HomeCard(
            icon: Icons.person,
            title: "payment history ",
            subtitle: "     go to payment history   ",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.paymentHistory);
            },
          ),
        ]),
    ),
    );
  }
}
