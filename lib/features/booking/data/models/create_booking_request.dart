import 'address_model.dart';
import 'pet_spec_model.dart';

class CreateBookingRequest {
  final PetSpecModel petSpec;
  final AddressModel pickupAddress;
  final AddressModel dropoffAddress;
  final DateTime? scheduledAt;
  final String? notes;

  const CreateBookingRequest({
    required this.petSpec,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.scheduledAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'pet_spec': petSpec.toJson(),
        'pickup_address': pickupAddress.toJson(),
        'dropoff_address': dropoffAddress.toJson(),
        if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}
