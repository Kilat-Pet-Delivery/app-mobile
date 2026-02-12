class ApiError implements Exception {
  final String message;
  final String? detail;
  final int? statusCode;

  const ApiError({
    required this.message,
    this.detail,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiError(
      message: json['error'] as String? ?? 'Unknown error',
      detail: json['detail'] as String?,
      statusCode: statusCode,
    );
  }

  @override
  String toString() =>
      'ApiError($statusCode): $message${detail != null ? ' - $detail' : ''}';
}

class NetworkError implements Exception {
  final String message;
  const NetworkError(this.message);

  @override
  String toString() => 'NetworkError: $message';
}
