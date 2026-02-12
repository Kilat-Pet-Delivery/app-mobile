class NotificationModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String eventType;
  final String title;
  final String body;
  final List<String> channelsSent;
  final List<String> channelsFailed;
  final String status;
  final bool isRead;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.eventType,
    required this.title,
    required this.body,
    this.channelsSent = const [],
    this.channelsFailed = const [],
    required this.status,
    required this.isRead,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      bookingId: json['booking_id'] as String?,
      eventType: json['event_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      channelsSent: (json['channels_sent'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      channelsFailed: (json['channels_failed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: json['status'] as String? ?? 'sent',
      isRead: json['is_read'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Returns a user-friendly icon based on event type.
  String get eventCategory {
    if (eventType.startsWith('booking.')) return 'booking';
    if (eventType.startsWith('payment.')) return 'payment';
    if (eventType.startsWith('tracking.')) return 'tracking';
    return 'general';
  }
}
