import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/location_picker_screen.dart';
import '../../data/models/address_model.dart';
import '../../data/models/pet_spec_model.dart';
import '../bloc/create_booking_bloc.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _petNameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedPetType = 'dog';

  @override
  void dispose() {
    _petNameCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation(BuildContext context, {required bool isPickup}) async {
    final bloc = context.read<CreateBookingBloc>();
    final existing = isPickup ? bloc.state.pickupAddress : bloc.state.dropoffAddress;

    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: isPickup ? 'Set Pickup Location' : 'Set Dropoff Location',
          initialLocation: existing != null
              ? LatLng(existing.latitude, existing.longitude)
              : null,
          initialLabel: existing?.line1,
        ),
      ),
    );

    if (result != null && mounted) {
      final address = AddressModel(
        line1: result.label,
        city: 'Kuala Lumpur',
        state: 'Malaysia',
        country: 'Malaysia',
        latitude: result.location.latitude,
        longitude: result.location.longitude,
      );

      if (isPickup) {
        bloc.add(PickupLocationSelected(address));
      } else {
        bloc.add(DropoffLocationSelected(address));
      }
    }
  }

  void _updatePetSpec() {
    final name = _petNameCtrl.text.trim();
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    if (name.isNotEmpty && weight > 0) {
      context.read<CreateBookingBloc>().add(PetDetailsUpdated(
            PetSpecModel(
              petType: _selectedPetType,
              name: name,
              breed: '',
              weightKg: weight,
              ageMonths: 0,
              specialNeeds: '',
            ),
          ));
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CreateBookingBloc>();
    if (bloc.state.pickupAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set pickup location')),
      );
      return;
    }
    if (bloc.state.dropoffAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set dropoff location')),
      );
      return;
    }

    // Ensure pet spec is up to date
    _updatePetSpec();

    // Small delay to let the bloc process the pet details update
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<CreateBookingBloc>().add(const BookingSubmitted(''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateBookingBloc, CreateBookingState>(
      listener: (context, state) {
        if (state.createdBooking != null) {
          final booking = state.createdBooking!;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking created! Proceed to payment.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/bookings/${booking.id}/payment', extra: {
            'amountCents': booking.estimatedPriceCents,
            'currency': booking.currency,
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('New Booking')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Section
                  _SectionHeader(icon: Icons.route, title: 'Route'),
                  const SizedBox(height: 8),
                  _LocationCard(
                    label: 'Pickup Location',
                    address: state.pickupAddress,
                    color: AppColors.success,
                    icon: Icons.trip_origin,
                    onTap: () => _pickLocation(context, isPickup: true),
                  ),
                  // Dotted line connector
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => Container(
                          width: 2,
                          height: 6,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: AppColors.divider,
                        ),
                      ),
                    ),
                  ),
                  _LocationCard(
                    label: 'Dropoff Location',
                    address: state.dropoffAddress,
                    color: AppColors.error,
                    icon: Icons.location_on,
                    onTap: () => _pickLocation(context, isPickup: false),
                  ),
                  const SizedBox(height: 24),

                  // Pet Section
                  _SectionHeader(icon: Icons.pets, title: 'Pet Details'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedPetType,
                            decoration: const InputDecoration(
                              labelText: 'Pet Type',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'dog', child: Text('Dog')),
                              DropdownMenuItem(value: 'cat', child: Text('Cat')),
                              DropdownMenuItem(value: 'bird', child: Text('Bird')),
                              DropdownMenuItem(value: 'rabbit', child: Text('Rabbit')),
                              DropdownMenuItem(value: 'reptile', child: Text('Reptile')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                            onChanged: (v) {
                              setState(() => _selectedPetType = v!);
                              _updatePetSpec();
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _petNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Pet Name',
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => Validators.required(v, 'Pet name'),
                            onChanged: (_) => _updatePetSpec(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _weightCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(Icons.monitor_weight),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                Validators.positiveNumber(v, 'Weight'),
                            onChanged: (_) => _updatePetSpec(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notes Section
                  _SectionHeader(icon: Icons.note, title: 'Notes (optional)'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Special instructions for the runner...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (v) => context
                            .read<CreateBookingBloc>()
                            .add(NotesUpdated(v)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Estimate
                  if (state.estimatedPriceCents != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatMYR(
                                state.estimatedPriceCents!),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: state.isSubmitting ? null : _onSubmit,
                      icon: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(
                        state.isSubmitting ? 'Creating...' : 'Book Now',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String label;
  final AddressModel? address;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _LocationCard({
    required this.label,
    required this.address,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address?.line1 ?? 'Tap to set location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: address != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (address != null)
                      Text(
                        '${address!.latitude.toStringAsFixed(4)}, ${address!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                address != null ? Icons.check_circle : Icons.chevron_right,
                color: address != null ? AppColors.success : AppColors.divider,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
