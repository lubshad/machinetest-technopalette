import 'dart:convert';

class NotificationHistoryModel {
  final String id;
  final String title;
  final String body;
  final String notificationType;
  final String status;
  final String userType;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationHistoryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.status,
    required this.userType,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.createdAt,
    this.data,
  });

  factory NotificationHistoryModel.fromMap(Map<String, dynamic> map) {
    return NotificationHistoryModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      notificationType: map['notification_type'] as String? ?? '',
      status: map['status'] as String? ?? '',
      userType: map['user_type'] as String? ?? '',
      sentAt: map['sent_at'] != null
          ? DateTime.parse(map['sent_at'] as String)
          : DateTime.now(),
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at'] as String)
          : null,
      readAt: map['read_at'] != null
          ? DateTime.parse(map['read_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'notification_type': notificationType,
      'status': status,
      'user_type': userType,
      'sent_at': sentAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }

  factory NotificationHistoryModel.fromJson(String source) =>
      NotificationHistoryModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  String toJson() => json.encode(toMap());

  bool get isRead => readAt != null;
  bool get isDelivered => deliveredAt != null;

  String? get actionUrl => data?['url'] as String?;
}
