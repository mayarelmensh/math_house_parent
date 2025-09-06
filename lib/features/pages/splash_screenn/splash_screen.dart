import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ));

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              "assets/images/logo.png",
              width: 200.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
