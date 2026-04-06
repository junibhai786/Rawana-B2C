class FlightAirportResponseModel {
  final bool success;
  final List<FlightAirportModel> data;

  FlightAirportResponseModel({
    required this.success,
    required this.data,
  });

  factory FlightAirportResponseModel.fromJson(Map<String, dynamic> json) {
    return FlightAirportResponseModel(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map(
                  (e) => FlightAirportModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FlightAirportModel {
  final String iataCode;
  final String airport;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;

  FlightAirportModel({
    required this.iataCode,
    required this.airport,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory FlightAirportModel.fromJson(Map<String, dynamic> json) {
    return FlightAirportModel(
      iataCode: json['IATA_CODE'] as String? ?? '',
      airport: json['AIRPORT'] as String? ?? '',
      city: json['CITY'] as String? ?? '',
      state: json['STATE'] as String? ?? '',
      country: json['COUNTRY'] as String? ?? '',
      latitude: (json['LATITUDE'] as num?)?.toDouble(),
      longitude: (json['LONGITUDE'] as num?)?.toDouble(),
    );
  }
}
