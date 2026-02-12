import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../cubit/notification_preferences_cubit.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationPreferencesCubit>().loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: BlocBuilder<NotificationPreferencesCubit,
          NotificationPreferencesState>(
        builder: (context, state) {
          if (state is NotificationPreferencesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationPreferencesError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<NotificationPreferencesCubit>()
                  .loadPreferences(),
            );
          }

          final prefs = state is NotificationPreferencesLoaded
              ? state.preferences
              : state is NotificationPreferencesSaving
                  ? state.preferences
                  : null;

          if (prefs == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isSaving = state is NotificationPreferencesSaving;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Notification Channels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you want to receive notifications.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _ChannelToggle(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications on this device',
                value: prefs.enablePush,
                enabled: !isSaving,
                onChanged: (val) => context
                    .read<NotificationPreferencesCubit>()
                    .updatePreferences(enablePush: val),
              ),
              const Divider(),
              _ChannelToggle(
                icon: Icons.sms,
                title: 'SMS Notifications',
                subtitle: 'Receive SMS to your registered phone number',
                value: prefs.enableSms,
                enabled: !isSaving,
                onChanged: (val) => context
                    .read<NotificationPreferencesCubit>()
                    .updatePreferences(enableSms: val),
              ),
              const Divider(),
              _ChannelToggle(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive email notifications',
                value: prefs.enableEmail,
                enabled: !isSaving,
                onChanged: (val) => context
                    .read<NotificationPreferencesCubit>()
                    .updatePreferences(enableEmail: val),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChannelToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ChannelToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.primary,
    );
  }
}
