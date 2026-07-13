import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int? id;
  final String title;
  final String body;
  final String date;
  final bool isRead;

  const NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? date,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'date': date,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      date: map['date'] ?? '',
      isRead: (map['is_read'] ?? 0) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, body, date, isRead];
}
