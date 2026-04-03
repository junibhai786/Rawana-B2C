// lib/modals/activity_order_model.dart

class ActivityOrderResponse {
  final bool success;
  final String? message;
  final ActivityOrderData? data;

  ActivityOrderResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ActivityOrderResponse.fromJson(Map<String, dynamic> json) {
    return ActivityOrderResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? ActivityOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ActivityOrderData {
  final String? orderId;
  final String? provider;
  final String? activityTitle;
  final String? category;
  final String? city;
  final String? activityDate;
  final int? participants;
  final String? duration;
  final double? unitPrice;
  final double? totalPrice;
  final String? currency;
  final String? status;
  final ActivityOrderGuest? guest;
  final String? specialRequests;
  final List<ActivityOrderPassenger> passengers;

  ActivityOrderData({
    this.orderId,
    this.provider,
    this.activityTitle,
    this.category,
    this.city,
    this.activityDate,
    this.participants,
    this.duration,
    this.unitPrice,
    this.totalPrice,
    this.currency,
    this.status,
    this.guest,
    this.specialRequests,
    this.passengers = const [],
  });

  factory ActivityOrderData.fromJson(Map<String, dynamic> json) {
    final rawPassengers = json['passengers'];
    List<ActivityOrderPassenger> passengers = [];
    if (rawPassengers is List) {
      passengers = rawPassengers
          .whereType<Map<String, dynamic>>()
          .map((p) => ActivityOrderPassenger.fromJson(p))
          .toList();
    }

    return ActivityOrderData(
      orderId: json['order_id']?.toString(),
      provider: json['provider']?.toString(),
      activityTitle: json['activity_title']?.toString(),
      category: json['category']?.toString(),
      city: json['city']?.toString(),
      activityDate: json['activity_date']?.toString(),
      participants: json['participants'] is int
          ? json['participants'] as int
          : int.tryParse(json['participants'].toString()),
      duration: json['duration']?.toString(),
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString())
          : null,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
      guest: json['guest'] is Map<String, dynamic>
          ? ActivityOrderGuest.fromJson(json['guest'] as Map<String, dynamic>)
          : null,
      specialRequests: json['special_requests']?.toString(),
      passengers: passengers,
    );
  }
}

class ActivityOrderGuest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  ActivityOrderGuest({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  factory ActivityOrderGuest.fromJson(Map<String, dynamic> json) {
    return ActivityOrderGuest(
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

class ActivityOrderPassenger {
  final String? title;
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? nationality;
  final String? gender;
  final String? passport;
  final String? passportExpiry;
  final String? label;

  ActivityOrderPassenger({
    this.title,
    this.firstName,
    this.lastName,
    this.dob,
    this.nationality,
    this.gender,
    this.passport,
    this.passportExpiry,
    this.label,
  });

  factory ActivityOrderPassenger.fromJson(Map<String, dynamic> json) {
    return ActivityOrderPassenger(
      title: json['title']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      dob: json['dob']?.toString(),
      nationality: json['nationality']?.toString(),
      gender: json['gender']?.toString(),
      passport: json['passport']?.toString(),
      passportExpiry: json['passport_expiry']?.toString(),
      label: json['label']?.toString(),
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
