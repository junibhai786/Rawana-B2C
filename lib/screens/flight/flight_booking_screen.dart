// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, use_build_context_synchronously, unnecessary_string_interpolations, unnecessary_cast

import 'dart:developer';

import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/flight/flight_confirm_screen.dart';
import 'package:moonbnd/screens/payment_screen.dart';
import 'package:moonbnd/widgets/separator.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FlightBookingScreen extends StatefulWidget {
  final String bookingCode;
  final int? totalPrice;
  // final int? extraPrice;

  FlightBookingScreen({
    super.key,
    required this.bookingCode,
    this.totalPrice,
    // this.extraPrice = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<FlightBookingScreen> {
  DateTime? startDate;
  DateTime? endDate;
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  bool _isCouponApplied = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _specialRequirementsController =
      TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  String? selectedCountry;
  bool loading = false;
  String _formatDate(DateTime date) {
    return "${date.day}-${_monthToString(date.month)}";
  }

  String _monthToString(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();

    _fetchBookingDetails().then((value) {});
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.UserCreditbalance();
    await homeProvider.fetchCountries(); // Fetch countries
    setState(() {}); // Trigger a rebuild after fetching data
  }

  // Function to handle submission
  Future<void> _submitBooking() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please accept the Terms & Conditions to proceed.')));
      return;
    }

    if (_formKey.currentState!.validate() && _termsAccepted) {
      setState(() {
        loading = true;
      });
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      // Prepare data for API call
      final bookingData = {
        'code': widget.bookingCode,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address_line_1': _addressLine1Controller.text,
        'address_line_2': _addressLine2Controller.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip_code': _zipCodeController.text,
        'country': selectedCountry,
        'customer_notes': _specialRequirementsController.text,
        'payment_gateway':
            homeProvider.paymentMethod == "offline" ? 'offline' : 'stripe',
        'term_conditions': 'accepted',
        'coupon_code': '',
        'credit': _creditController.text,
      };

      print("Booking Data: $bookingData");

      final response = await homeProvider.checkout(
          code: bookingData['code'] as String,
          firstName: bookingData['first_name'] as String,
          lastName: bookingData['last_name'] as String,
          email: bookingData['email'] as String,
          phone: bookingData['phone'] as String,
          addressLine1: bookingData['address_line_1'] as String,
          addressLine2: bookingData['address_line_2'] as String,
          city: bookingData['city'] as String,
          state: bookingData['state'] as String,
          zipCode: bookingData['zip_code'] as String,
          country: bookingData['country'] as String,
          customerNotes: bookingData['customer_notes'] as String,
          paymentGateway: bookingData['payment_gateway'] as String,
          termConditions: bookingData['term_conditions'] as String,
          couponCode: bookingData['coupon_code'] as String,
          credit: bookingData['credit'] as String);

      setState(() {
        loading = true;
      });

      // Print response for debugging
      log("API Response: $response"); // Added print statement

      if (response != null) {
        setState(() {
          loading = false;
        });
        log("url kick in $response");
        if (response['status'] == 0) {
          if (response['message'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${response['message']}')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to submit booking. Please try again.')));
          }
          return;
        }
        if (homeProvider.paymentMethod == "online") {
          String urlGo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(weburl: response["url"]),
            ),
          );
          log("check in to $urlGo");
          if (urlGo.contains("https://travolyo.com/api/booking/confirm")) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FlightConfirmScreen(bookingCode: widget.bookingCode),
              ),
            );
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FlightConfirmScreen(bookingCode: widget.bookingCode),
            ),
          );
        }
      } else {
        setState(() {
          loading = false;
        });
        // Handle error case
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to submit booking. Please try again.')));
      }
    }
  }

  Future<void> _fetchBookingDetails() async {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);

    await flightProvider.fetchFlightBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {});
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    log("${widget.totalPrice} total");
    final flightbookingitem =
        Provider.of<FlightProvider>(context, listen: true);
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);

    log("${flightbookingitem.bookingResponse} bookingResponse");

    if (flightbookingitem.bookingResponse == null) {
      return Center(
          child: CircularProgressIndicator(
              color: kSecondaryColor)); // Show loading indicator
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Booking'.tr),
        leading: BackButton(),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flightbookingitem
                            .bookingResponse?.data?.booking?.service?.title ??
                        ""
                            ' | ${flightbookingitem.flightDetail?.data?.code}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                      fontFamily: 'Inter'.tr,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        flightbookingitem.bookingResponse?.data?.booking
                                ?.service?.airportFrom?.name ??
                            "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: grey,
                          fontFamily: 'Inter'.tr,
                        ),
                      ),
                      Text(
                        " to ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: grey,
                          fontFamily: 'Inter'.tr,
                        ),
                      ),
                      Text(
                        flightbookingitem.bookingResponse?.data?.booking
                                ?.service?.airportTo?.name ??
                            "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: grey,
                          fontFamily: 'Inter'.tr,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${flightbookingitem.bookingResponse?.data?.booking?.service?.duration ?? ""} hrs",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontFamily: 'Inter'.tr,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          flightbookingitem.bookingResponse?.data?.booking
                                  ?.service?.airportImageUrl ??
                              'assets/haven/house.png',
                          height: 80,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFlightInfo(
                          'Take Off'.tr,
                          DateFormat('HH:mm').format(DateTime.parse(
                              (flightbookingitem.bookingResponse?.data?.booking
                                          ?.service?.departureTime ??
                                      DateTime.now().toString())
                                  .toString())),
                          DateFormat('dd MMM, yyyy').format(DateTime.parse(
                              (flightbookingitem.bookingResponse?.data?.booking
                                          ?.service?.departureTime ??
                                      DateTime.now().toString())
                                  .toString())),
                          flightbookingitem.bookingResponse?.data?.booking
                                  ?.service?.airportTo?.name ??
                              ''),
                      // Center(
                      //   child: Text(
                      //     '${flightbookingitem.bookingResponse?.data?.booking?.service?.duration} hrs'
                      //         .tr,
                      //     style: TextStyle(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //       color: kPrimaryColor,
                      //       decoration: TextDecoration.underline,
                      //     ),
                      //   ),
                      // ),
                      _buildFlightInfo(
                          'Landing'.tr,
                          DateFormat('HH:mm').format(DateTime.parse(
                              (flightbookingitem.bookingResponse?.data?.booking
                                          ?.service?.arrivalTime ??
                                      DateTime.now().toString())
                                  .toString())),
                          DateFormat('dd MMM, yyyy').format(DateTime.parse(
                              (flightbookingitem.bookingResponse?.data?.booking
                                          ?.service?.arrivalTime ??
                                      DateTime.now().toString())
                                  .toString())),
                          flightbookingitem.bookingResponse?.data?.booking
                                  ?.service?.airportFrom?.name ??
                              ''),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),

                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start Date'.tr,
                        style: TextStyle(
                            fontFamily: 'Inter'.tr,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kPrimaryColor),
                      ),
                      Text(
                          DateFormat("dd/MM/yyyy").format(DateTime.parse(
                              (flightbookingitem.bookingResponse?.data?.booking
                                          ?.service?.departureTime ??
                                      '2000-01-01')
                                  .toString())), // Using a valid default date instead of empty string
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter'.tr,
                              fontWeight: FontWeight.w400,
                              color: grey)),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'End Date'.tr,
                  //       style: TextStyle(
                  //           fontFamily: 'Inter'.tr,
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w500,
                  //           color: kPrimaryColor),
                  //     ),
                  //     // Text(
                  //     //     DateFormat("dd/MM/yyyy").format(DateTime.parse(
                  //     //         flightbookingitem
                  //     //                 .bookingResponse?.data?.booking?.endDate ??
                  //     //             '')),
                  //     //     style: TextStyle(
                  //     //         fontSize: 16,
                  //     //         fontFamily: 'Inter'.tr,
                  //     //         fontWeight: FontWeight.w400,
                  //     //         color: grey)),
                  //   ],
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Duration'.tr,
                          style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryColor)),
                      Text(
                          "${flightbookingitem.bookingResponse?.data?.booking?.service?.duration ?? 0} hrs",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter'.tr,
                              fontWeight: FontWeight.w400,
                              color: grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      ...(flightbookingitem.bookingResponse?.data?.booking
                                  ?.seatDetails ??
                              [])
                          .map((seat) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${seat.seatType?.code?.capitalizeFirst ?? ""}'
                                          .tr,
                                      style: TextStyle(
                                          fontFamily: 'Inter'.tr,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: kPrimaryColor)),
                                  SizedBox(width: 16),
                                  SizedBox(height: 30),
                                  Text("${seat.number ?? 0} ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Inter'.tr,
                                          fontWeight: FontWeight.w400,
                                          color: grey)),
                                ],
                              )),
                    ],
                  ),

                  SizedBox(height: 8),
                  Divider(), // Separator
                  SizedBox(height: 16),
                  // Price details
                  Column(
                    children: [
                      ...(flightbookingitem.bookingResponse?.data?.booking
                                  ?.seatDetails ??
                              [])
                          .map((seat) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${seat.seatType?.code?.capitalizeFirst ?? ""}: ${seat.number ?? 0} * \$${seat.price ?? 0}'
                                          .tr,
                                      style: TextStyle(
                                          fontFamily: 'Inter'.tr,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: kPrimaryColor)),
                                  SizedBox(width: 16),
                                  SizedBox(height: 30),
                                  Text(
                                      "\$${(int.parse(seat.number?.toString() ?? "0") * double.parse(seat.price?.toString() ?? "0")).toStringAsFixed(2)} ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Inter'.tr,
                                          fontWeight: FontWeight.w400,
                                          color: grey)),
                                ],
                              )),
                    ],
                  ),
                  SizedBox(height: 20),

                  // ...(flightbookingitem.bookingResponse?.data?.booking?.buyerFees)!
                  //     .map((element) {
                  //   return Container(
                  //     padding: EdgeInsets.only(top: 10),
                  //     child: Row(
                  //       children: [
                  //         Text(element.name ?? "",
                  //             style: TextStyle(
                  //                 fontFamily: 'Inter'.tr,
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.w500,
                  //                 color: kPrimaryColor)),
                  //         Spacer(),
                  //         Text("\$${element.price}",
                  //             style: TextStyle(
                  //                 fontFamily: 'Inter'.tr,
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.w400,
                  //                 color: grey)),
                  //       ],
                  //     ),
                  //   );
                  // }).toList(),

                  // ...(flightbookingitem.bookingResponse?.data?.booking?.extraPrice)!
                  //     .map((element) {
                  //   return Container(
                  //     padding: EdgeInsets.only(top: 10),
                  //     child: Row(
                  //       children: [
                  //         Text(element.name ?? "",
                  //             style: TextStyle(
                  //                 fontFamily: 'Inter'.tr,
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.w500,
                  //                 color: kPrimaryColor)),
                  //         Spacer(),
                  //         Text("\$${element.price}",
                  //             style: TextStyle(
                  //                 fontFamily: 'Inter'.tr,
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.w400,
                  //                 color: grey)),
                  //       ],
                  //     ),
                  //   );
                  // }).toList(),

                  SizedBox(height: 18),
                  TextFormField(
                    controller: _couponCodeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Coupon Code'.tr,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isCouponApplied) {
                              homeProvider
                                  .removeCoupon(
                                flightbookingitem
                                        .bookingResponse?.data?.booking?.code ??
                                    '',
                                _couponCodeController.text,
                                context,
                              )
                                  .then((_) {
                                setState(() {
                                  _isCouponApplied = false;
                                });
                                _couponCodeController.clear();
                              });
                            } else {
                              homeProvider.applyCoupon(
                                flightbookingitem
                                        .bookingResponse?.data?.booking?.code ??
                                    '',
                                _couponCodeController.text,
                                context,
                              );
                              setState(() {
                                _isCouponApplied = true;
                              });
                            }
                          },
                          child:
                              Text(_isCouponApplied ? 'Remove'.tr : 'Apply'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isCouponApplied ? Colors.red : kSecondaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 8),
                  Divider(), // Separator

                  SizedBox(height: 8),
