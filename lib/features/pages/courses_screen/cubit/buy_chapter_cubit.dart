import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
import '../../../../data/models/buy_chapter_model.dart';
import 'buy_chapter_states.dart';

@injectable
class BuyChapterCubit extends Cubit<BuyChapterStates> {
  final ApiManager apiManager;

  BuyChapterCubit(this.apiManager) : super(BuyChapterInitialState());

  Future<void> buyChapter({
    required int courseId,
    required dynamic paymentMethodId,
    required double amount,
    required int userId,
    required int chapterId,
    required int duration,
    required String image,
  }) async {
    emit(BuyChapterLoadingState());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;
      if (token == null) {
        emit(BuyChapterErrorState('No token found'));
        return;
      }

      // Prepare the request body
      final body = FormData.fromMap({
        'course_id': courseId,
        'payment_method_id': paymentMethodId,
        'amount': amount.toInt(), // Convert to int to match API expectation
        'user_id': userId,
        'chapters[0][chapter_id]': chapterId,
        'chapters[0][duration]': duration,
      });

      if (image != 'wallet') {
        body.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(image),
        ));
      } else {
        body.fields.add(const MapEntry('image', 'wallet'));
      }

      // Log the request for debugging
      print('BuyChapter Request: ${body.fields}');
      print('Headers: {Authorization: Bearer $token}');

      final response = await apiManager.postData(
        endPoint: EndPoints.buyChapter,
        body: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final buyChapterResponse = BuyChapterModel.fromJson(response.data);
      emit(BuyChapterSuccessState(buyChapterResponse));
    } catch (e) {
      String errorMessage = 'Failed to purchase chapter';

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

      emit(BuyChapterErrorState(errorMessage));
    }
  }
}