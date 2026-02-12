import 'dart:io' show Platform;

class AppConfig {
  final String baseUrl;
  final String wsUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;

  const AppConfig({
    required this.baseUrl,
    required this.wsUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.enableLogging = true,
  });

  factory AppConfig.dev() {
    // Android emulator uses 10.0.2.2, iOS simulator uses localhost
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return AppConfig(
      baseUrl: 'http://$host:8080',
      wsUrl: 'ws://$host:8080',
    );
  }

  factory AppConfig.staging({required String host}) {
    return AppConfig(
      baseUrl: 'https://$host',
      wsUrl: 'wss://$host',
      enableLogging: true,
    );
  }

  factory AppConfig.production({required String host}) {
    return AppConfig(
      baseUrl: 'https://$host',
      wsUrl: 'wss://$host',
      enableLogging: false,
    );
  }
}
