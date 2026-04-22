// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/boat/booking_confirm_boat_screen.dart';
import 'package:moonbnd/screens/payment_screen.dart';
import 'package:moonbnd/widgets/separator.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingScreenForBoat extends StatefulWidget {
  final String bookingCode;
  final int? totalPrice;
  final int? extraPrice;

  BookingScreenForBoat(
      {super.key,
      required this.bookingCode,
      this.totalPrice,
      this.extraPrice = 0});

  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreenForBoat> {
  DateTime? startDate;
  DateTime? endDate;
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  bool _isCouponApplied = false;
  int calculatedTime = 0;
  double rentalPrice = 0.0;
  final TextEditingController _specialRequirementsController =
      TextEditingController();
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
    // Fetch booking details asynchronously
    setState(() {
      loading = true;
    });
    _fetchBookingDetails().then((value) {
      calculateRentalPrice();
      _fetchCountries().then((ca) {
        setState(() {
          loading = false;
        });
      });
    });
  }

  void calculateRentalPrice() {
    final carbookingitem = Provider.of<HomeProvider>(context, listen: false);

    if (carbookingitem.bookingResponse?.data?.booking?.days == 0) {
      calculatedTime =
          int.parse("${carbookingitem.bookingResponse?.data?.booking?.hours}");

      rentalPrice = calculatedTime *
          double.parse(carbookingitem
                  .bookingResponse?.data?.booking?.service?.pricePerHour ??
              "1");
    } else {
      calculatedTime =
          int.parse("${carbookingitem.bookingResponse?.data?.booking?.days}");
      rentalPrice = calculatedTime *
          double.parse(carbookingitem
                  .bookingResponse?.data?.booking?.service?.pricePerDay ??
              "1");
    }
    setState(() {});
  }

  Future<void> _fetchCountries() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchCountries(); // Fetch countries
    setState(() {}); // Trigger a rebuild after fetching data
  }

  // Function to handle submission
  Future<void> _submitBooking() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Please accept the Terms & Conditions to proceed.'.tr)));
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
        loading = false;
      });

      // Print response for debugging
      log("API Response: $response"); // Added print statement

      if (response != null) {
        // Navigate to confirmation screen after successful submission
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingConfirmedScreenForBoat(bookingCode: widget.bookingCode),
          ),
        );
      }
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
          if (urlGo.contains("https://rawana.com/api/booking/confirm")) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmedScreenForBoat(
                    bookingCode: widget.bookingCode),
              ),
            );
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmedScreenForBoat(
                  bookingCode: widget.bookingCode),
            ),
          );
        }
      } else {
        setState(() {
          loading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to submit booking. Please try again.')));
      }
    }
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    log("${widget.totalPrice} total");
    final carbookingitem = Provider.of<HomeProvider>(context, listen: true);

    log("${double.parse('$calculatedTime') * double.parse(carbookingitem.bookingResponse?.data?.booking?.service?.pricePerDay ?? "1")} countryes");
    log("${carbookingitem.bookingResponse?.data?.booking?.days == 0 ? carbookingitem.bookingResponse?.data?.booking?.service?.pricePerHour : carbookingitem.bookingResponse?.data?.booking?.service?.pricePerDay} countryes 2");

    if (carbookingitem.bookingResponse == null) {
      return Center(
          child: CircularProgressIndicator(
              color: kSecondaryColor)); // Show loading indicator
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Booking'.tr, style:GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.black,

        )),
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
                    carbookingitem
                            .bookingResponse?.data?.booking?.service?.title ??
                        "",
                      style:GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.black,

                      )
                  ),
                  SizedBox(height: 10),
                  Text(
                    carbookingitem
                            .bookingResponse?.data?.booking?.service?.address ??
                        "",
                      style:GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black54

                      )
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          carbookingitem.bookingResponse?.data?.booking
                                  ?.service!.gallery?[0] ??
                              'assets/haven/house.png',
                          height: 130,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),

                      // Expanded(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           SizedBox(height: 25),
                      //           // Row(
                      //           //   children: [
                      //           //     // Star Icons.
                      //           //     SvgPicture.asset('assets/icons/star.svg'),
                      //           //     ...List.generate(
                      //           //       int.parse("2"),
                      //           //       (index) =>
                      //           //           Icon(Icons.star, color: AppColors.accent),
                      //           //     ),
                      //           //     SizedBox(width: 8),

                      //           //     // Review Text
                      //           //     Text(
                      //           //       '${carbookingitem.bookingResponse?.data?.booking?.service?.reviewScore ?? ""} (20 Reviews)'
                      //           //           .tr,
                      //           //       style: TextStyle(
                      //           //         fontSize: 14,
                      //           //         fontFamily: 'Inter'.tr,
                      //           //         fontWeight: FontWeight.w400,
                      //           //         color: grey,
                      //           //       ),
                      //           //     ),
                      //           //   ],
                      //           // ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Separator(), // Separator

                  // Trip details
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        'Vendor :'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )
                      ),
                      SizedBox(width: 10),
                      Text(
                        carbookingitem.bookingResponse?.data?.booking?.service
                                ?.vendorDetails?.name ??
                            "",
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black54

                          )
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start Date'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )
                      ),
                      Text(
                          DateFormat("dd/MM/yyyy").format(DateTime.parse(
                              carbookingitem.bookingResponse?.data?.booking
                                      ?.startDate ??
                                  '')),
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )),
                    ],
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )
                      ),
                      Text(
                          carbookingitem
                                  .bookingResponse?.data?.booking?.startTime ??
                              "",
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          carbookingitem.bookingResponse?.data?.booking?.days ==
                                  0
                              ? 'Hours'
                              : 'Days',
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )),
                      Text('$calculatedTime',
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )),
                    ],
                  ),

                  SizedBox(height: 20),

                  SizedBox(height: 16),
                  Separator(), // Separator
                  SizedBox(height: 16),
                  // Price details
                  Text(
                    'Extra Price :'.tr,
                      style:GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,


                      )
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Rental Price".tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,


                          )),
                      Spacer(),
                      Text('\$$rentalPrice',
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )),
                    ],
                  ),

                  ...(carbookingitem.bookingResponse?.data?.booking?.buyerFees)!
                      .map((element) {
                    return Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Text(element.name ?? "",
                              style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,


                              )),
                          Spacer(),
                          Text("\$${element.price}",
                              style:GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.black54

                              )),
                        ],
                      ),
                    );
                  }).toList(),

                  ...(carbookingitem
                          .bookingResponse?.data?.booking?.extraPrice)!
                      .map((element) {
                    return Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Text(element.name ?? "",
                              style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryColor)),
                          Spacer(),
                          Text("\$${element.price}",
                              style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: grey)),
                        ],
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 8),
                  Divider(), // Separator

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
                          onPressed: () async {
                            if (_isCouponApplied) {
                              await carbookingitem
                                  .removeCoupon(
                                carbookingitem
                                        .bookingResponse?.data?.booking?.code ??
                                    '',
                                _couponCodeController.text,
                                context,
                              )
                                  .then((value) async {
                                if (value) {
                                  await _fetchBookingDetails();
                                  setState(() {
                                    _isCouponApplied = false;
                                  });
                                  _couponCodeController.clear();
                                }
                              });
                            } else {
                              bool check = await carbookingitem.applyCoupon(
                                carbookingitem
                                        .bookingResponse?.data?.booking?.code ??
                                    '',
                                _couponCodeController.text,
                                context,
                              );
                              if (check) {
                                await _fetchBookingDetails();
                                setState(() {
                                  _isCouponApplied = true;
                                });
                              }
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
                  SizedBox(height: 8),
                  Divider(), // Separator

// Total Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,


                          )),
                      Text(
                          '\$${(carbookingitem.bookingResponse?.data?.booking?.total ?? 0)}',
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black,


                          )),
                      // Text(
                      //     '\$${(carbookingitem.bookingResponse?.data?.booking?.commission ?? 0).toInt() + int.parse("${widget.totalPrice}")}',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 18,
                      //         fontFamily: 'Inter'.tr,
                      //         color: kPrimaryColor)),
                    ],
                  ),
                  Divider(),
                  Text('Credit want to pay?'.tr,
                      style:GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,


                      )),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Credit ${carbookingitem.creditbalance?.data?.creditBalance ?? '0'}'
                                .tr
                                .tr,
                              style:GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black

                              )
                          ),
                        ),

                        Expanded(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            // width: 190,
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
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          )),
                      Text(
                          '\$${carbookingitem.bookingResponse?.data?.booking?.total ?? 0} ',
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black

                          )),
                    ],
                  ),
                  SizedBox(height: 16),
                  Separator(),
                  // Separator

                  // Separator

                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Submission'.tr,
                            style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black

                            )
                        ),
                        SizedBox(height: 16),

                        // First Name
                        Text('First Name*'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _firstNameController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your first name'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your last name'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your email'.tr,
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
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your phone number'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller:
                              _addressLine1Controller, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your address'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller:
                              _addressLine2Controller, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your address (optional)'.tr,
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter your address'.tr;
                          //   }
                          //   return null;
                          // },
                        ),
                        SizedBox(height: 12),
