import '../../../../core/network/api_response.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/notification_preference_model.dart';

abstract class NotificationRepository {
  Future<PaginatedResult<NotificationModel>> listNotifications({
    required int page,
    int limit = 20,
  });

  Future<void> markAsRead(String notificationId);

  Future<NotificationPreferenceModel> getPreferences();

  Future<void> updatePreferences({
    required bool enablePush,
    required bool enableSms,
    required bool enableEmail,
  });

  Future<void> registerFcmToken(String token);
}
