class PetShopModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String category;
  final List<String> services;
  final double rating;
  final String imageUrl;
  final String openingHours;
  final String description;
  final DateTime createdAt;

  const PetShopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.category,
    required this.services,
    required this.rating,
    required this.imageUrl,
    required this.openingHours,
    required this.description,
    required this.createdAt,
  });

  factory PetShopModel.fromJson(Map<String, dynamic> json) {
    return PetShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      category: json['category'] as String,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      openingHours: json['opening_hours'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get categoryDisplay {
    switch (category) {
      case 'grooming':
        return 'Grooming';
      case 'vet':
        return 'Veterinary';
      case 'boarding':
        return 'Boarding';
      case 'pet_store':
        return 'Pet Store';
      default:
        return category;
    }
  }

  IconDataInfo get categoryIcon {
    switch (category) {
      case 'grooming':
        return IconDataInfo(0xe14f, 'content_cut'); // content_cut
      case 'vet':
        return IconDataInfo(0xf0527, 'medical_services');
      case 'boarding':
        return IconDataInfo(0xe318, 'hotel');
      case 'pet_store':
        return IconDataInfo(0xf04f4, 'storefront');
      default:
        return IconDataInfo(0xf04f4, 'storefront');
    }
  }
}

/// Helper class since we can't reference Icons directly in model.
class IconDataInfo {
  final int codePoint;
  final String name;
  const IconDataInfo(this.codePoint, this.name);
}
