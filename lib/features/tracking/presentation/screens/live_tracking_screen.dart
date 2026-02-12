import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/live_tracking_bloc.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String bookingId;
  const LiveTrackingScreen({super.key, required this.bookingId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context
        .read<LiveTrackingBloc>()
        .add(LiveTrackingStarted(widget.bookingId));
  }

  @override
  void dispose() {
    context.read<LiveTrackingBloc>().add(LiveTrackingStopped());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          BlocBuilder<LiveTrackingBloc, LiveTrackingState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  state.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: state.isConnected ? Colors.white : Colors.red[200],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<LiveTrackingBloc, LiveTrackingState>(
        listener: (context, state) {
          if (state.latestUpdate != null) {
            _mapController.move(
              LatLng(
                state.latestUpdate!.latitude,
                state.latestUpdate!.longitude,
              ),
              15,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Default center: Kuala Lumpur
          final center = state.latestUpdate != null
              ? LatLng(
                  state.latestUpdate!.latitude,
                  state.latestUpdate!.longitude,
                )
              : state.routePoints.isNotEmpty
                  ? state.routePoints.last
                  : const LatLng(3.139, 101.6869);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kilatpet.app_mobile',
                  ),

                  // Route polyline
                  if (state.routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.routePoints,
                          color: AppColors.primary,
                          strokeWidth: 4,
                        ),
                      ],
                    ),

                  // Markers
                  MarkerLayer(
                    markers: [
                      // Pickup marker (if tracking data available)
                      if (state.tracking != null &&
                          state.tracking!.waypoints.isNotEmpty)
                        Marker(
                          point: LatLng(
                            state.tracking!.waypoints.first.latitude,
                            state.tracking!.waypoints.first.longitude,
                          ),
                          child: const Icon(
                            Icons.trip_origin,
                            color: AppColors.success,
                            size: 30,
                          ),
                        ),

                      // Runner marker (latest position)
                      if (state.latestUpdate != null)
                        Marker(
                          point: LatLng(
                            state.latestUpdate!.latitude,
                            state.latestUpdate!.longitude,
                          ),
                          child: Transform.rotate(
                            angle: state.latestUpdate!.headingDegrees *
                                3.14159 /
                                180,
                            child: const Icon(
                              Icons.navigation,
                              color: AppColors.accent,
                              size: 36,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Bottom info panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoTile(
                            icon: Icons.speed,
                            label: 'Speed',
                            value: state.latestUpdate != null
                                ? '${state.latestUpdate!.speedKmh.toStringAsFixed(1)} km/h'
                                : '--',
                          ),
                          _InfoTile(
                            icon: Icons.straighten,
                            label: 'Distance',
                            value: state.tracking != null
                                ? '${state.tracking!.totalDistanceKm.toStringAsFixed(2)} km'
                                : '--',
                          ),
                          _InfoTile(
                            icon: Icons.explore,
                            label: 'Heading',
                            value: state.latestUpdate != null
                                ? '${state.latestUpdate!.headingDegrees.toStringAsFixed(0)}°'
                                : '--',
                          ),
                        ],
                      ),
                      if (!state.isConnected &&
                          state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Connection lost. Reconnecting...',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
