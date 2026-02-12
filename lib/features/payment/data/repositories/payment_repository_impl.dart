import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _client;

  PaymentRepositoryImpl(this._client);

  @override
  Future<PaymentModel> initiatePayment({
    required String bookingId,
    required int amountCents,
    required String currency,
    required String customerEmail,
  }) async {
    try {
      final response = await _client.dio.post(
        '/api/v1/payments/initiate',
        data: {
          'booking_id': bookingId,
          'amount_cents': amountCents,
          'currency': currency,
          'customer_email': customerEmail,
        },
      );
      return _parsePayment(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      final response = await _client.dio.get('/api/v1/payments/$paymentId');
      return _parsePayment(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentModel> getPaymentByBooking(String bookingId) async {
    try {
      final response =
          await _client.dio.get('/api/v1/payments/booking/$bookingId');
      return _parsePayment(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  PaymentModel _parsePayment(Response response) {
    final json = response.data as Map<String, dynamic>;
    if (json['success'] != true) {
      throw ApiError.fromJson(json, statusCode: response.statusCode);
    }
    return PaymentModel.fromJson(json['data'] as Map<String, dynamic>);
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
