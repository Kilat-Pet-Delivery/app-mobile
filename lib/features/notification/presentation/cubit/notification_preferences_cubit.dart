import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_preference_model.dart';
import '../../domain/repositories/notification_repository.dart';

// ── State ──

abstract class NotificationPreferencesState extends Equatable {
  const NotificationPreferencesState();

  @override
  List<Object?> get props => [];
}

class NotificationPreferencesInitial extends NotificationPreferencesState {}

class NotificationPreferencesLoading extends NotificationPreferencesState {}

class NotificationPreferencesLoaded extends NotificationPreferencesState {
  final NotificationPreferenceModel preferences;

  const NotificationPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [
        preferences.enablePush,
        preferences.enableSms,
        preferences.enableEmail,
      ];
}

class NotificationPreferencesError extends NotificationPreferencesState {
  final String message;

  const NotificationPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationPreferencesSaving extends NotificationPreferencesState {
  final NotificationPreferenceModel preferences;

  const NotificationPreferencesSaving(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

// ── Cubit ──

class NotificationPreferencesCubit
    extends Cubit<NotificationPreferencesState> {
  final NotificationRepository _repository;

  NotificationPreferencesCubit(this._repository)
      : super(NotificationPreferencesInitial());

  Future<void> loadPreferences() async {
    emit(NotificationPreferencesLoading());
    try {
      final prefs = await _repository.getPreferences();
      emit(NotificationPreferencesLoaded(prefs));
    } catch (e) {
      emit(NotificationPreferencesError(e.toString()));
    }
  }

  Future<void> updatePreferences({
    bool? enablePush,
    bool? enableSms,
    bool? enableEmail,
  }) async {
    final current = state;
    if (current is! NotificationPreferencesLoaded) return;

    final updated = current.preferences.copyWith(
      enablePush: enablePush,
      enableSms: enableSms,
      enableEmail: enableEmail,
    );

    emit(NotificationPreferencesSaving(updated));

    try {
      await _repository.updatePreferences(
        enablePush: updated.enablePush,
        enableSms: updated.enableSms,
        enableEmail: updated.enableEmail,
      );
      emit(NotificationPreferencesLoaded(updated));
    } catch (e) {
      // Revert to previous state on failure.
      emit(NotificationPreferencesLoaded(current.preferences));
    }
  }
}
