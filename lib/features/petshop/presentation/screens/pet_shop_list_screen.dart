import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/models/pet_shop_model.dart';
import '../cubit/pet_shop_cubit.dart';

class PetShopListScreen extends StatefulWidget {
  const PetShopListScreen({super.key});

  @override
  State<PetShopListScreen> createState() => _PetShopListScreenState();
}

class _PetShopListScreenState extends State<PetShopListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PetShopCubit>().loadPetShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Services')),
      body: Column(
        children: [
          // Category filter chips
          _CategoryFilter(),
          // Shop list
          Expanded(
            child: BlocBuilder<PetShopCubit, PetShopState>(
              builder: (context, state) {
                if (state is PetShopLoading || state is PetShopInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PetShopError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<PetShopCubit>().loadPetShops(),
                  );
                }
                if (state is PetShopLoaded) {
                  if (state.shops.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<PetShopCubit>().loadPetShops(
                        category: state.activeCategory),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.shops.length,
                      itemBuilder: (context, index) =>
                          _PetShopCard(shop: state.shops[index]),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront,
              size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text(
            'No pet shops found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different category filter.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  static const _categories = [
    (null, 'All', Icons.apps),
    ('grooming', 'Grooming', Icons.content_cut),
    ('vet', 'Vet', Icons.medical_services),
    ('boarding', 'Boarding', Icons.hotel),
    ('pet_store', 'Pet Store', Icons.storefront),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetShopCubit, PetShopState>(
      builder: (context, state) {
        final activeCategory =
            state is PetShopLoaded ? state.activeCategory : null;
        return SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (value, label, icon) = _categories[index];
              final isSelected = activeCategory == value;
              return FilterChip(
                avatar: Icon(icon, size: 18),
                label: Text(label),
                selected: isSelected,
                onSelected: (_) =>
                    context.read<PetShopCubit>().filterByCategory(value),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            },
          ),
        );
      },
    );
  }
}

class _PetShopCard extends StatelessWidget {
  final PetShopModel shop;
  const _PetShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/petshops/${shop.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              CircleAvatar(
                radius: 28,
                backgroundColor: _categoryColor.withValues(alpha: 0.1),
                child: Icon(_categoryIcon, color: _categoryColor, size: 28),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shop.categoryDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.divider),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _categoryIcon {
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

  Color get _categoryColor {
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
