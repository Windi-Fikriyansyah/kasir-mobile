import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kasirsuper/core/database/database_helper.dart';
import 'package:kasirsuper/features/notification/models/notification_model.dart';

// --- Events ---
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class AddNotification extends NotificationEvent {
  final NotificationModel notification;
  const AddNotification(this.notification);
  @override
  List<Object?> get props => [notification];
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;
  const MarkNotificationAsRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

// --- State ---
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final DatabaseHelper databaseHelper;

  NotificationBloc({required this.databaseHelper}) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<AddNotification>(_onAddNotification);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final maps = await databaseHelper.getNotifications();
      final notifications = maps.map((e) => NotificationModel.fromMap(e)).toList();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications: notifications, unreadCount: unreadCount));
    } catch (e) {
      emit(NotificationError('Gagal memuat notifikasi: $e'));
    }
  }

  Future<void> _onAddNotification(AddNotification event, Emitter<NotificationState> emit) async {
    try {
      await databaseHelper.insertNotification(event.notification.toMap());
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError('Gagal menambah notifikasi: $e'));
    }
  }

  Future<void> _onMarkAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    try {
      await databaseHelper.markNotificationAsRead(event.notificationId);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError('Gagal mengubah status notifikasi: $e'));
    }
  }
}
