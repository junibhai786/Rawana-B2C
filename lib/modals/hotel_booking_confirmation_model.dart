class HotelBookingConfirmationResponse {
  final bool success;
  final String? message;
  final HotelBookingConfirmationData? data;

  HotelBookingConfirmationResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory HotelBookingConfirmationResponse.fromJson(Map<String, dynamic> json) {
    return HotelBookingConfirmationResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? HotelBookingConfirmationData.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HotelBookingConfirmationData {
  final String? orderId;
  final String? provider;
  final String? hotelName;
  final String? roomName;
  final String? checkIn;
  final String? checkOut;
  final int? nights;
  final int? adults;
  final int? children;
  final double? totalPrice;
  final String? currency;
  final String? status;
  final HotelBookingGuest? guest;
  final String? specialRequests;

  HotelBookingConfirmationData({
    this.orderId,
    this.provider,
    this.hotelName,
    this.roomName,
    this.checkIn,
    this.checkOut,
    this.nights,
    this.adults,
    this.children,
    this.totalPrice,
    this.currency,
    this.status,
    this.guest,
    this.specialRequests,
  });

  factory HotelBookingConfirmationData.fromJson(Map<String, dynamic> json) {
    return HotelBookingConfirmationData(
      orderId: json['order_id']?.toString(),
      provider: json['provider']?.toString(),
      hotelName: json['hotel_name']?.toString(),
      roomName: json['room_name']?.toString(),
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      nights: json['nights'] is int
          ? json['nights'] as int
          : int.tryParse(json['nights'].toString()),
      adults: json['adults'] is int
          ? json['adults'] as int
          : int.tryParse(json['adults'].toString()),
      children: json['children'] is int
          ? json['children'] as int
          : int.tryParse(json['children'].toString()),
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
      guest: json['guest'] is Map<String, dynamic>
          ? HotelBookingGuest.fromJson(json['guest'] as Map<String, dynamic>)
          : null,
      specialRequests: json['special_requests']?.toString(),
    );
  }
}

class HotelBookingGuest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  HotelBookingGuest({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  factory HotelBookingGuest.fromJson(Map<String, dynamic> json) {
    return HotelBookingGuest(
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