// Country Dropdown
                        Text('Country*'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: _greyFilledDecoration(
                            'Enter your country'.tr,
                          ),
                          hint: Text('Select your country'.tr),
                          items: carbookingitem.countryResponse!.data.isNotEmpty
                              ? carbookingitem.countryResponse!.data
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
                              return 'Please select a country'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        // State/Province/Region
                        Text('State/Province/Region'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _stateController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your state or region'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _cityController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your city'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _zipCodeController, // Added controller
                          decoration: _greyFilledDecoration(
                            'Enter your postal code'.tr,
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

                        // Special Requirements
                        Text('Special Requirements'.tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        TextFormField(
                          controller:
                              _specialRequirementsController, // Added controller
                          decoration:_greyFilledDecoration(
                            'Enter any special requests'.tr,
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
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            )
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
                            title: Text('Offline Payment'.tr,style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black,
                            )),
                            value: "offline",
                            groupValue: carbookingitem.paymentMethod,
                            onChanged: (value) {
                              carbookingitem.paymentMethod = value!;
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
                            title: Text('Online Payment'.tr,style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black,
                            )),
                            value: "online",
                            groupValue: carbookingitem.paymentMethod,
                            onChanged: (value) {
                              carbookingitem.paymentMethod = value!;
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
                                        .tr, style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ))),
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
InputDecoration _greyFilledDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    hintStyle: GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black54,
    ),
    fillColor: Colors.grey.shade200,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}