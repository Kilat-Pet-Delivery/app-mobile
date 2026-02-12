import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_response.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

// ── State ──

class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final PaginationMeta? pagination;
  final NotificationStatus status;
  final String? errorMessage;
  final bool hasReachedMax;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.pagination,
    this.status = NotificationStatus.initial,
    this.errorMessage,
    this.hasReachedMax = false,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    PaginationMeta? pagination,
    NotificationStatus? status,
    String? errorMessage,
    bool? hasReachedMax,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props =>
      [notifications, pagination, status, errorMessage, hasReachedMax, unreadCount];
}

enum NotificationStatus { initial, loading, loaded, error }

// ── Cubit ──

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationState());

  Future<void> loadNotifications({int page = 1}) async {
    if (state.status == NotificationStatus.loading) return;
    if (state.hasReachedMax && page > 1) return;

    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final result = await _repository.listNotifications(page: page);
      final allItems = page == 1
          ? result.items
          : [...state.notifications, ...result.items];

      final unread = allItems.where((n) => !n.isRead).length;

      emit(state.copyWith(
        status: NotificationStatus.loaded,
        notifications: allItems,
        pagination: result.pagination,
        hasReachedMax: !result.pagination.hasNextPage,
        unreadCount: unread,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(hasReachedMax: false));
    await loadNotifications(page: 1);
  }

  Future<void> loadNextPage() async {
    if (state.pagination == null) return;
    await loadNotifications(page: state.pagination!.page + 1);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      final updated = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            bookingId: n.bookingId,
            eventType: n.eventType,
            title: n.title,
            body: n.body,
            channelsSent: n.channelsSent,
            channelsFailed: n.channelsFailed,
            status: n.status,
            isRead: true,
            metadata: n.metadata,
            createdAt: n.createdAt,
            updatedAt: n.updatedAt,
          );
        }
        return n;
      }).toList();

      final unread = updated.where((n) => !n.isRead).length;

      emit(state.copyWith(
        notifications: updated,
        unreadCount: unread,
      ));
    } catch (_) {
      // Silently fail — optimistic UI can retry on next load.
    }
  }

  Future<void> registerFcmToken(String token) async {
    try {
      await _repository.registerFcmToken(token);
    } catch (_) {
      // Non-critical — will retry on next app launch.
    }
  }
}
