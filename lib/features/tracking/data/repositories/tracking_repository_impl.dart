import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../models/tracking_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final ApiClient _client;

  TrackingRepositoryImpl(this._client);

  @override
  Future<TrackingModel> getTracking(String bookingId) async {
    try {
      final response =
          await _client.dio.get('/api/v1/tracking/$bookingId');
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return TrackingModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> getRouteGeoJSON(String bookingId) async {
    try {
      final response =
          await _client.dio.get('/api/v1/tracking/$bookingId/route');
      // Route endpoint returns raw GeoJSON
      if (response.data is String) return response.data as String;
      return response.data.toString();
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
