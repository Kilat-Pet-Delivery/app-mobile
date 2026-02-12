import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';
import '../models/create_booking_request.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _client;

  BookingRepositoryImpl(this._client);

  @override
  Future<BookingModel> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/bookings',
        data: request.toJson(),
      );
      return _parseBooking(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResult<BookingModel>> listBookings({
    required int page,
    int limit = 20,
  }) async {
    try {
      final response = await _client.dio.get(
        '/api/v1/bookings',
        queryParameters: {'page': page, 'limit': limit},
      );
      final json = response.data as Map<String, dynamic>;
      if (json['success'] != true) {
        throw ApiError.fromJson(json, statusCode: response.statusCode);
      }
      final items = (json['data'] as List<dynamic>)
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {'total': 0, 'page': 1, 'limit': 20, 'total_pages': 1},
      );
      return PaginatedResult(items: items, pagination: pagination);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingModel> getBooking(String bookingId) async {
    try {
      final response = await _client.dio.get('/api/v1/bookings/$bookingId');
      return _parseBooking(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingModel> confirmDelivery(String bookingId) async {
    try {
      final response =
          await _client.dio.post('/api/v1/bookings/$bookingId/confirm');
      return _parseBooking(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );
      return _parseBooking(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  BookingModel _parseBooking(Response response) {
    final json = response.data as Map<String, dynamic>;
    if (json['success'] != true) {
      throw ApiError.fromJson(json, statusCode: response.statusCode);
    }
    return BookingModel.fromJson(json['data'] as Map<String, dynamic>);
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
