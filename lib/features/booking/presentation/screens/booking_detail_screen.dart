import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/booking_status.dart';
import '../bloc/booking_detail_cubit.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingDetailCubit>().loadBooking(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: BlocConsumer<BookingDetailCubit, BookingDetailState>(
        listener: (context, state) {
          if (state is BookingDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingDetailError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<BookingDetailCubit>()
                  .loadBooking(widget.bookingId),
            );
          }

          final booking = state is BookingDetailLoaded
              ? state.booking
              : state is BookingDetailActionLoading
                  ? state.booking
                  : null;
          final payment = state is BookingDetailLoaded
              ? state.payment
              : state is BookingDetailActionLoading
                  ? state.payment
                  : null;

          if (booking == null) return const SizedBox.shrink();
          final status = booking.bookingStatus;
          final isActionLoading = state is BookingDetailActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.bookingNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Timeline
                _buildTimeline(booking),
                const SizedBox(height: 20),

                // Pet Details
                _SectionCard(
                  title: 'Pet Details',
                  icon: Icons.pets,
                  children: [
                    _InfoRow('Name', booking.petSpec.name),
                    _InfoRow('Type', booking.petSpec.petTypeDisplay),
                    if (booking.petSpec.breed.isNotEmpty)
                      _InfoRow('Breed', booking.petSpec.breed),
                    _InfoRow('Weight', '${booking.petSpec.weightKg} kg'),
                    if (booking.petSpec.specialNeeds.isNotEmpty)
                      _InfoRow('Special Needs', booking.petSpec.specialNeeds),
                  ],
                ),
                const SizedBox(height: 12),

                // Addresses
                _SectionCard(
                  title: 'Route',
                  icon: Icons.route,
                  children: [
                    _InfoRow('Pickup', booking.pickupAddress.fullDisplay),
                    _InfoRow('Dropoff', booking.dropoffAddress.fullDisplay),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                _SectionCard(
                  title: 'Payment',
                  icon: Icons.payment,
                  children: [
                    _InfoRow('Estimated',
                        CurrencyFormatter.formatMYR(booking.estimatedPriceCents)),
                    if (booking.finalPriceCents != null)
                      _InfoRow('Final',
                          CurrencyFormatter.formatMYR(booking.finalPriceCents!)),
                    if (payment != null)
                      _InfoRow('Escrow', payment.statusDisplay),
                    if (payment == null && status == BookingStatus.requested) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/bookings/${booking.id}/payment',
                            extra: {
                              'amountCents': booking.estimatedPriceCents,
                              'currency': booking.currency,
                            },
                          ),
                          icon: const Icon(Icons.payment),
                          label: const Text('Pay Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Notes',
                    icon: Icons.note,
                    children: [Text(booking.notes!)],
                  ),
                  const SizedBox(height: 12),
                ],

                if (booking.cancelNote != null && booking.cancelNote!.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Cancellation',
                    icon: Icons.cancel,
                    children: [
                      Text(booking.cancelNote!,
                          style: const TextStyle(color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Actions
                const SizedBox(height: 8),
                if (status.canTrack)
                  PrimaryButton(
                    label: 'Track Live',
                    icon: Icons.map,
                    onPressed: () =>
                        context.push('/bookings/${booking.id}/tracking'),
                  ),
                if (status.canTrack) const SizedBox(height: 8),

                if (status.canConfirmDelivery)
                  PrimaryButton(
                    label: 'Confirm Delivery',
                    icon: Icons.check_circle,
                    isLoading: isActionLoading,
                    onPressed: () => _showConfirmDialog(context, booking.id),
                  ),
                if (status.canConfirmDelivery) const SizedBox(height: 8),

                if (status.canCancel)
                  OutlinedButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () => _showCancelDialog(context, booking.id),
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    label: const Text('Cancel Booking',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(booking) {
    final steps = [
      _TimelineStep('Requested', booking.createdAt, true),
      _TimelineStep(
        'Accepted',
        booking.bookingStatus.index >= BookingStatus.accepted.index
            ? booking.updatedAt
            : null,
        booking.bookingStatus.index >= BookingStatus.accepted.index,
      ),
      _TimelineStep(
        'Picked Up',
        booking.pickedUpAt,
        booking.pickedUpAt != null,
      ),
      _TimelineStep(
        'Delivered',
        booking.deliveredAt,
        booking.deliveredAt != null,
      ),
      _TimelineStep(
        'Completed',
        booking.bookingStatus == BookingStatus.completed ? booking.updatedAt : null,
        booking.bookingStatus == BookingStatus.completed,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Timeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final step = entry.value;
              final isLast = entry.key == steps.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        step.completed ? Icons.check_circle : Icons.circle_outlined,
                        size: 20,
                        color: step.completed
                            ? AppColors.success
                            : AppColors.divider,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: step.completed
                              ? AppColors.success
                              : AppColors.divider,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.label,
                              style: TextStyle(
                                fontWeight: step.completed
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: step.completed
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              )),
                          if (step.timestamp != null)
                            Text(
                              DateFormatter.dateTime(step.timestamp!),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: const Text(
            'Are you sure you want to confirm the delivery? This will release the payment to the runner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<BookingDetailCubit>().confirmDelivery(bookingId);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String bookingId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              this.context.read<BookingDetailCubit>().cancelBooking(
                    bookingId,
                    reasonController.text.isNotEmpty
                        ? reasonController.text
                        : 'Cancelled by owner',
                  );
            },
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final DateTime? timestamp;
  final bool completed;
  const _TimelineStep(this.label, this.timestamp, this.completed);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
