import 'package:flutter/foundation.dart';

class HomeAptsModel {
  final String id;
  final String? name;
  final String? city;
  final String? country;
  final String? address;
  final int? maxGuests;
  final int? bedrooms;
  final int? bathrooms;
  final int? beds;
  final List<String> images;
  final List<String> amenities;

  // Converted price fields (returned by API when currency param is sent)
  final dynamic convertedPricePerNight;
  final String? convertedCurrency;
  final dynamic convertedTotalPrice;

  HomeAptsModel({
    required this.id,
    this.name,
    this.city,
    this.country,
    this.address,
    this.maxGuests,
    this.bedrooms,
    this.bathrooms,
    this.beds,
    this.images = const [],
    this.amenities = const [],
    this.convertedPricePerNight,
    this.convertedCurrency,
    this.convertedTotalPrice,
  });

  factory HomeAptsModel.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('[HomeAptsModel] Parsing: ${_safeString(json['name'])}');
      return HomeAptsModel(
        id: _safeString(json['id'], 'unknown'),
        name: _safeString(json['name']),
        city: _safeString(json['city']),
        country: _safeString(json['country']),
        address: _safeString(json['address']),
        maxGuests: _safeInt(json['max_guests']),
        bedrooms: _safeInt(json['bedrooms']),
        bathrooms: _safeInt(json['bathrooms']),
        beds: _safeInt(json['beds']),
        images: _safeStringList(json['images']),
        amenities: _safeStringList(json['amenities']),
        convertedPricePerNight: json['converted_price_per_night'],
        convertedCurrency: _safeString(json['converted_currency']),
        convertedTotalPrice: json['converted_total_price'],
      );
    } catch (e) {
      debugPrint('[HomeAptsModel] ✗ Error parsing: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'country': country,
        'address': address,
        'max_guests': maxGuests,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'beds': beds,
        'images': images,
        'amenities': amenities,
        'converted_price_per_night': convertedPricePerNight,
        'converted_currency': convertedCurrency,
        'converted_total_price': convertedTotalPrice,
      };

  @override
  String toString() => 'HomeAptsModel(id: $id, name: $name, city: $city)';

  static String _safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((x) => x != null)
          .map((x) {
            if (x is Map) {
              for (final key in [
                'url',
                'image',
                'path',
                'src',
                'thumb',
                'thumbnail',
                'original',
                'large',
                'medium',
              ]) {
                final v = x[key];
                if (v is String && v.trim().isNotEmpty) {
                  final s = v.trim();
                  if (s.startsWith('<')) return null;
                  return s;
                }
              }
              return null;
            }
            if (x is String) {
              final s = x.trim();
              if (s.isEmpty || s.startsWith('<')) return null;
              return s;
            }
            return null;
          })
          .whereType<String>()
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return [];
  }
}
