import '../../../../core/network/api_response.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/create_booking_request.dart';

abstract class BookingRepository {
  Future<BookingModel> createBooking(CreateBookingRequest request);
  Future<PaginatedResult<BookingModel>> listBookings({
    required int page,
    int limit = 20,
  });
  Future<BookingModel> getBooking(String bookingId);
  Future<BookingModel> confirmDelivery(String bookingId);
  Future<BookingModel> cancelBooking(String bookingId, String reason);
}
