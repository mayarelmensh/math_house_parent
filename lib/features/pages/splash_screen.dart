// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:math_house/constant/routes.dart';
// import 'package:math_house/controller/auth/login_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AppColors {
//   static const primaryColor = Color.fromRGBO(207, 32, 47, 1);
//   static const secondColor = Color.fromRGBO(253, 244, 245, 1);
//   static const red = Colors.red;
//   static const notAttendColor = Color.fromRGBO(239, 68, 68, 1);
//   static const black = Colors.black;
//   static const white = Colors.white;
//   static const grey = Colors.grey;
//   static const darkGrey = Color(0xFF7C7C7C);
//   static const shadowGrey = Color.fromRGBO(245, 245, 245, 0.3);
//   static const primary = Color(0xFFCF202F);
//   static const primaryLight = Color(0xFFFDF4F5);
//   static const yellow = Color(0xFFEFA947);
//   static const gray = Color(0xFF585858);
//   static const green = Color(0xFF15D031);
//   static const lightGray = Color(0xFFF5F5F5);
//   static const darkGray = Color(0xFF2C2C2C);
//   static const blue = Color(0xFF2196F3);
//   static const orange = Color(0xFFFF9800);
//   static const purple = Color(0xFF9C27B0);
//   static const purpleLight = Color(0xFFE1BEE7);
// }
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _logoController;
//   late AnimationController _textController;
//   late AnimationController _backgroundController;
//   late AnimationController _particleController;
//
//   late Animation<double> _logoScaleAnimation;
//   late Animation<double> _logoOpacityAnimation;
//   late Animation<double> _textSlideAnimation;
//   late Animation<double> _textOpacityAnimation;
//   late Animation<double> _backgroundAnimation;
//   late Animation<double> _particleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _startAnimations();
//     _checkFirstTime();
//   }
//
//   void _initializeAnimations() {
//     // Logo Animation Controller
//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     // Text Animation Controller
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     // Background Animation Controller
//     _backgroundController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//
//     // Particle Animation Controller
//     _particleController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat();
//
//     // Logo Animations
//     _logoScaleAnimation = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.elasticOut,
//     ));
//
//     _logoOpacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
//     ));
//
//     // Text Animations
//     _textSlideAnimation = Tween<double>(
//       begin: 50.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeOutBack,
//     ));
//
//     _textOpacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeIn,
//     ));
//
//     // Background Animation
//     _backgroundAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _backgroundController,
//       curve: Curves.easeInOut,
//     ));
//
//     // Particle Animation
//     _particleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_particleController);
//   }
//
//   void _startAnimations() async {
//     _backgroundController.forward();
//     await Future.delayed(const Duration(milliseconds: 300));
//     _logoController.forward();
//     await Future.delayed(const Duration(milliseconds: 800));
//     _textController.forward();
//   }
//
//   Future<void> _checkFirstTime() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final isFirstTime = prefs.getBool('isFirstTime') ?? true;
//       await Future.delayed(const Duration(seconds: 3));
//       if (!mounted) return;
//
//       if (isFirstTime) {
//         await prefs.setBool('isFirstTime', false);
//         Navigator.pushReplacementNamed(context, /);
//       } else {
//         final authProvider = Provider.of<LoginProvider>(
//           context,
//           listen: false,
//         );
//         final isAuthenticated = authProvider.isUserAuthenticated();
//         if (isAuthenticated) {
//           Navigator.pushReplacementNamed(context, Routes.tabsRoute);
//         } else {
//           Navigator.pushReplacementNamed(context, Routes.loginRoute);
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Error: $e',
//             style: const TextStyle(color: AppColors.white, fontSize: 14),
//           ),
//           backgroundColor: AppColors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       await Future.delayed(const Duration(seconds: 2));
//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, Routes.onboardingRoute);
//     }
//   }
//
//   @override
//   void dispose() {
//     _logoController.dispose();
//     _textController.dispose();
//     _backgroundController.dispose();
//     _particleController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: Listenable.merge([
//           _logoController,
//           _textController,
//           _backgroundController,
//           _particleController,
//         ]),
//         builder: (context, child) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primary,
//                   AppColors.primary.withOpacity(0.8),
//                   AppColors.primaryColor.withOpacity(0.9),
//                   AppColors.primary,
//                 ],
//                 stops: [
//                   0.0,
//                   0.3 + (_backgroundAnimation.value * 0.2),
//                   0.7 + (_backgroundAnimation.value * 0.2),
//                   1.0,
//                 ],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Animated Background Pattern
//                 _buildAnimatedBackground(),
//
//                 // Floating Particles
//                 _buildFloatingParticles(),
//
//                 // Background Image with Dynamic Overlay
//                 Positioned.fill(
//                   child: Opacity(
//                     opacity: 0.1 + (_backgroundAnimation.value * 0.1),
//                     child: Image.asset(
//                       'assets/images/Splash.png',
//                       fit: BoxFit.cover,
//                       color: AppColors.white.withOpacity(0.1),
//                       colorBlendMode: BlendMode.overlay,
//                     ),
//                   ),
//                 ),
//
//                 // Main Content
//                 _buildMainContent(),
//
//                 // Bottom Elements
//                 _buildBottomElements(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildAnimatedBackground() {
//     return Positioned.fill(
//       child: CustomPaint(
//         painter: BackgroundPatternPainter(_backgroundAnimation.value),
//       ),
//     );
//   }
//
//   Widget _buildFloatingParticles() {
//     return Positioned.fill(
//       child: CustomPaint(
//         painter: ParticlePainter(_particleAnimation.value),
//       ),
//     );
//   }
//
//   Widget _buildMainContent() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Logo with Enhanced Animation
//           Transform.scale(
//             scale: _logoScaleAnimation.value,
//             child: FadeTransition(
//               opacity: _logoOpacityAnimation,
//               child: Container(
//                 width: 320.w,
//                 height: 320.h,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.white.withOpacity(0.3),
//                       blurRadius: 30,
//                       spreadRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(
//                   'assets/images/logo.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(height: 40.h),
//
//           // App Name with Slide Animation
//           Transform.translate(
//             offset: Offset(0, _textSlideAnimation.value),
//             child: FadeTransition(
//               opacity: _textOpacityAnimation,
//               child: Column(
//                 children: [
//                   Text(
//                     'Math House',
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: 36.sp,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 2.0,
//                       shadows: [
//                         Shadow(
//                           color: AppColors.black.withOpacity(0.3),
//                           offset: const Offset(0, 2),
//                           blurRadius: 4,
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Container(
//                     width: 100.w,
//                     height: 3.h,
//                     decoration: BoxDecoration(
//                       color: AppColors.white,
//                       borderRadius: BorderRadius.circular(2.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.white.withOpacity(0.5),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                   Text(
//                     'Your Gateway to Mathematical Excellence',
//                     style: TextStyle(
//                       color: AppColors.white.withOpacity(0.9),
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w400,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomElements() {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         height: 120.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               AppColors.primary.withOpacity(0.3),
//               AppColors.primary.withOpacity(0.8),
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Pulsing Loading Indicator
//             Transform.scale(
//               scale: 1.0 + (_particleAnimation.value * 0.1),
//               child: Container(
//                 width: 40.w,
//                 height: 40.h,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: AppColors.white.withOpacity(0.3),
//                     width: 2,
//                   ),
//                 ),
//                 child: CircularProgressIndicator(
//                   color: AppColors.white,
//                   strokeWidth: 3.0,
//                   backgroundColor: AppColors.white.withOpacity(0.2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//             FadeTransition(
//               opacity: _textOpacityAnimation,
//               child: Text(
//                 'Loading your learning journey...',
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.8),
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w300,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class BackgroundPatternPainter extends CustomPainter {
//   final double animationValue;
//
//   BackgroundPatternPainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;
//
//     // Draw animated geometric patterns
//     for (int i = 0; i < 8; i++) {
//       final radius = 50.0 + (i * 30.0) + (animationValue * 20.0);
//       final center = Offset(size.width / 2, size.height / 2);
//
//       canvas.drawCircle(center, radius, paint);
//
//       // Draw rotating lines
//       final angle = (animationValue * 2 * 3.14159) + (i * 0.785398);
//       final lineEnd = Offset(
//         center.dx + radius * 0.8 * cos(angle),
//         center.dy + radius * 0.8 * sin(angle),
//       );
//
//       canvas.drawLine(center, lineEnd, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// class ParticlePainter extends CustomPainter {
//   final double animationValue;
//
//   ParticlePainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.fill;
//
//     // Draw floating particles
//     for (int i = 0; i < 20; i++) {
//       final x = (size.width / 20) * i + (animationValue * 50) % size.width;
//       final y = (size.height / 4) +
//           (sin(animationValue * 2 + i) * 100) +
//           (i % 3) * (size.height / 3);
//
//       final particleSize = 2.0 + (sin(animationValue * 3 + i) * 2);
//
//       canvas.drawCircle(
//         Offset(x, y % size.height),
//         particleSize,
//         paint..color = Colors.white.withOpacity(0.1 + (sin(animationValue + i) * 0.1).abs()),
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// // Helper functions for mathematical calculations
// double sin(double value) => math_sin(value);
// double cos(double value) => math_cos(value);
//
// // Mathematical functions
// double math_sin(double x) {
//   // Taylor series approximation for sin(x)
//   double result = x;
//   double term = x;
//   for (int i = 1; i < 10; i++) {
//     term *= -x * x / ((2 * i) * (2 * i + 1));
//     result += term;
//   }
//   return result;
// }
//
// double math_cos(double x) {
//   // Taylor series approximation for cos(x)
//   double result = 1.0;
//   double term = 1.0;
//   for (int i = 1; i < 10; i++) {
//     term *= -x * x / ((2 * i - 1) * (2 * i));
//     result += term;
//   }
//   return result;
// }