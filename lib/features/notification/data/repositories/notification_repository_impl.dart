import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<PaginatedResult<NotificationModel>> listNotifications({
    required int page,
    int limit = 20,
  }) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      final items = (json['data'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>? ??
            {'total': 0, 'page': 1, 'limit': 20, 'total_pages': 1},
      );
      return PaginatedResult(items: items, pagination: pagination);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _client.dio.put(
        '/api/v1/notifications/$notificationId/read',
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<NotificationPreferenceModel> getPreferences() async {
    try {
      final response = await _client.dio.get(
        '/api/v1/notifications/preferences',
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return NotificationPreferenceModel.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updatePreferences({
    required bool enablePush,
    required bool enableSms,
    required bool enableEmail,
  }) async {
    try {
      final response = await _client.dio.put(
        '/api/v1/notifications/preferences',
        data: {
          'enable_push': enablePush,
          'enable_sms': enableSms,
          'enable_email': enableEmail,
        },
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> registerFcmToken(String token) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/notifications/fcm-token',
        data: {'token': token},
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      return ApiError.fromJson(
        e.response!.data as Map<String, dynamic>,
        statusCode: e.response!.statusCode,
      );
    }
    return NetworkError('Connection failed: ${e.message}');
  }
}
