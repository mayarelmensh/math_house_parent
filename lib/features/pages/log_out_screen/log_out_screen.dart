import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogOutScreen extends StatelessWidget {
  const LogOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            Navigator.pushReplacementNamed(context, '/login'); // او /register لو حابة
          },
          child: Text('Logout'),
        )
      ],
    );
  }
}
