// lib/modals/hotel_country_model.dart
// Hotel-specific country model — isolated from any other country models in the app.

class HotelCountryResponseModel {
  final bool success;
  final List<HotelCountryModel> data;

  HotelCountryResponseModel({
    required this.success,
    required this.data,
  });

  factory HotelCountryResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return HotelCountryResponseModel(
      success: json['success'] as bool? ?? false,
      data: list
          .map((e) => HotelCountryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HotelCountryModel {
  final String countryCode;
  final String countryName;

  HotelCountryModel({
    required this.countryCode,
    required this.countryName,
  });

  factory HotelCountryModel.fromJson(Map<String, dynamic> json) {
    return HotelCountryModel(
      countryCode: json['country_code']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
    );
  }
}
