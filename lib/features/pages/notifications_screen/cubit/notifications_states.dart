import '../../../../data/models/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final NotificationResponse response;
  NotificationLoaded(this.response);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
