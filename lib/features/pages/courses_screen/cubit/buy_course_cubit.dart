import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';

import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/buy_cource_model.dart';
import 'buy_course_states.dart';

@injectable
class BuyCourseCubit extends Cubit<BuyCourseStates> {
  final ApiManager apiManager;

  BuyCourseCubit(this.apiManager) : super(BuyCourseInitialState());

  Future<void> buyPackage({
    required int userId,
    required int courseId,
    required dynamic paymentMethodId,
    required double amount,
    required int duration,
    required String image,
  }) async {
    emit(BuyCourseLoadingState());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null) {
        emit(BuyCourseErrorState('No token found'));
        return;
      }

      // تحضير الـ image data بناءً على نوع الدفع
      String imageData;
      if (image == 'wallet') {
        imageData = 'wallet';
      } else {
        // إذا كان Base64، تحقق من وجود الـ prefix أو لا
        if (image.startsWith('data:image/')) {
          imageData = image; // الـ prefix موجود بالفعل
        } else {
          imageData = 'data:image/jpeg;base64,$image'; // أضف الـ prefix
        }
      }

      // Prepare the request body
      final body = {
        'course_id': courseId,
        'payment_method_id': paymentMethodId,
        'amount': amount.toInt(), // Convert to int to match API expectation
        'user_id': userId,
        'duration': duration,
        'image': imageData,
      };

      // Log the request for debugging
      print('BuyCourse Request: $body');
      print('Headers: {Authorization: Bearer $token}');

      final response = await apiManager.postData(
        endPoint: EndPoints.buyCourse,
        body: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final buyCourseResponse = BuyCourseResponseEntity.fromJson(response.data);
      emit(BuyCourseSuccessState(buyCourseResponse));
    } catch (e) {
      String errorMessage = 'Failed to purchase course';

      if (e is DioException) {
        print('DioException response data: ${e.response?.data}');
        print('DioException message: ${e.message}');

        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message']?.toString() ??
              'Error ${e.response?.statusCode}: ${e.message}';
        } else {
          errorMessage = 'Error ${e.response?.statusCode}: ${e.message}';
        }
      } else {
        print('Error: $e');
      }

      emit(BuyCourseErrorState(errorMessage));
    }
  }
}