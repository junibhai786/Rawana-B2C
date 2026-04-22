// lib/modals/hotel_city_model.dart
// Hotel-specific city model — isolated from any generic city models in the app.

class HotelCityResponseModel {
  final bool success;
  final List<HotelCityModel> data;

  HotelCityResponseModel({
    required this.success,
    required this.data,
  });

  factory HotelCityResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return HotelCityResponseModel(
      success: json['success'] as bool? ?? false,
      data: list
          .map((e) => HotelCityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotelCityModel {
  final String cityCode;
  final String cityName;
  final String countryCode;
  final String countryName;

  HotelCityModel({
    required this.cityCode,
    required this.cityName,
    required this.countryCode,
    required this.countryName,
  });

  factory HotelCityModel.fromJson(Map<String, dynamic> json) {
    return HotelCityModel(
      cityCode: json['city_code']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
    );
  }
}
