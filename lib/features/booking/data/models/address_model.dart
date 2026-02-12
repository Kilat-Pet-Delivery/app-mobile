class AddressModel {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String? postalCode;
  final String country;
  final double latitude;
  final double longitude;

  const AddressModel({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'line1': line1,
        'line2': line2 ?? '',
        'city': city,
        'state': state,
        'postal_code': postalCode ?? '',
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  String get shortDisplay => '$line1, $city';
  String get fullDisplay => '$line1${line2 != null && line2!.isNotEmpty ? ", $line2" : ""}, $city, $state $country';
}
