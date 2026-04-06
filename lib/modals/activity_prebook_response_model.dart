// ignore_for_file: unnecessary_question_mark

/// Response model for the activities prebook API
class ActivityPreBookResponse {
  bool? success;
  dynamic totalPrice;
  dynamic unitPrice;
  String? currency;
  String? checkoutToken;
  String? checkoutUrl;
  String? message;

  ActivityPreBookResponse({
    this.success,
    this.totalPrice,
    this.unitPrice,
    this.currency,
    this.checkoutToken,
    this.checkoutUrl,
    this.message,
  });

  ActivityPreBookResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalPrice = json['total_price'];
    unitPrice = json['unit_price'];
    currency = json['currency'];
    checkoutToken = json['checkout_token']?.toString();
    checkoutUrl = json['checkout_url'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['total_price'] = totalPrice;
    data['unit_price'] = unitPrice;
    data['currency'] = currency;
    data['checkout_token'] = checkoutToken;
    data['checkout_url'] = checkoutUrl;
    data['message'] = message;
    return data;
  }
}
