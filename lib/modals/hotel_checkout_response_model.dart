class HotelCheckoutResponse {
  final bool success;
  final String? message;
  final String? paymentUrl;
  final String? bookingId;
  final Map<String, dynamic>? rawData;

  HotelCheckoutResponse({
    required this.success,
    this.message,
    this.paymentUrl,
    this.bookingId,
    this.rawData,
  });

  factory HotelCheckoutResponse.fromJson(Map<String, dynamic> json) {
    // Keep raw data for flexible logging
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    return HotelCheckoutResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      // payment/redirect URL — API returns 'url' (Stripe), also check aliases
      paymentUrl: json['url']?.toString() ??
          json['payment_url']?.toString() ??
          json['redirect_url']?.toString() ??
          json['checkout_url']?.toString() ??
          data?['url']?.toString() ??
          data?['payment_url']?.toString() ??
          data?['redirect_url']?.toString() ??
          data?['checkout_url']?.toString(),
      bookingId: json['booking_id']?.toString() ??
          data?['booking_id']?.toString() ??
          data?['id']?.toString(),
      rawData: data,
    );
  }
}
