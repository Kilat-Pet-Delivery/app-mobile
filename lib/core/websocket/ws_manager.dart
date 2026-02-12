import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';

class TrackingUpdate {
  final String bookingId;
  final String runnerId;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double headingDegrees;
  final DateTime timestamp;

  const TrackingUpdate({
    required this.bookingId,
    required this.runnerId,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.headingDegrees,
    required this.timestamp,
  });

  factory TrackingUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingUpdate(
      bookingId: json['booking_id'] as String,
      runnerId: json['runner_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speedKmh: (json['speed_kmh'] as num).toDouble(),
      headingDegrees: (json['heading_degrees'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class WebSocketManager {
  final SecureStorageService _storage;
  final AppConfig _config;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  StreamController<TrackingUpdate>? _controller;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  String? _currentBookingId;
  static const _maxReconnectAttempts = 5;

  WebSocketManager({
    required SecureStorageService storage,
    required AppConfig config,
  })  : _storage = storage,
        _config = config;

  Stream<TrackingUpdate> connect(String bookingId) {
    _currentBookingId = bookingId;
    _reconnectAttempts = 0;
    _controller = StreamController<TrackingUpdate>.broadcast(
      onCancel: disconnect,
    );
    _doConnect(bookingId);
    return _controller!.stream;
  }

  Future<void> _doConnect(String bookingId) async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      _controller?.addError('No authentication token');
      return;
    }

    final wsUrl = '${_config.wsUrl}/ws/tracking/$bookingId?token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            _controller?.add(TrackingUpdate.fromJson(json));
            _reconnectAttempts = 0;
          } catch (e) {
            _controller?.addError('Failed to parse tracking update: $e');
          }
        },
        onError: (error) => _attemptReconnect(bookingId),
        onDone: () => _attemptReconnect(bookingId),
      );
    } catch (e) {
      _attemptReconnect(bookingId);
    }
  }

  void _attemptReconnect(String bookingId) {
    if (_controller?.isClosed ?? true) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _controller?.addError('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay =
        Duration(seconds: math.pow(2, _reconnectAttempts).toInt());

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _subscription?.cancel();
      _channel?.sink.close();
      _doConnect(bookingId);
    });
  }

  void disconnect() {
    _currentBookingId = null;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    if (!(_controller?.isClosed ?? true)) {
      _controller?.close();
    }
    _controller = null;
  }

  bool get isConnected => _channel != null && _currentBookingId != null;
}
