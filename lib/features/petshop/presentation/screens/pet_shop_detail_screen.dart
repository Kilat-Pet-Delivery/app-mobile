import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/pet_shop_model.dart';
import '../cubit/pet_shop_detail_cubit.dart';

class PetShopDetailScreen extends StatefulWidget {
  final String shopId;
  const PetShopDetailScreen({super.key, required this.shopId});

  @override
  State<PetShopDetailScreen> createState() => _PetShopDetailScreenState();
}

class _PetShopDetailScreenState extends State<PetShopDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PetShopDetailCubit>().loadPetShop(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Details')),
      body: BlocBuilder<PetShopDetailCubit, PetShopDetailState>(
        builder: (context, state) {
          if (state is PetShopDetailLoading ||
              state is PetShopDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PetShopDetailError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<PetShopDetailCubit>()
                  .loadPetShop(widget.shopId),
            );
          }
          if (state is PetShopDetailLoaded) {
            return _buildContent(context, state.shop);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PetShopModel shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: _categoryColor(shop).withValues(alpha: 0.1),
                child: Icon(_categoryIcon(shop),
                    size: 32, color: _categoryColor(shop)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                _categoryColor(shop).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            shop.categoryDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _categoryColor(shop),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          if (shop.description.isNotEmpty) ...[
            _SectionCard(
              title: 'About',
              icon: Icons.info_outline,
              children: [Text(shop.description)],
            ),
            const SizedBox(height: 12),
          ],

          // Contact & Hours
          _SectionCard(
            title: 'Contact & Hours',
            icon: Icons.access_time,
            children: [
              _InfoRow(Icons.location_on, shop.address),
              if (shop.phone.isNotEmpty)
                _InfoRow(Icons.phone, shop.phone),
              if (shop.email.isNotEmpty)
                _InfoRow(Icons.email, shop.email),
              if (shop.openingHours.isNotEmpty)
                _InfoRow(Icons.schedule, shop.openingHours),
            ],
          ),
          const SizedBox(height: 12),

          // Services
          if (shop.services.isNotEmpty) ...[
            _SectionCard(
              title: 'Services',
              icon: Icons.list,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: shop.services
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 13)),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            side: BorderSide.none,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Book Delivery Here
          PrimaryButton(
            label: 'Book Delivery Here',
            icon: Icons.local_shipping,
            onPressed: () => context.push(
              '/bookings/create',
              extra: {
                'dropoff_address': shop.address,
                'dropoff_lat': shop.latitude,
                'dropoff_lng': shop.longitude,
                'dropoff_name': shop.name,
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _categoryIcon(PetShopModel shop) {
    switch (shop.category) {
      case 'grooming':
        return Icons.content_cut;
      case 'vet':
        return Icons.medical_services;
      case 'boarding':
        return Icons.hotel;
      case 'pet_store':
        return Icons.storefront;
      default:
        return Icons.storefront;
    }
  }

  Color _categoryColor(PetShopModel shop) {
    switch (shop.category) {
      case 'grooming':
        return AppColors.accent;
      case 'vet':
        return AppColors.error;
      case 'boarding':
        return AppColors.info;
      case 'pet_store':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
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
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
