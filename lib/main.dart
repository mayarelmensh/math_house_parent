import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/features/auth/forget_password_screen/forget_password_screen.dart';
import 'package:math_house_parent/features/pages/home_screen/tabs/home_tab/home_tab.dart';
import 'package:math_house_parent/features/pages/students_screen/students_screen.dart';
import 'core/cashe/shared_preferences_utils.dart';
import 'core/di/di.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/my_bloc_observer.dart';
import 'features/auth/login/login_screen.dart';
import 'features/auth/register/register_screen.dart';
import 'features/pages/home_screen/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = MyBlocObserver();
  await SharedPreferenceUtils.init();
  String routeName;
  var token = SharedPreferenceUtils.getData(key: 'token');
  if (token == null) {
    routeName = AppRoutes.registerRoute;
  } else {
    //todo: token != null => user
    routeName = AppRoutes.homeTab;
  }
  runApp(MyApp(routeName: routeName,));
}

class MyApp extends StatelessWidget{
  String routeName;
   MyApp({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: routeName,
          routes: {
            AppRoutes.loginRoute: (context) => LoginScreen(),
            AppRoutes.registerRoute: (context) => RegisterScreen(),
            AppRoutes.forgetPasswordRoute: (context) => ForgetPasswordScreen(),
            AppRoutes.homeRoute: (context) => HomeScreen(),
            AppRoutes.getStudent: (context) => StudentsScreen(),
            AppRoutes.homeTab: (context) => HomeTab(),
          },
        );
      },
    );
  }
}




