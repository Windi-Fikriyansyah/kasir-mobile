import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/notification/blocs/notification_bloc.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: QuickPOSColors.onSurface)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: QuickPOSColors.onSurface),
        elevation: 0,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Text('Belum ada notifikasi.', style: TextStyle(color: QuickPOSColors.outline)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                final date = DateTime.parse(notif.date);
                final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

                return InkWell(
                  onTap: () {
                    if (!notif.isRead && notif.id != null) {
                      context.read<NotificationBloc>().add(MarkNotificationAsRead(notif.id!));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: notif.isRead ? Colors.white : QuickPOSColors.error.withOpacity(0.05),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notif.isRead ? QuickPOSColors.surfaceContainerHigh : QuickPOSColors.error.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: notif.isRead ? QuickPOSColors.outline : QuickPOSColors.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                                  color: QuickPOSColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: QuickPOSColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: QuickPOSColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: const BoxDecoration(
                              color: QuickPOSColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is NotificationError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
