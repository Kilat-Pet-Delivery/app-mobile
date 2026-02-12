import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_error.dart';
import '../../data/models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../payment/data/models/payment_model.dart';
import '../../../payment/domain/repositories/payment_repository.dart';

// State
abstract class BookingDetailState extends Equatable {
  const BookingDetailState();
  @override
  List<Object?> get props => [];
}

class BookingDetailInitial extends BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailLoaded extends BookingDetailState {
  final BookingModel booking;
  final PaymentModel? payment;
  const BookingDetailLoaded({required this.booking, this.payment});
  @override
  List<Object?> get props => [booking.id, booking.status, payment?.id];
}

class BookingDetailError extends BookingDetailState {
  final String message;
  const BookingDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class BookingDetailActionLoading extends BookingDetailState {
  final BookingModel booking;
  final PaymentModel? payment;
  const BookingDetailActionLoading({required this.booking, this.payment});
  @override
  List<Object?> get props => [booking.id];
}

// Cubit
class BookingDetailCubit extends Cubit<BookingDetailState> {
  final BookingRepository _bookingRepository;
  final PaymentRepository _paymentRepository;

  BookingDetailCubit(this._bookingRepository, this._paymentRepository)
      : super(BookingDetailInitial());

  Future<void> loadBooking(String bookingId) async {
    emit(BookingDetailLoading());
    try {
      final booking = await _bookingRepository.getBooking(bookingId);
      PaymentModel? payment;
      try {
        payment = await _paymentRepository.getPaymentByBooking(bookingId);
      } catch (_) {
        // Payment might not exist yet
      }
      emit(BookingDetailLoaded(booking: booking, payment: payment));
    } on ApiError catch (e) {
      emit(BookingDetailError(e.message));
    } catch (e) {
      emit(BookingDetailError('Failed to load booking'));
    }
  }

  Future<void> confirmDelivery(String bookingId) async {
    final current = state;
    if (current is! BookingDetailLoaded) return;

    emit(BookingDetailActionLoading(
        booking: current.booking, payment: current.payment));
    try {
      final booking = await _bookingRepository.confirmDelivery(bookingId);
      emit(BookingDetailLoaded(booking: booking, payment: current.payment));
    } on ApiError catch (e) {
      emit(BookingDetailLoaded(
          booking: current.booking, payment: current.payment));
      // Error will be shown via a snackbar in the UI
      emit(BookingDetailError(e.message));
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    final current = state;
    if (current is! BookingDetailLoaded) return;

    emit(BookingDetailActionLoading(
        booking: current.booking, payment: current.payment));
    try {
      final booking =
          await _bookingRepository.cancelBooking(bookingId, reason);
      emit(BookingDetailLoaded(booking: booking, payment: current.payment));
    } on ApiError catch (e) {
      emit(BookingDetailLoaded(
          booking: current.booking, payment: current.payment));
      emit(BookingDetailError(e.message));
    }
  }
}
