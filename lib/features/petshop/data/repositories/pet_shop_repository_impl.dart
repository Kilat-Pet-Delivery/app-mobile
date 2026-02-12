import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/pet_shop_repository.dart';
import '../models/pet_shop_model.dart';

class PetShopRepositoryImpl implements PetShopRepository {
  final ApiClient _client;

  PetShopRepositoryImpl(this._client);

  @override
  Future<List<PetShopModel>> listPetShops({String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      final response = await _client.dio.get(
        '/api/v1/petshops',
        queryParameters: queryParams,
      );
      return _parseList(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PetShopModel> getPetShop(String id) async {
    try {
      final response = await _client.dio.get('/api/v1/petshops/$id');
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return PetShopModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PetShopModel>> getNearbyPetShops(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/petshops/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
        },
      );
      return _parseList(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  List<PetShopModel> _parseList(Response response) {
    final json = response.data as Map<String, dynamic>;
    if (json['success'] != true) {
      throw ApiError.fromJson(json, statusCode: response.statusCode);
    }
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => PetShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
