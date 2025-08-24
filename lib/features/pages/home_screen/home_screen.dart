import 'package:flutter/material.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text("home",style: TextStyle(color: AppColors.primaryColor,fontSize:20 ),)),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushReplacementNamed(context, '/login'); // او /register لو حابة
            },
            child: Text('Logout'),
          )

        ],
      ),
    );
  }
}
