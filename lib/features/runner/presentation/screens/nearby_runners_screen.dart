import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/models/runner_model.dart';
import '../cubit/nearby_runners_cubit.dart';
import '../widgets/runner_detail_sheet.dart';

class NearbyRunnersScreen extends StatefulWidget {
  const NearbyRunnersScreen({super.key});

  @override
  State<NearbyRunnersScreen> createState() => _NearbyRunnersScreenState();
}

class _NearbyRunnersScreenState extends State<NearbyRunnersScreen> {
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // Fallback to KL center
        _lat = 3.1390;
        _lng = 101.6869;
      } else {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
        _lat = position.latitude;
        _lng = position.longitude;
      }
    } catch (_) {
      // Fallback to KL center
      _lat = 3.1390;
      _lng = 101.6869;
    }

    if (mounted && _lat != null && _lng != null) {
      context.read<NearbyRunnersCubit>().loadNearbyRunners(_lat!, _lng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Runners')),
      body: BlocBuilder<NearbyRunnersCubit, NearbyRunnersState>(
        builder: (context, state) {
          if (state is NearbyRunnersLoading || state is NearbyRunnersInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NearbyRunnersError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                if (_lat != null && _lng != null) {
                  context
                      .read<NearbyRunnersCubit>()
                      .loadNearbyRunners(_lat!, _lng!);
                }
              },
            );
          }
          if (state is NearbyRunnersLoaded) {
            if (state.runners.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async {
                if (_lat != null && _lng != null) {
                  await context
                      .read<NearbyRunnersCubit>()
                      .loadNearbyRunners(_lat!, _lng!);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.runners.length,
                itemBuilder: (context, index) =>
                    _RunnerCard(runner: state.runners[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined,
              size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text(
            'No runners nearby',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'No active runners found in your area.\nTry again later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadLocation,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _RunnerCard extends StatelessWidget {
  final RunnerModel runner;
  const _RunnerCard({required this.runner});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vehicle icon
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  _vehicleIcon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      runner.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          runner.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${runner.totalTrips} trips',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${runner.vehicleTypeDisplay} - ${runner.vehicleModel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Distance + AC badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (runner.distanceKm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        runner.distanceDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (runner.airConditioned)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, size: 14, color: AppColors.info),
                        const SizedBox(width: 2),
                        const Text('AC',
                            style:
                                TextStyle(fontSize: 11, color: AppColors.info)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _vehicleIcon {
    switch (runner.vehicleType) {
      case 'car':
        return Icons.directions_car;
      case 'van':
        return Icons.airport_shuttle;
      case 'motorcycle':
        return Icons.two_wheeler;
      default:
        return Icons.local_shipping;
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RunnerDetailSheet(runner: runner),
    );
  }
}
