import 'package:flutter/material.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text("home",style: TextStyle(color: AppColors.primaryColor,fontSize:20 ),)),
        ],
      ),
    );
  }
}
