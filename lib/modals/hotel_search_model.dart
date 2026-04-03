import 'package:flutter/foundation.dart';
import 'hotel_room_model.dart';

// Type alias for backward compatibility with existing code using HotelSearchResult
typedef HotelSearchResult = HotelModel;

class HotelModel {
  // Always String to handle both local ("1") and Hyperguest ("HG001") IDs
  final String id;

  // Can be int or null (null for Hyperguest)
  final int? dbHotelId;

  final String? provider;
  final String? slug;
  final String? name;

  // Star rating can be int or double
  final dynamic starRating;

  final String? city;
  final String? country;
  final String? address;
  final String? description;
  final String? shortDescription;
  final String? checkInTime;
  final String? checkOutTime;

  // Coordinates can be int, double, or string
  final dynamic latitude;
  final dynamic longitude;

  // Collections with defaults
  final List<String> images;
  final List<String> amenities;
  final List<String> services;

  // Price can be int, double, or string
  final dynamic lowestPrice;

  final String? currency;
  final List<HotelRoomModel> rooms;
  final String? badge;
  final String? apiSource;

  HotelModel({
    required this.id,
    this.dbHotelId,
    this.provider,
    this.slug,
    this.name,
    this.starRating,
    this.city,
    this.country,
    this.address,
    this.description,
    this.shortDescription,
    this.checkInTime,
    this.checkOutTime,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.amenities = const [],
    this.services = const [],
    this.lowestPrice,
    this.currency,
    this.rooms = const [],
    this.badge,
    this.apiSource,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('[HotelModel] Parsing: ${_safeString(json['name'])}');

      return HotelModel(
        id: _safeString(json['id'], 'unknown'),
        dbHotelId: _safeInt(json['db_hotel_id']),
        provider: _safeString(json['provider']),
        slug: _safeString(json['slug']),
        name: _safeString(json['name']),
        starRating: json['star_rating'],
        city: _safeString(json['city']),
        country: _safeString(json['country']),
        address: _safeString(json['address']),
        description: _safeString(json['description']),
        shortDescription: _safeString(json['short_description']),
        checkInTime: _safeString(json['check_in_time']),
        checkOutTime: _safeString(json['check_out_time']),
        latitude: json['latitude'],
        longitude: json['longitude'],
        images: _safeStringList(json['images']),
        amenities: _safeStringList(json['amenities']),
        services: _safeStringList(json['services']),
        lowestPrice: json['lowest_price'],
        currency: _safeString(json['currency']),
        rooms: _safeRoomList(json['rooms']),
        badge: _safeString(json['badge']),
        apiSource: _safeString(json['api_source']),
      );
    } catch (e) {
      debugPrint('[HotelModel] ✗ Error parsing: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'db_hotel_id': dbHotelId,
        'provider': provider,
        'slug': slug,
        'name': name,
        'star_rating': starRating,
        'city': city,
        'country': country,
        'address': address,
        'description': description,
        'short_description': shortDescription,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'latitude': latitude,
        'longitude': longitude,
        'images': images,
        'amenities': amenities,
        'services': services,
        'lowest_price': lowestPrice,
        'currency': currency,
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'badge': badge,
        'api_source': apiSource,
      };

  @override
  String toString() =>
      'HotelModel(id: $id, name: $name, city: $city, rooms: ${rooms.length})';

  /// Safe string conversion - never returns null
  static String _safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }

  /// Safe integer conversion - returns null if cannot parse
  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safe double conversion - returns 0.0 if cannot parse
  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safe string list conversion - returns empty list if null.
  /// Handles:
  ///   - plain URL strings
  ///   - base64 data URIs (data:image/...) — kept as-is for Image.memory fallback
  ///   - SVG/HTML placeholder strings (starts with '<') — skipped
  ///   - Map objects — tries to extract a URL from known keys
  static List<String> _safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((x) => x != null)
          .map((x) {
            if (x is Map) {
              // Try common image URL keys from API objects.
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
                  // Skip SVG/HTML placeholders.
                  if (s.startsWith('<')) return '';
                  return s;
                }
              }
              return '';
            }
            final s = x.toString().trim();
            // Skip SVG/HTML placeholder strings.
            if (s.startsWith('<')) return '';
            return s;
          })
          .where((x) => x.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Safe room list conversion - returns empty list if null
  static List<HotelRoomModel> _safeRoomList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((x) => HotelRoomModel.fromJson(x))
          .toList();
    }
    return [];
  }
}
