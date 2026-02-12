import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum BookingStatus {
  requested,
  accepted,
  inProgress,
  delivered,
  completed,
  cancelled;

  static BookingStatus fromString(String s) {
    switch (s) {
      case 'requested':
        return BookingStatus.requested;
      case 'accepted':
        return BookingStatus.accepted;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'delivered':
        return BookingStatus.delivered;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        throw ArgumentError('Unknown booking status: $s');
    }
  }

  String get apiValue {
    switch (this) {
      case BookingStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.requested:
        return 'Requested';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.delivered:
        return 'Delivered';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.requested:
        return AppColors.statusRequested;
      case BookingStatus.accepted:
        return AppColors.statusAccepted;
      case BookingStatus.inProgress:
        return AppColors.statusInProgress;
      case BookingStatus.delivered:
        return AppColors.statusDelivered;
      case BookingStatus.completed:
        return AppColors.statusCompleted;
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.requested:
        return Icons.schedule;
      case BookingStatus.accepted:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.local_shipping;
      case BookingStatus.delivered:
        return Icons.place;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  bool get isActive =>
      this != BookingStatus.completed && this != BookingStatus.cancelled;

  bool get canCancel =>
      this == BookingStatus.requested ||
      this == BookingStatus.accepted ||
      this == BookingStatus.inProgress;

  bool get canConfirmDelivery => this == BookingStatus.delivered;

  bool get canTrack => this == BookingStatus.inProgress;
}
