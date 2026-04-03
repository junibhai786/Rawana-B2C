/// Hotel Search API Response Models
/// Matches: POST /api/hotels/search with request body: {city, check_in, check_out, adults, children, rooms}

import 'hotel_search_model.dart';
import 'hotel_room_model.dart';

// Re-export the type aliases for backward compatibility
export 'hotel_search_model.dart' show HotelSearchResult;
export 'hotel_room_model.dart' show Room;

class HotelSearchResponse {
  bool? success;

  /// Number of items in the current page.
  int? count;

  /// True total across all pages (may be larger than [count]).
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  List<HotelSearchResult>? data;
  String? message;

  HotelSearchResponse({
    this.success,
    this.count,
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.data,
    this.message,
  });

  factory HotelSearchResponse.fromJson(Map<String, dynamic> json) {
    return HotelSearchResponse(
      success: json['success'] as bool?,
      count: _safeInt(json['count']),
      total: _safeInt(json['total']),
      perPage: _safeInt(json['per_page']),
      currentPage: _safeInt(json['current_page']),
      lastPage: _safeInt(json['last_page']),
      data: json['data'] != null
          ? List<HotelSearchResult>.from(
              (json['data'] as List).map(
                (x) => HotelSearchResult.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      message: json['message'] as String?,
    );
  }

  static int? _safeInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'count': count,
        'total': total,
        'per_page': perPage,
        'current_page': currentPage,
        'last_page': lastPage,
        'data': data?.map((x) => x.toJson()).toList(),
        'message': message,
      };
}
