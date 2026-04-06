// ignore_for_file: unnecessary_question_mark

/// Response model for the flight prebook API
class FlightPreBookResponse {
  bool? success;
  dynamic price;
  String? currency;
  String? checkoutUrl;
  String? message;
  String? token;

  FlightPreBookResponse({
    this.success,
    this.price,
    this.currency,
    this.checkoutUrl,
    this.message,
    this.token,
  });

  FlightPreBookResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    price = json['price'];
    currency = json['currency'];
    checkoutUrl = json['checkout_url'];
    message = json['message'];
    // API may return the token as 'token' or 'checkout_token'
    token = (json['token'] ?? json['checkout_token'])?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['price'] = price;
    data['currency'] = currency;
    data['checkout_url'] = checkoutUrl;
    data['message'] = message;
    data['token'] = token;
    return data;
  }
}