// Total Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              fontFamily: 'Inter'.tr,
                              color: kPrimaryColor)),
                      Text(
                          '\$${(flightbookingitem.bookingResponse?.data?.booking?.total ?? 0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              fontFamily: 'Inter'.tr,
                              color: kPrimaryColor)),
                      // Text(
                      //     '\$${(flightbookingitem.bookingResponse?.data?.booking?.commission ?? 0).toInt() + int.parse("${widget.totalPrice}")}',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 18,
                      //         fontFamily: 'Inter'.tr,
                      //         color: kPrimaryColor)),
                    ],
                  ),
                  Text('Credit want to pay?'.tr,
                      style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor)),
                  SizedBox(height: 16),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        // Left Side: Credit 0
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'Credit ${homeProvider.creditbalance?.data?.creditBalance ?? '0'}'
                                .tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            // width: 200,
                            child: TextField(
                              controller: _creditController,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: false, decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}$')),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Text(
                            '\$0',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pay now :'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              fontFamily: 'Inter'.tr,
                              color: kPrimaryColor)),
                      Text(
                          '\$${flightbookingitem.bookingResponse?.data?.booking?.total ?? 0} ',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              fontFamily: 'Inter'.tr,
                              color: kPrimaryColor)),
                    ],
                  ),

                  SizedBox(height: 16),
                  Separator(),
                  // Separator

                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Submission'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                            fontFamily: 'Inter'.tr,
                          ),
                        ),
                        SizedBox(height: 16),

                        // First Name
                        Text('First Name*'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter'.tr,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _firstNameController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your first name'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                            LengthLimitingTextInputFormatter(25),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name'.tr;
                            }
                            if (value.length > 25) {
                              return 'Name cannot exceed 25 characters'
                                  .tr; // Optional redundant check
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // Last Name
                        Text('Last Name*'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter'.tr,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your last name'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                            LengthLimitingTextInputFormatter(25),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name'.tr;
                            }
                            if (value.length > 25) {
                              return 'Name cannot exceed 25 characters'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // Email
                        Text('Email*'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter'.tr,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your email'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email'.tr;
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // Phone
                        Text('Phone*'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter'.tr,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your phone number'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\+?\d*$')),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number'.tr;
                            }
                            final phoneRegex = RegExp(r'^\+?\d{10,15}$');
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Please enter a valid phone number with 10–15 digits'
                                  .tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // Address Line 1
                        Text('Address Line 1'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller:
                              _addressLine1Controller, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your address'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // Address Line 2
                        Text('Address Line 2'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller:
                              _addressLine2Controller, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your address (optional)'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your address'.tr;
                          //   }
                          //   return null;
                          // },
                        ),
                        SizedBox(height: 12),

                        Text('Country*'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          hint: Text('Select your country'),
                          items: homeProvider.countryResponse!.data.isNotEmpty
                              ? homeProvider.countryResponse!.data
                                  .map((country) {
                                  return DropdownMenuItem<String>(
                                    value: country.code,
                                    child: Text(country.name),
                                  );
                                }).toList()
                              : [
                                  // Ensure there's a fallback if the list is empty
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('No countries available'),
                                  ),
                                ],
                          onChanged: (value) {
                            log('$value valuecountry');
                            setState(() {
                              selectedCountry =
                                  value; // Update selectedCountry on change
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a country';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 12),

                        // State/Province/Region
                        Text('State/Province/Region'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _stateController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your state or region'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your state or region'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // City
                        Text('City'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _cityController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your city'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your city'.tr;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 12),
                        // ZIP code/Postal code
                        Text('ZIP Code/Postal Code'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _zipCodeController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter your postal code'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set border radius
                              borderSide: BorderSide(
                                  color: Colors.grey), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.blue), // Focused border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey), // Enabled border color
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            // Allow alphanumeric characters only
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[a-zA-Z0-9]*$')),
                            LengthLimitingTextInputFormatter(
                                10), // Limit to 10 characters
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your postal code'.tr;
                            }
                            if (value.length < 5) {
                              return 'Postal code must be at least 5 characters long'
                                  .tr;
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 12),

                        // Country Dropdown

                        SizedBox(height: 12),

                        // Special Requirements
                        Text('Special Requirements'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller:
                              _specialRequirementsController, // Added controller
                          decoration: InputDecoration(
                            hintText: 'Enter any special requests'.tr,
                            border: OutlineInputBorder(),
                          ),

                          maxLines: 3,
                          keyboardType: TextInputType.text,

                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                500), // Limit input to 500 characters
                          ],
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'Please enter your special requests'.tr;
                            // }
                            if (value!.length > 500) {
                              return 'Special requests cannot exceed 500 characters'
                                  .tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        Separator(),
                        SizedBox(height: 16),

                        // Payment Method
                        Text(
                          'Payment Method'.tr,
                          style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor),
                        ),
                        SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border(
                              left: BorderSide(color: Colors.grey, width: 1.0),
                              top: BorderSide(color: Colors.grey, width: 1.0),
                              bottom:
                                  BorderSide(color: Colors.grey, width: 1.0),
                              right: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          child: RadioListTile(
                            title: Text('Offline Payment'.tr),
                            value: "offline",
                            groupValue: homeProvider.paymentMethod,
                            onChanged: (value) {
                              homeProvider.paymentMethod = value!;
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border(
                              left: BorderSide(color: Colors.grey, width: 1.0),
                              top: BorderSide(color: Colors.grey, width: 1.0),
                              bottom:
                                  BorderSide(color: Colors.grey, width: 1.0),
                              right: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          child: RadioListTile(
                            title: Text('Online Payment'.tr),
                            value: "online",
                            groupValue: homeProvider.paymentMethod,
                            onChanged: (value) {
                              homeProvider.paymentMethod = value!;
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _termsAccepted = value!;
                                });
                              },
                            ),
                            Expanded(
                                child: Text(
                              'I have read and accept the Terms & Conditions'
                                  .tr,
                              style: TextStyle(
                                fontFamily: 'Inter'.tr,
                                fontSize: 12,
                              ),
                            )),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Terms and Conditions Checkbox

                        SizedBox(height: 16),
                        TertiaryButton(
                          text: "Submit".tr,
                          press:
                              _submitBooking, // Updated to call the submit function
                        ),

                        // Submit Button
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       if (_formKey.currentState!.validate() &&
                        //           _termsAccepted) {
                        //         // Process the booking submission
                        //       }
                        //     },
                        //     child: Text('Submit'.tr),
                        //   ),
                        // ),
                        // TertiaryButton(
                        //   text: "Submit".tr,
                        //   press: () => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const BookingConfirmedScreen(),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
    );
  }
}

Widget _buildFlightInfo(
    String title, String time, String date, String location) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Inter',
              color: kSecondaryColor)),
      SizedBox(height: 5),
      Text(time,
          style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              fontFamily: 'Inter')),
      SizedBox(height: 5),
      Text(date,
          style:
              TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
      Text(location,
          style:
              TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
    ],
  );
}
