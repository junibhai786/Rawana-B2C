import 'dart:convert';

class RoomSearchModel {
  final String id; // Always String
  final String? name;
  final String? roomType;
  final Map<String, dynamic> bedConfiguration; // Parsed from both formats
  final int? maxAdults;
  final int? maxChildren;
  final double basePrice;
  final double totalPrice;
  final int nights;
  final String? currency;
  final bool isAvailable;
  final List<String> amenities;
  final int? sizeSqm;
  final String? viewType;
  final String? description;
  final List<String> images;

  RoomSearchModel({
    required this.id,
    this.name,
    this.roomType,
    this.bedConfiguration = const {},
    this.maxAdults,
    this.maxChildren,
    this.basePrice = 0.0,
    this.totalPrice = 0.0,
    this.nights = 1,
    this.currency,
    this.isAvailable = true,
    this.amenities = const [],
    this.sizeSqm,
    this.viewType,
    this.description,
    this.images = const [],
  });

  factory RoomSearchModel.fromJson(Map<String, dynamic> json) {
    try {
      // === ISSUE 2: ID must always be String ===
      final id = json['id'];
      final idString = id == null
          ? 'unknown'
          : id is String
              ? id
              : id.toString();

      // === ISSUE 3: Handle bed_configuration both formats ===
      final bedConfiguration =
          _parseBedConfiguration(json['bed_configuration']);

      // === Parse max_adults safely ===
      int? maxAdults;
      if (json['max_adults'] != null) {
        if (json['max_adults'] is int) {
          maxAdults = json['max_adults'];
        } else if (json['max_adults'] is String) {
          maxAdults = int.tryParse(json['max_adults']);
        }
      }

      // === Parse max_children safely ===
      int? maxChildren;
      if (json['max_children'] != null) {
        if (json['max_children'] is int) {
          maxChildren = json['max_children'];
        } else if (json['max_children'] is String) {
          maxChildren = int.tryParse(json['max_children']);
        }
      }

      // === Parse size_sqm safely ===
      int? sizeSqm;
      if (json['size_sqm'] != null) {
        if (json['size_sqm'] is int) {
          sizeSqm = json['size_sqm'];
        } else if (json['size_sqm'] is String) {
          sizeSqm = int.tryParse(json['size_sqm']);
        }
      }

      // === Parse base_price safely ===
      final basePrice = _parseDouble(json['base_price']);

      // === Parse total_price safely ===
      final totalPrice = _parseDouble(json['total_price']);

      // === Parse nights safely ===
      int nights = 1;
      if (json['nights'] != null) {
        if (json['nights'] is int) {
          nights = json['nights'];
        } else if (json['nights'] is String) {
          nights = int.tryParse(json['nights']) ?? 1;
        }
      }

      // === Parse is_available safely ===
      bool isAvailable = true;
      if (json['is_available'] != null) {
        if (json['is_available'] is bool) {
          isAvailable = json['is_available'];
        } else if (json['is_available'] is int) {
          isAvailable = json['is_available'] == 1;
        } else if (json['is_available'] is String) {
          isAvailable = json['is_available'].toLowerCase() == 'true' ||
              json['is_available'] == '1';
        }
      }

      // === Parse amenities list ===
      final amenities = _parseStringList(json['amenities']);

      // === Parse images list ===
      final images = _parseStringList(json['images']);

      return RoomSearchModel(
        id: idString,
        name: json['name']?.toString(),
        roomType: json['room_type']?.toString(),
        bedConfiguration: bedConfiguration,
        maxAdults: maxAdults,
        maxChildren: maxChildren,
        basePrice: basePrice,
        totalPrice: totalPrice,
        nights: nights,
        currency: json['currency']?.toString(),
        isAvailable: isAvailable,
        amenities: amenities,
        sizeSqm: sizeSqm,
        viewType: json['view_type']?.toString(),
        description: json['description']?.toString(),
        images: images,
      );
    } catch (e) {
      print('[RoomSearchModel.fromJson] ERROR: $e');
      print('[RoomSearchModel.fromJson] JSON: $json');
      rethrow;
    }
  }

  /// Safely parse bed_configuration from both formats:
  /// FORMAT A (Local):    ["{\"king\":1}"]   → parse string inside list
  /// FORMAT B (Hyperguest): {"king": 1}      → direct map
  static Map<String, dynamic> _parseBedConfiguration(dynamic raw) {
    if (raw == null) return {};

    // Format B: Direct Map (Hyperguest)
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }

    // Format A: Array of JSON strings (Local)
    if (raw is List && raw.isNotEmpty) {
      try {
        final firstElement = raw.first;
        if (firstElement is String) {
          final parsed = jsonDecode(firstElement);
          if (parsed is Map<String, dynamic>) {
            return parsed;
          }
        } else if (firstElement is Map<String, dynamic>) {
          return Map<String, dynamic>.from(firstElement);
        }
      } catch (e) {
        print('[RoomSearchModel._parseBedConfiguration] Failed to parse: $e');
      }
    }

    return {};
  }

  static double _parseDouble(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.where((x) => x != null).map((x) => x.toString()).toList();
    }
    return [];
  }

  /// Get bed configuration as readable string: "1 King, 2 Queen"
  String formatBedConfiguration() {
    if (bedConfiguration.isEmpty) return 'Not specified';

    final parts = <String>[];
    bedConfiguration.forEach((bedType, count) {
      final countInt =
          count is int ? count : int.tryParse(count.toString()) ?? 0;
      if (countInt > 0) {
        final bedTypeCapitalized =
            bedType[0].toUpperCase() + bedType.substring(1).toLowerCase();
        parts.add('$countInt $bedTypeCapitalized${countInt > 1 ? 's' : ''}');
      }
    });

    return parts.isNotEmpty ? parts.join(', ') : 'Not specified';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'room_type': roomType,
        'bed_configuration': bedConfiguration,
        'max_adults': maxAdults,
        'max_children': maxChildren,
        'base_price': basePrice,
        'total_price': totalPrice,
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
      'RoomSearchModel(id: $id, name: $name, beds: ${formatBedConfiguration()}, price: $totalPrice $currency)';
}
