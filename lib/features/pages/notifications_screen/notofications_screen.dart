import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/core/di/di.dart';
import 'package:math_house_parent/core/widgets/custom_app_bar.dart';
import '../../../core/utils/app_colors.dart';
import '../../../data/models/notification_model.dart';
import 'cubit/notifications_cuibt.dart';
import 'cubit/notifications_states.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationCubit notificationCubit = getIt<NotificationCubit>();

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => notificationCubit..fetchNotifications(),
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: CustomAppBar(title: "Notifications"),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationInitial) {
              return const Center(
                child: Text(
                  'Initializing...',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 16,
                  ),
                ),
              );
            } else if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            } else if (state is NotificationLoaded) {
              return NotificationUtils.buildNotificationContent(
                context,
                state.response,
              );
            } else if (state is NotificationError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}




class NotificationUtils {
  static Widget buildNotificationContent(
      BuildContext context, NotificationResponse response) {
    if (response.notifications != null &&
        response.notifications!.isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: response.notifications!.length,
              itemBuilder: (context, index) {
                final notification = response.notifications![index];
                return Card(
                  color: AppColors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.notifications,
                      color: notification.isRead == true
                          ? AppColors.gray
                          : AppColors.primary,
                      size: 40,
                    ),
                    title: Text(
                      notification.title ?? 'No Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: notification.isRead == true
                            ? AppColors.gray
                            : AppColors.darkGray,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.message != null)
                          Text(
                            notification.message!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gray,
                            ),
                          ),
                        if (notification.createdAt != null)
                          Text(
                            'Date: ${notification.createdAt}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowGrey,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // عشان يفضل في النص بالظبط
            children: [
              const Icon(
                Icons.notifications_none,
                color: AppColors.gray,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No notifications available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for updates!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
