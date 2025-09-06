
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/features/pages/splash_screenn/cubit/splash_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class SplashCubit extends Cubit<SplashStates> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkSplashStatus() async {
    emit(SplashLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      await Future.delayed(const Duration(seconds: 3)); // Splash delay

      if (isFirstTime) {
        await prefs.setBool('isFirstTime', false);
        emit(SplashNavigate('/onboarding'));
      } else {
        // Replace with actual auth check
        final isAuthenticated = await _checkAuthentication();
        if (isAuthenticated) {
          emit(SplashNavigate('/tabs'));
        } else {
          emit(SplashNavigate('/login'));
        }
      }
    } catch (e) {
      emit(SplashError('Error: $e'));
      await Future.delayed(const Duration(seconds: 2));
      emit(SplashNavigate('/onboarding')); // Fallback
    }
  }

  Future<bool> _checkAuthentication() async {
    // Replace with actual LoginProvider check
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return token.isNotEmpty; // Simplified auth check
  }
}