import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';

import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/notification_model.dart';
import 'notifications_states.dart';


@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final ApiManager apiManager;

  NotificationCubit(this.apiManager) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.getData(
        endPoint: EndPoints.notifications, // Adjust endpoint as needed
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final notificationResponse = NotificationResponse.fromJson(response.data);
      emit(NotificationLoaded(notificationResponse));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}