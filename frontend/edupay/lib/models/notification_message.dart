// lib/models/notification_message.dart
// Model for real-time notifications from WebSocket

class NotificationMessage {
  final int? id;
  final String title;
  final String message;
  final String type;
  final String? insight;
  final double? totalOutstanding;
  final bool isRead;
  final DateTime createdAt;

  NotificationMessage({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    this.insight,
    this.totalOutstanding,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'] as int?,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'GENERAL',
      insight: json['insight'] as String?,
      totalOutstanding: (json['totalOutstanding'] as num?)?.toDouble(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationMessage copyWith({bool? isRead}) {
    return NotificationMessage(
      id: id,
      title: title,
      message: message,
      type: type,
      insight: insight,
      totalOutstanding: totalOutstanding,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
