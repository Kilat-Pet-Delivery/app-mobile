import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_error.dart';
import '../../data/models/address_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/create_booking_request.dart';
import '../../data/models/pet_spec_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../payment/domain/repositories/payment_repository.dart';

// Events
abstract class CreateBookingEvent extends Equatable {
  const CreateBookingEvent();
  @override
  List<Object?> get props => [];
}

class PickupLocationSelected extends CreateBookingEvent {
  final AddressModel address;
  const PickupLocationSelected(this.address);
}

class DropoffLocationSelected extends CreateBookingEvent {
  final AddressModel address;
  const DropoffLocationSelected(this.address);
}

class PetDetailsUpdated extends CreateBookingEvent {
  final PetSpecModel petSpec;
  const PetDetailsUpdated(this.petSpec);
}

class NotesUpdated extends CreateBookingEvent {
  final String notes;
  const NotesUpdated(this.notes);
}

class BookingSubmitted extends CreateBookingEvent {
  final String customerEmail;
  const BookingSubmitted(this.customerEmail);
}

class BookingReset extends CreateBookingEvent {
  const BookingReset();
}

// Keep old events for backward compatibility
class PetDetailsSubmitted extends CreateBookingEvent {
  final PetSpecModel petSpec;
  const PetDetailsSubmitted(this.petSpec);
}

class AddressesSubmitted extends CreateBookingEvent {
  final AddressModel pickupAddress;
  final AddressModel dropoffAddress;
  const AddressesSubmitted(this.pickupAddress, this.dropoffAddress);
}

class StepChanged extends CreateBookingEvent {
  final int step;
  const StepChanged(this.step);
}

class ScheduleSelected extends CreateBookingEvent {
  final DateTime? scheduledAt;
  const ScheduleSelected(this.scheduledAt);
}

// State
class CreateBookingState extends Equatable {
  final int currentStep;
  final PetSpecModel? petSpec;
  final AddressModel? pickupAddress;
  final AddressModel? dropoffAddress;
  final DateTime? scheduledAt;
  final String notes;
  final int? estimatedPriceCents;
  final bool isSubmitting;
  final BookingModel? createdBooking;
  final String? errorMessage;

  const CreateBookingState({
    this.currentStep = 0,
    this.petSpec,
    this.pickupAddress,
    this.dropoffAddress,
    this.scheduledAt,
    this.notes = '',
    this.estimatedPriceCents,
    this.isSubmitting = false,
    this.createdBooking,
    this.errorMessage,
  });

  bool get canSubmit =>
      pickupAddress != null &&
      dropoffAddress != null &&
      petSpec != null;

  CreateBookingState copyWith({
    int? currentStep,
    PetSpecModel? petSpec,
    AddressModel? pickupAddress,
    AddressModel? dropoffAddress,
    DateTime? scheduledAt,
    bool clearSchedule = false,
    String? notes,
    int? estimatedPriceCents,
    bool clearPrice = false,
    bool? isSubmitting,
    BookingModel? createdBooking,
    String? errorMessage,
  }) {
    return CreateBookingState(
      currentStep: currentStep ?? this.currentStep,
      petSpec: petSpec ?? this.petSpec,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      scheduledAt: clearSchedule ? null : (scheduledAt ?? this.scheduledAt),
      notes: notes ?? this.notes,
      estimatedPriceCents: clearPrice ? null : (estimatedPriceCents ?? this.estimatedPriceCents),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdBooking: createdBooking ?? this.createdBooking,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        petSpec,
        pickupAddress,
        dropoffAddress,
        scheduledAt,
        notes,
        estimatedPriceCents,
        isSubmitting,
        createdBooking,
        errorMessage,
      ];
}

// Bloc
class CreateBookingBloc extends Bloc<CreateBookingEvent, CreateBookingState> {
  final BookingRepository _bookingRepository;
  final PaymentRepository _paymentRepository;

  CreateBookingBloc(this._bookingRepository, this._paymentRepository)
      : super(const CreateBookingState()) {
    on<PickupLocationSelected>(_onPickupLocation);
    on<DropoffLocationSelected>(_onDropoffLocation);
    on<PetDetailsUpdated>(_onPetDetailsUpdated);
    on<NotesUpdated>(_onNotes);
    on<BookingSubmitted>(_onSubmit);
    on<BookingReset>(_onReset);
    // Keep old handlers for compatibility
    on<PetDetailsSubmitted>(_onPetDetails);
    on<AddressesSubmitted>(_onAddresses);
    on<StepChanged>(_onStepChanged);
    on<ScheduleSelected>(_onSchedule);
  }

