import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notification_cubit.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications(page: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<NotificationCubit>().state;
      if (state.status != NotificationStatus.loading && !state.hasReachedMax) {
        context.read<NotificationCubit>().loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Notification Settings',
            onPressed: () => context.push('/notifications/settings'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.error &&
              state.notifications.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load notifications',
              onRetry: () => context.read<NotificationCubit>().refresh(),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('No notifications yet',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.notifications.length +
                  (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = state.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () {
                    if (!notification.isRead) {
                      context
                          .read<NotificationCubit>()
                          .markAsRead(notification.id);
                    }
                    // Navigate to related booking if available.
                    if (notification.bookingId != null &&
                        notification.bookingId!.isNotEmpty) {
                      context.push('/bookings/${notification.bookingId}');
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? null : AppColors.primaryLight.withValues(alpha: 0.15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _iconColor.withValues(alpha: 0.15),
          child: Icon(_icon, color: _iconColor, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.relative(notification.createdAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  IconData get _icon {
    switch (notification.eventCategory) {
      case 'booking':
        return Icons.pets;
      case 'payment':
        return Icons.payment;
      case 'tracking':
        return Icons.location_on;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (notification.eventCategory) {
      case 'booking':
        return AppColors.statusAccepted;
      case 'payment':
        return AppColors.statusInProgress;
      case 'tracking':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }
}
