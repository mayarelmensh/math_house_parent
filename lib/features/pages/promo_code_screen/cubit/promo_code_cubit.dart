// promo_code_screen/cubit/promo_code_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_manager.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/promo_code_model.dart';
import 'promo_code_states.dart';

@injectable
class PromoCodeCubit extends Cubit<PromoCodeStates> {
  final ApiManager apiManager;

  PromoCodeCubit(this.apiManager) : super(PromoCodeInitialState());

  Future<void> applyPromoCode({
    required int promoCode,
    required int courseId,
    required int userId,
    required double originalAmount,
  }) async {
    emit(PromoCodeLoadingState());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token') ;
      if (token == null) {
        emit(PromoCodeErrorState('No token found'));
        return;
      }


      final body = {
        'promo_code': promoCode,
        'course_id': courseId,
        'user_id': userId,
        'amount': originalAmount, // Convert to int
      };

      print('PromoCode Request: $body');
      print('Headers: {Authorization: Bearer $token}');

      final response = await apiManager.postData(
        endPoint: EndPoints.promoCode,
        body: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('PromoCode Response: ${response.data}');

      final promoCodeResponse = PromoCodeResponse.fromJson(response.data);
      emit(PromoCodeSuccessState(promoCodeResponse));
    } catch (e) {
      String errorMessage = 'Failed to apply promo code';

      if (e is DioException) {
        print('PromoCode DioException response data: ${e.response?.data}');
        print('PromoCode DioException message: ${e.message}');

        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString() ??
              'Invalid promo code';
        } else if (e.response?.statusCode == 422) {
          errorMessage = 'Invalid promo code';
        } else {
          errorMessage = 'Error ${e.response?.statusCode}: ${e.message}';
        }
      } else {
        print('PromoCode Error: $e');
        errorMessage = e.toString();
      }

      emit(PromoCodeErrorState(errorMessage));
    }
  }

  void resetState() {
    emit(PromoCodeInitialState());
  }
}