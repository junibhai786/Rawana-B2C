// lib/modals/country_modal.dart

class CountryResponse {
  final String message;
  final List<Country> data;

  CountryResponse({required this.message, required this.data});

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Country> countryList = list.map((i) => Country.fromJson(i)).toList();

    return CountryResponse(
      message: json['message'],
      data: countryList,
    );
  }
}

class Country {
  final String code;
  final String name;

  Country({required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'],
      name: json['name'],
    );
  }
}
