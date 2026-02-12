import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/booking_status.dart';
import '../bloc/booking_list_bloc.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<BookingListBloc>()
        .add(const BookingListFetchRequested(page: 1));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<BookingListBloc>().state;
      if (state.status != BlocStatus.loading &&
          !state.hasReachedMax &&
          state.pagination != null) {
        context.read<BookingListBloc>().add(
              BookingListFetchRequested(page: state.pagination!.page + 1),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bookings/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<BookingListBloc, BookingListState>(
        builder: (context, state) {
          return Column(
            children: [
              // Filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: state.statusFilter == null,
                      onTap: () => context.read<BookingListBloc>().add(
                            BookingListFilterChanged(state.statusFilter),
                          ),
                    ),
                    ...BookingStatus.values.map(
                      (s) => _FilterChip(
                        label: s.displayName,
                        selected: state.statusFilter == s,
                        color: s.color,
                        onTap: () => context
                            .read<BookingListBloc>()
                            .add(BookingListFilterChanged(s)),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: _buildList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, BookingListState state) {
    if (state.status == BlocStatus.loading && state.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == BlocStatus.error && state.bookings.isEmpty) {
      return ErrorView(
        message: state.errorMessage ?? 'Failed to load bookings',
        onRetry: () => context
            .read<BookingListBloc>()
            .add(const BookingListRefreshRequested()),
      );
    }

    final bookings = state.filteredBookings;
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No bookings found',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<BookingListBloc>()
            .add(const BookingListRefreshRequested());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: bookings.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= bookings.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final booking = bookings[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor:
                    booking.bookingStatus.color.withValues(alpha: 0.2),
                child: Icon(
                  _petIcon(booking.petSpec.petType),
                  color: booking.bookingStatus.color,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.petSpec.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  StatusBadge(status: booking.bookingStatus),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(booking.bookingNumber),
                  Text(
                    '${CurrencyFormatter.formatMYR(booking.estimatedPriceCents)} - ${DateFormatter.relative(booking.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onTap: () => context.push('/bookings/${booking.id}'),
            ),
          );
        },
      ),
    );
  }

  IconData _petIcon(String petType) {
    switch (petType) {
      case 'dog': return Icons.pets;
      case 'cat': return Icons.pets;
      case 'bird': return Icons.flutter_dash;
      case 'rabbit': return Icons.cruelty_free;
      default: return Icons.pets;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.2),
        checkmarkColor: color ?? AppColors.primary,
      ),
    );
  }
}
