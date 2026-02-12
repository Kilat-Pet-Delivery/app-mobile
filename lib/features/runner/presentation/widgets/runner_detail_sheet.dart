import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/runner_model.dart';

class RunnerDetailSheet extends StatelessWidget {
  final RunnerModel runner;
  const RunnerDetailSheet({super.key, required this.runner});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(_vehicleIcon, size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          runner.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 18, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              '${runner.rating.toStringAsFixed(1)} rating',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${runner.totalTrips} trips',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (runner.distanceKm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        runner.distanceDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Vehicle Details
              _SectionTitle(icon: Icons.directions_car, title: 'Vehicle'),
              const SizedBox(height: 8),
              _DetailRow('Type', runner.vehicleTypeDisplay),
              _DetailRow('Model', runner.vehicleModel),
              _DetailRow('Plate', runner.vehiclePlate),
              _DetailRow(
                  'Air Conditioned', runner.airConditioned ? 'Yes' : 'No'),
              const SizedBox(height: 20),

              // Crate Specs
              if (runner.crateSpecs.isNotEmpty) ...[
                _SectionTitle(icon: Icons.inventory_2, title: 'Crate Specs'),
                const SizedBox(height: 8),
                ...runner.crateSpecs.map((crate) => _CrateCard(crate: crate)),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child:
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _CrateCard extends StatelessWidget {
  final CrateSpecModel crate;
  const _CrateCard({required this.crate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    crate.sizeDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Max ${crate.maxWeightKg.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (crate.ventilated)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.air, size: 16, color: AppColors.info),
                  ),
                if (crate.temperatureControlled)
                  const Icon(Icons.thermostat, size: 16, color: AppColors.info),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pets: ${crate.petTypesDisplay}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
