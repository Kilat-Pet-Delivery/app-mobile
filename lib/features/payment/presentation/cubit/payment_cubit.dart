import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../domain/repositories/payment_repository.dart';

// State
abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final PaymentModel payment;
  const PaymentLoaded(this.payment);
  @override
  List<Object?> get props => [payment.id, payment.escrowStatus];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _repository;

  PaymentCubit(this._repository) : super(PaymentInitial());

  Future<void> loadPaymentForBooking(String bookingId) async {
    emit(PaymentLoading());
    try {
      final payment = await _repository.getPaymentByBooking(bookingId);
      emit(PaymentLoaded(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> initiatePayment({
    required String bookingId,
    required int amountCents,
    required String customerEmail,
  }) async {
    emit(PaymentLoading());
    try {
      final payment = await _repository.initiatePayment(
        bookingId: bookingId,
        amountCents: amountCents,
        currency: 'MYR',
        customerEmail: customerEmail,
      );
      emit(PaymentLoaded(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
