import 'dart:convert';

HotelPreBookResponse hotelPreBookResponseFromJson(String str) =>
    HotelPreBookResponse.fromJson(json.decode(str));

String hotelPreBookResponseToJson(HotelPreBookResponse data) =>
    json.encode(data.toJson());

class HotelPreBookResponse {
  bool? success;
  double? totalPrice;
  String? currency;
  String? checkoutUrl;
  String? checkoutToken;
  String? message;

  HotelPreBookResponse({
    this.success,
    this.totalPrice,
    this.currency,
    this.checkoutUrl,
    this.checkoutToken,
    this.message,
  });

  factory HotelPreBookResponse.fromJson(Map<String, dynamic> json) {
    final checkoutUrl = json["checkout_url"]?.toString();

    // API returns checkout_url like: /hotels/checkout?token=<uuid>
    // Extract the token query param when checkout_token field is absent.
    String? extractedToken;
    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      // Use a dummy base so Uri.tryParse works even for relative URLs.
      final uri = Uri.tryParse('https://placeholder$checkoutUrl');
      extractedToken = uri?.queryParameters['token'];
    }

    final checkoutToken = json["checkout_token"]?.toString() ?? extractedToken;

    // ── [PREBOOK RESPONSE DEBUG] ─────────────────────────────────────────
    // (dart:developer log is not available here; use print for model layer)
    // ignore: avoid_print
    print('[PREBOOK] CHECKOUT URL      : $checkoutUrl');
    // ignore: avoid_print
    print('[PREBOOK] EXTRACTED TOKEN   : $extractedToken');
    // ignore: avoid_print
    print('[PREBOOK] FINAL checkoutToken: $checkoutToken');

    return HotelPreBookResponse(
      success: json["success"],
      totalPrice: json["total_price"] != null
          ? double.tryParse(json["total_price"].toString())
          : null,
      currency: json["currency"],
      checkoutUrl: checkoutUrl,
      checkoutToken: checkoutToken,
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "total_price": totalPrice,
        "currency": currency,
        "checkout_url": checkoutUrl,
        "checkout_token": checkoutToken,
        "message": message,
      };
}
