class HotelDestinationResult {
  final String? type;
  final String? destination;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? location;
  final String? region;
  final String? displayName;

  HotelDestinationResult({
    this.type,
    this.destination,
    this.city,
    this.country,
    this.countryCode,
    this.location,
    this.region,
    this.displayName,
  });

  factory HotelDestinationResult.fromJson(Map<String, dynamic> json) {
    return HotelDestinationResult(
      type: json['type']?.toString(),
      destination: json['destination']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      countryCode: json['country_code']?.toString(),
      location: json['location']?.toString(),
      region: json['region']?.toString(),
      displayName: json['display_name']?.toString(),
    );
  }
}
