class NotificationResponse {
  final List<NotificationItem>? notifications;

  NotificationResponse({this.notifications});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificationItem {
  final int? id;
  final String? title;
  final String? message;
  final String? createdAt;
  final bool? isRead;

  NotificationItem({
    this.id,
    this.title,
    this.message,
    this.createdAt,
    this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString() ?? '0'),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['created_at']?.toString(),
      isRead: json['is_read'] is bool ? json['is_read'] : json['is_read']?.toString().toLowerCase() == 'true',
    );
  }
}