  void _onPickupLocation(
      PickupLocationSelected event, Emitter<CreateBookingState> emit) {
    final newState = state.copyWith(pickupAddress: event.address);
    emit(_recalculatePrice(newState));
  }

  void _onDropoffLocation(
      DropoffLocationSelected event, Emitter<CreateBookingState> emit) {
    final newState = state.copyWith(dropoffAddress: event.address);
    emit(_recalculatePrice(newState));
  }

  void _onPetDetailsUpdated(
      PetDetailsUpdated event, Emitter<CreateBookingState> emit) {
    final newState = state.copyWith(petSpec: event.petSpec);
    emit(_recalculatePrice(newState));
  }

  CreateBookingState _recalculatePrice(CreateBookingState s) {
    if (s.petSpec != null && s.pickupAddress != null && s.dropoffAddress != null) {
      final price = _estimatePrice(s.petSpec!, s.pickupAddress!, s.dropoffAddress!);
      return s.copyWith(estimatedPriceCents: price);
    }
    return s;
  }

  void _onNotes(NotesUpdated event, Emitter<CreateBookingState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onReset(BookingReset event, Emitter<CreateBookingState> emit) {
    emit(const CreateBookingState());
  }

  // Old handlers kept for backward compat
  void _onPetDetails(
      PetDetailsSubmitted event, Emitter<CreateBookingState> emit) {
    emit(state.copyWith(petSpec: event.petSpec, currentStep: 1));
  }

  void _onAddresses(
      AddressesSubmitted event, Emitter<CreateBookingState> emit) {
    final price = _estimatePrice(
        state.petSpec!, event.pickupAddress, event.dropoffAddress);
    emit(state.copyWith(
      pickupAddress: event.pickupAddress,
      dropoffAddress: event.dropoffAddress,
      estimatedPriceCents: price,
      currentStep: 2,
    ));
  }

  void _onStepChanged(StepChanged event, Emitter<CreateBookingState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onSchedule(ScheduleSelected event, Emitter<CreateBookingState> emit) {
    emit(state.copyWith(
      scheduledAt: event.scheduledAt,
      clearSchedule: event.scheduledAt == null,
    ));
  }

  Future<void> _onSubmit(
      BookingSubmitted event, Emitter<CreateBookingState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final request = CreateBookingRequest(
        petSpec: state.petSpec!,
        pickupAddress: state.pickupAddress!,
        dropoffAddress: state.dropoffAddress!,
        scheduledAt: state.scheduledAt,
        notes: state.notes.isNotEmpty ? state.notes : null,
      );

      final booking = await _bookingRepository.createBooking(request);

      // Auto-initiate payment
      try {
        await _paymentRepository.initiatePayment(
          bookingId: booking.id,
          amountCents: booking.estimatedPriceCents,
          currency: booking.currency,
          customerEmail: event.customerEmail,
        );
      } catch (_) {
        // Payment initiation failure is non-blocking
      }

      emit(state.copyWith(isSubmitting: false, createdBooking: booking));
    } on ApiError catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
          isSubmitting: false, errorMessage: 'Failed to create booking'));
    }
  }

  // Client-side pricing (mirrors backend pricing.go)
  int _estimatePrice(
      PetSpecModel pet, AddressModel pickup, AddressModel dropoff) {
    final distanceKm = _haversineDistance(
      pickup.latitude,
      pickup.longitude,
      dropoff.latitude,
      dropoff.longitude,
    );
    int totalCents = 500; // Base: RM 5.00
    totalCents += (distanceKm * 250).round(); // RM 2.50/km
    totalCents += _petSurcharge(pet.petType);
    totalCents += _crateSurcharge(_determineCrateSize(pet.weightKg));
    return totalCents;
  }

  int _petSurcharge(String petType) {
    switch (petType) {
      case 'dog':
        return 500;
      case 'cat':
        return 300;
      case 'bird':
        return 200;
      case 'reptile':
        return 800;
      case 'rabbit':
        return 300;
      default:
        return 500;
    }
  }

  int _crateSurcharge(String crateSize) {
    switch (crateSize) {
      case 'small':
        return 0;
      case 'medium':
        return 500;
      case 'large':
        return 1000;
      case 'xlarge':
        return 2000;
      default:
        return 0;
    }
  }

  String _determineCrateSize(double weightKg) {
    if (weightKg <= 5) return 'small';
    if (weightKg <= 15) return 'medium';
    if (weightKg <= 30) return 'large';
    return 'xlarge';
  }

  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
