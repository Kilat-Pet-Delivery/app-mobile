import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<AuthResponseModel> login(LoginRequest request) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return AuthResponseModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return AuthResponseModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post('/api/v1/auth/logout');
    } on DioException {
      // Ignore logout errors — we'll clear tokens locally anyway
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.dio.get('/api/v1/auth/profile');
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return UserModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.put(
        '/api/v1/auth/profile',
        data: data,
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      return UserModel.fromJson(json['data'] as Map<String, dynamic>);
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
