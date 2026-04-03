import 'dart:convert';

class HotelCheckoutRequest {
  final String checkoutToken;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String paymentGateway;

  HotelCheckoutRequest({
    required this.checkoutToken,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.paymentGateway,
  });

  Map<String, dynamic> toJson() => {
        'checkout_token': checkoutToken,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'payment_gateway': paymentGateway,
      };

  String toJsonString() => json.encode(toJson());
}
