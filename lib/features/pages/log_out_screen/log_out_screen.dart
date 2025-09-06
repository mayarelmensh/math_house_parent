// import 'package:flutter/material.dart';
// import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
// import 'package:math_house_parent/core/utils/app_colors.dart';
// import 'package:math_house_parent/core/utils/app_routes.dart';
// import 'package:math_house_parent/features/widgets/custom_elevated_button.dart';
//
// class LogOutScreen extends StatelessWidget {
//   const LogOutScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//        body: Center(
//          child: CustomElevatedButton(text: 'Log Out ',
//              onPressed: (){
//              SharedPreferenceUtils.removeData(key: 'CASHED_PARENT');
//              Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
//              }, backgroundColor:
//              AppColors.blue, textStyle: TextStyle(color: AppColors.primaryColor)),
//        ),
//     );
//   }
// }
