import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/domain/repositories/booking_repository.dart';

// State
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel user;
  final List<BookingModel> activeBookings;
  const HomeLoaded({required this.user, required this.activeBookings});
  @override
  List<Object?> get props => [user.id, activeBookings.length];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class HomeCubit extends Cubit<HomeState> {
  final BookingRepository _bookingRepository;
  final AuthRepository _authRepository;

  HomeCubit(this._bookingRepository, this._authRepository)
      : super(HomeInitial());

  Future<void> loadDashboard() async {
    emit(HomeLoading());
    try {
      final user = await _authRepository.getProfile();
      final bookings = await _bookingRepository.listBookings(page: 1, limit: 5);
      final activeBookings = bookings.items
          .where((b) => b.bookingStatus.isActive)
          .toList();
      emit(HomeLoaded(user: user, activeBookings: activeBookings));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
