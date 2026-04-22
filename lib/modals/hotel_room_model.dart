import 'dart:convert';
import 'package:flutter/foundation.dart';

// Type alias for backward compatibility with existing code using Room
typedef Room = HotelRoomModel;

class HotelRoomModel {
  // Always String to handle both local and Hyperguest IDs
  final String id;

  final String? name;
  final String? roomType;
  final String? offerId;
  final String? roomId;

  // bed_configuration can be:
  // - Local:      ["{\"king\":1}"]  → Array of JSON strings
  // - Hyperguest: {"king": 1}       → Direct Map
  final Map<String, dynamic> bedConfiguration;

  final int? maxAdults;
  final int? maxChildren;

  // Prices can be int, double, or string
  final dynamic basePrice;
  final dynamic totalPrice;

  // Converted price fields (returned by API when currency param is sent)
  final String? convertedCurrency;
  final dynamic convertedBasePrice;
  final dynamic convertedTotalPrice;

  final int? nights;
  final String? currency;

  final bool isAvailable;

  // Collections with defaults
  final List<String> amenities;
  final int? sizeSqm;
  final String? viewType;
  final String? description;
  final List<String> images;

  HotelRoomModel({
    required this.id,
    this.name,
    this.roomType,
    this.offerId,
    this.roomId,
    this.bedConfiguration = const {},
    this.maxAdults,
    this.maxChildren,
    this.basePrice,
    this.totalPrice,
    this.convertedCurrency,
    this.convertedBasePrice,
    this.convertedTotalPrice,
    this.nights,
    this.currency,
    this.isAvailable = true,
    this.amenities = const [],
    this.sizeSqm,
    this.viewType,
    this.description,
    this.images = const [],
  });

  factory HotelRoomModel.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('[HotelRoomModel] Parsing room: ${_safeString(json['name'])}');

      return HotelRoomModel(
        id: _safeString(json['id'], 'unknown'),
        name: _safeString(json['name']),
        roomType: _safeString(json['room_type']),
        offerId: _safeString(json['offer_id']),
        roomId: _safeString(json['room_id']),
        bedConfiguration: _parseBedConfiguration(json['bed_configuration']),
        maxAdults: _safeInt(json['max_adults']),
        maxChildren: _safeInt(json['max_children']),
        basePrice: json['base_price'],
        totalPrice: json['total_price'],
        convertedCurrency: _safeString(json['converted_currency']),
        convertedBasePrice: json['converted_base_price'],
        convertedTotalPrice: json['converted_total_price'],
        nights: _safeInt(json['nights']) ?? 1,
        currency: _safeString(json['currency']),
        isAvailable: _safeBool(json['is_available']),
        amenities: _safeStringList(json['amenities']),
        sizeSqm: _safeInt(json['size_sqm']),
        viewType: _safeString(json['view_type']),
        description: _safeString(json['description']),
        images: _safeStringList(json['images']),
      );
    } catch (e) {
      debugPrint('[HotelRoomModel] ✗ Error parsing: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'room_type': roomType,
        'offer_id': offerId,
        'room_id': roomId,
        'bed_configuration': bedConfiguration,
        'max_adults': maxAdults,
        'max_children': maxChildren,
        'base_price': basePrice,
        'total_price': totalPrice,
        'converted_currency': convertedCurrency,
        'converted_base_price': convertedBasePrice,
        'converted_total_price': convertedTotalPrice,
        'nights': nights,
        'currency': currency,
        'is_available': isAvailable,
        'amenities': amenities,
        'size_sqm': sizeSqm,
        'view_type': viewType,
        'description': description,
        'images': images,
      };

  @override
  String toString() =>
      'HotelRoomModel(id: $id, name: $name, type: $roomType, beds: $bedConfiguration)';

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

  /// Safe boolean conversion - returns false if null
  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  /// Safe string list conversion - returns empty list if null
  static List<String> _safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((x) => x != null)
          .map((x) => x.toString().trim())
          .where((x) => x.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// === CRITICAL: Parse bed_configuration from BOTH formats ===
  /// Format A (Local):      ["{\"king\":1}"]  → Array of JSON strings
  /// Format B (Hyperguest): {"king": 1}       → Direct Map object
  static Map<String, dynamic> _parseBedConfiguration(dynamic raw) {
    try {
      if (raw == null) return {};

      // Format B: Direct Map (Hyperguest)
      if (raw is Map<String, dynamic>) {
        return Map<String, dynamic>.from(raw);
      }

      // Format A: Array of JSON strings (Local)
      if (raw is List && raw.isNotEmpty) {
        final firstElement = raw.first;

        // If first element is a String, it's a JSON string
        if (firstElement is String) {
          final decoded = jsonDecode(firstElement);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
        // If first element is already a Map
        else if (firstElement is Map<String, dynamic>) {
          return firstElement;
        }
      }

      return {};
    } catch (e) {
      debugPrint('[_parseBedConfiguration] Failed to parse: $e');
      return {};
    }
  }
}
