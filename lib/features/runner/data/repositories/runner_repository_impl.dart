import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/runner_repository.dart';
import '../models/runner_model.dart';

class RunnerRepositoryImpl implements RunnerRepository {
  final ApiClient _client;

  RunnerRepositoryImpl(this._client);

  @override
  Future<List<RunnerModel>> getNearbyRunners(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  }) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/runners/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
        },
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      final data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => RunnerModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
