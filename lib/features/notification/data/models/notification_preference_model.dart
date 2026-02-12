class NotificationPreferenceModel {
  final String id;
  final String userId;
  final bool enablePush;
  final bool enableSms;
  final bool enableEmail;
  final String? fcmToken;
  final String? phoneNumber;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationPreferenceModel({
    required this.id,
    required this.userId,
    required this.enablePush,
    required this.enableSms,
    required this.enableEmail,
    this.fcmToken,
    this.phoneNumber,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      enablePush: json['enable_push'] as bool? ?? true,
      enableSms: json['enable_sms'] as bool? ?? false,
      enableEmail: json['enable_email'] as bool? ?? true,
      fcmToken: json['fcm_token'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'enable_push': enablePush,
        'enable_sms': enableSms,
        'enable_email': enableEmail,
      };

  NotificationPreferenceModel copyWith({
    bool? enablePush,
    bool? enableSms,
    bool? enableEmail,
  }) {
    return NotificationPreferenceModel(
      id: id,
      userId: userId,
      enablePush: enablePush ?? this.enablePush,
      enableSms: enableSms ?? this.enableSms,
      enableEmail: enableEmail ?? this.enableEmail,
      fcmToken: fcmToken,
      phoneNumber: phoneNumber,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
