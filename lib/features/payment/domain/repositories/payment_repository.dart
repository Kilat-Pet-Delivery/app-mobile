import '../../data/models/payment_model.dart';

abstract class PaymentRepository {
  Future<PaymentModel> initiatePayment({
    required String bookingId,
    required int amountCents,
    required String currency,
    required String customerEmail,
  });
  Future<PaymentModel> getPayment(String paymentId);
  Future<PaymentModel> getPaymentByBooking(String bookingId);
}
