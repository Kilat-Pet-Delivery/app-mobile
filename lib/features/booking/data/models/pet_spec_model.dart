class PetSpecModel {
  final String petType;
  final String breed;
  final String name;
  final double weightKg;
  final int ageMonths;
  final List<VaccinationModel> vaccinations;
  final String specialNeeds;
  final String photoUrl;

  const PetSpecModel({
    required this.petType,
    this.breed = '',
    required this.name,
    required this.weightKg,
    this.ageMonths = 0,
    this.vaccinations = const [],
    this.specialNeeds = '',
    this.photoUrl = '',
  });

  factory PetSpecModel.fromJson(Map<String, dynamic> json) {
    return PetSpecModel(
      petType: json['pet_type'] as String? ?? '',
      breed: json['breed'] as String? ?? '',
      name: json['name'] as String? ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      ageMonths: json['age_months'] as int? ?? 0,
      vaccinations: (json['vaccinations'] as List<dynamic>?)
              ?.map((v) => VaccinationModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      specialNeeds: json['special_needs'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'pet_type': petType,
        'breed': breed,
        'name': name,
        'weight_kg': weightKg,
        'age_months': ageMonths,
        'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
        'special_needs': specialNeeds,
        'photo_url': photoUrl,
      };

  String get petTypeDisplay {
    switch (petType) {
      case 'dog': return 'Dog';
      case 'cat': return 'Cat';
      case 'bird': return 'Bird';
      case 'rabbit': return 'Rabbit';
      case 'reptile': return 'Reptile';
      default: return 'Other';
    }
  }
}

class VaccinationModel {
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime? expiresAt;
  final String? vetName;
  final bool verified;

  const VaccinationModel({
    required this.vaccineName,
    required this.dateGiven,
    this.expiresAt,
    this.vetName,
    this.verified = false,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      vaccineName: json['vaccine_name'] as String? ?? '',
      dateGiven: DateTime.parse(json['date_given'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      vetName: json['vet_name'] as String?,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'vaccine_name': vaccineName,
        'date_given': dateGiven.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        if (vetName != null) 'vet_name': vetName,
        'verified': verified,
      };
}
