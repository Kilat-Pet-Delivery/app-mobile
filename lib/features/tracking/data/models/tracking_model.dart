class TrackingModel {
  final String id;
  final String bookingId;
  final String runnerId;
  final String status;
  final double totalDistanceKm;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<WaypointModel> waypoints;

  const TrackingModel({
    required this.id,
    required this.bookingId,
    required this.runnerId,
    required this.status,
    required this.totalDistanceKm,
    required this.startedAt,
    this.completedAt,
    this.waypoints = const [],
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      runnerId: json['runner_id'] as String,
      status: json['status'] as String,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((w) => WaypointModel.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WaypointModel {
  final String id;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double headingDegrees;
  final DateTime recordedAt;

  const WaypointModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.headingDegrees,
    required this.recordedAt,
  });

  factory WaypointModel.fromJson(Map<String, dynamic> json) {
    return WaypointModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speedKmh: (json['speed_kmh'] as num?)?.toDouble() ?? 0,
      headingDegrees: (json['heading_degrees'] as num?)?.toDouble() ?? 0,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}
