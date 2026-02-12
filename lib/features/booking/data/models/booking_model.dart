import '../../domain/entities/booking_status.dart';
import 'address_model.dart';
import 'pet_spec_model.dart';

class BookingModel {
  final String id;
  final String bookingNumber;
  final String ownerId;
  final String? runnerId;
  final String status;
  final PetSpecModel petSpec;
  final CrateRequirementModel? crateRequirement;
  final AddressModel pickupAddress;
  final AddressModel dropoffAddress;
  final RouteSpecModel? routeSpec;
  final int estimatedPriceCents;
  final int? finalPriceCents;
  final String currency;
  final DateTime? scheduledAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelNote;
  final String? notes;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.ownerId,
    this.runnerId,
    required this.status,
    required this.petSpec,
    this.crateRequirement,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.routeSpec,
    required this.estimatedPriceCents,
    this.finalPriceCents,
    required this.currency,
    this.scheduledAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelNote,
    this.notes,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  BookingStatus get bookingStatus => BookingStatus.fromString(status);

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      bookingNumber: json['booking_number'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      runnerId: json['runner_id'] as String?,
      status: json['status'] as String,
      petSpec: PetSpecModel.fromJson(
        json['pet_spec'] as Map<String, dynamic>? ?? {},
      ),
      crateRequirement: json['crate_requirement'] != null
          ? CrateRequirementModel.fromJson(
              json['crate_requirement'] as Map<String, dynamic>)
          : null,
      pickupAddress: AddressModel.fromJson(
        json['pickup_address'] as Map<String, dynamic>? ?? {},
      ),
      dropoffAddress: AddressModel.fromJson(
        json['dropoff_address'] as Map<String, dynamic>? ?? {},
      ),
      routeSpec: json['route_spec'] != null
          ? RouteSpecModel.fromJson(json['route_spec'] as Map<String, dynamic>)
          : null,
      estimatedPriceCents: json['estimated_price_cents'] as int? ?? 0,
      finalPriceCents: json['final_price_cents'] as int?,
      currency: json['currency'] as String? ?? 'MYR',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancelNote: json['cancel_note'] as String?,
      notes: json['notes'] as String?,
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class CrateRequirementModel {
  final String minimumSize;
  final bool needsVentilation;
  final bool needsTempControl;
  final double minimumWeightCapacity;

  const CrateRequirementModel({
    required this.minimumSize,
    required this.needsVentilation,
    required this.needsTempControl,
    required this.minimumWeightCapacity,
  });

  factory CrateRequirementModel.fromJson(Map<String, dynamic> json) {
    return CrateRequirementModel(
      minimumSize: json['minimum_size'] as String? ?? 'small',
      needsVentilation: json['needs_ventilation'] as bool? ?? true,
      needsTempControl: json['needs_temp_control'] as bool? ?? false,
      minimumWeightCapacity:
          (json['minimum_weight_capacity'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RouteSpecModel {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double distanceKm;
  final int estimatedDurationMin;
  final String? polyline;

  const RouteSpecModel({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.distanceKm,
    required this.estimatedDurationMin,
    this.polyline,
  });

  factory RouteSpecModel.fromJson(Map<String, dynamic> json) {
    return RouteSpecModel(
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0,
      dropoffLat: (json['dropoff_lat'] as num?)?.toDouble() ?? 0,
      dropoffLng: (json['dropoff_lng'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      estimatedDurationMin: json['estimated_duration_min'] as int? ?? 0,
      polyline: json['polyline'] as String?,
    );
  }
}
