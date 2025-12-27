// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, sort_child_properties_last

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/country_modal.dart';
import 'package:moonbnd/screens/hotel/booking_confirm_screen.dart';
import 'package:moonbnd/screens/payment_screen.dart';
import 'package:moonbnd/widgets/separator.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingScreenForHotel extends StatefulWidget {
  final String bookingCode;
  BookingScreenForHotel({super.key, required this.bookingCode});

  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreenForHotel> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedCountry;
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isCouponApplied = false;
  bool _isOnlinePayment = true;
  int _selectedTabIndex = 0;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'Bank Transfer'
  ];
  final List<String> countryList = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'India',
    // Add more countries as needed
  ];

  int calculateNights(String? startDate, String? endDate) {
    if (startDate == null ||
        endDate == null ||
        startDate.isEmpty ||
        endDate.isEmpty) return 0;

    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays;
    } catch (e) {
      print('Error calculating nights: $e');
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    // _fetchBookingDetails();
    _fetchBookingDetails().then((value) {
      Provider.of<HomeProvider>(context, listen: false).fetchCountries();
    });
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.UserCreditbalance();
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {
      _isLoading = false;
    });
  }

  // Controllers for input fields
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
  @override
  void dispose() {
    // Dispose of the controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _specialRequirementsController.dispose();
    _creditController.dispose();
    super.dispose();
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
      // Prepare data for API call
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
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

      // print("Booking Data: $bookingData");
      try {
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

        // Print response for debugging
        // print("API Response: $response");

        // if (response != null) {
        //   // Navigate to confirmation screen after successful submission
        //   print("Response: ${response['booking_code']}");
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => BookingConfirmedScreen(
        //           bookingCode: response['booking_code'] as String),
        //     ),
        //   );
        // }
        if (response != null) {
          log("url kick in $response");
          if (response['status'] == 0) {
            if (response['message'] != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${response['message']}')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Failed to submit booking. Please try again.')));
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
            print("check in to $urlGo");
            if (urlGo.contains("https://travolyo.com/api/booking/confirm")) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingConfirmedScreen(bookingCode: widget.bookingCode),
                ),
              );
            }
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookingConfirmedScreen(bookingCode: widget.bookingCode),
              ),
            );
          }
        } else {
          // Handle error case
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to submit booking. Please try again.')));
        }
      } catch (e) {
        // Log the error
        print("Error during checkout: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'An error occurred during checkout. Please try again.'.tr)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelbookingitem = Provider.of<HomeProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Booking'.tr,style:GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.black,

        )),
        leading: BackButton(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelbookingitem
                              .bookingResponse?.data?.booking?.service?.title ??
                          '',
                        style:GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.black,

                        )
                    ),
                    SizedBox(height: 5),
                    Text(
                      hotelbookingitem.bookingResponse?.data?.booking?.service
                              ?.address ??
                          '',
                        style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black54

                        )
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              hotelbookingitem.bookingResponse?.data?.booking
                                  ?.service?.gallery?.isNotEmpty == true
                                  ? hotelbookingitem.bookingResponse!.data!.booking!
                                  .service!.gallery!.first
                                  : 'https://via.placeholder.com/120x80',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    SizedBox(height: 16),
                    Separator(), // Separator

                    // Trip details
                    SizedBox(height: 16),

                    Text(
                      'Your Trip'.tr,
                        style:GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,

                        )
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
                            hotelbookingitem.bookingResponse?.data?.booking
                                            ?.startDate !=
                                        null &&
                                    hotelbookingitem.bookingResponse!.data!
                                        .booking!.startDate!.isNotEmpty
                                ? DateFormat("dd/MM/yyyy").format(
                                    DateTime.parse(hotelbookingitem
                                        .bookingResponse!
                                        .data!
                                        .booking!
                                        .startDate!))
                                : '',
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
                          'End Date'.tr,
                            style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,

                            )
                        ),
                        Text(
                            hotelbookingitem.bookingResponse?.data?.booking
                                            ?.endDate !=
                                        null &&
                                    hotelbookingitem.bookingResponse!.data!
                                        .booking!.endDate!.isNotEmpty
                                ? DateFormat("dd/MM/yyyy").format(
                                    DateTime.parse(hotelbookingitem
                                        .bookingResponse!
                                        .data!
                                        .booking!
                                        .endDate!))
                                : '',
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
                        Text('Days'.tr,
                            style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,

                            )),
                        Text(
                            '${calculateNights(hotelbookingitem.bookingResponse?.data?.booking?.startDate, hotelbookingitem.bookingResponse?.data?.booking?.endDate)}',
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
                        Text('No. of Guests'.tr,
                            style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,

                            )),
                        Row(
                          children: [
                            Text(
                                hotelbookingitem.bookingResponse?.data?.booking
                                        ?.totalGuests
                                        .toString() ??
                                    '',
                                style:GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black54

                                )),
                            // const SizedBox(width: 8),
                            // GestureDetector(
                            //   onTap: () {
                            //     showGuestBottomSheet(
                            //       context,
                            //       initialAdults: 2, // Set initial value to 2 adults
                            //       initialChildren: 0, // Set initial value to 0 children
                            //       onSave: (adults, children) {
                            //         // Handle saving the selected number of guests
                            //         setState(() {
                            //           // Update your state variables here
                            //         });
                            //       },
                            //     );
                            //   },
                            //   child: SvgPicture.asset(
                            //     'assets/icons/edit_icon.svg',
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    Divider(
                      thickness: 1,
                    ),
                    SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Detail'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black

                          )
                      ),
                    ),
                    SizedBox(height: 16),
                    Separator(), // Separator
                    SizedBox(height: 16),
                    // Price details
                    // Text(
                    //   'Price Details'.tr,
                    //   style: TextStyle(
                    //       fontFamily: 'Inter'.tr,
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w600,
                    //       color: kPrimaryColor),
                    // ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rental Price'.tr,
                            style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,

                            )),
                        Text(
                            '\$${hotelbookingitem.bookingResponse?.data?.booking?.service?.roomDetails?.map((room) => '${room.price} * ${room.number}').join(', ') ?? ''}',
                            style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black54

                            )),
                      ],
                    ),
                    SizedBox(height: 10),

                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Extra Prices:".tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )),
                    ),

                    SizedBox(height: 10),
                    ...(hotelbookingitem
                                .bookingResponse?.data?.booking?.extraPrice ??
                            [])
                        .map((element) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(element.name ?? "",
                              style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,

                              )),
                          SizedBox(
                            height: 30,
                          ),
                          Text("\$${element.price}",
                              style:GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.black54

                              )),
                        ],
                      );
                    }),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Buyer Fees:".tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )),
                    ),

                    SizedBox(height: 5),
                    ...(hotelbookingitem
                                .bookingResponse?.data?.booking?.buyerFees ??
                            [])
                        .map((element) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(element.name ?? "",
                              style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,

                              )),
                          SizedBox(
                            height: 30,
                          ),
                          Text("\$${element.price}",
                              style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: grey)),
                        ],
                      );
                    }),

                    SizedBox(height: 16),

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
                                hotelbookingitem
                                    .removeCoupon(
                                  hotelbookingitem.bookingResponse?.data
                                          ?.booking?.code ??
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
                                hotelbookingitem.applyCoupon(
                                  hotelbookingitem.bookingResponse?.data
                                          ?.booking?.code ??
                                      '',
                                  _couponCodeController.text,
                                  context,
                                );
                                setState(() {
                                  _isCouponApplied = true;
                                });
                              }
                            },
                            child: Text(
                                _isCouponApplied ? 'Remove'.tr : 'Apply'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCouponApplied
                                  ? Colors.red
                                  : kSecondaryColor,
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

                    SizedBox(height: 8),
// Total Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total'.tr,
                            style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,

                            )),
                        Text(
                            '\$${hotelbookingitem.bookingResponse?.data?.booking?.total ?? 0} ',
                            style:GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black

                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    Text('Credit want to pay?'.tr,
                        style:GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,


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
                              'Credit ${hotelbookingitem.creditbalance?.data?.creditBalance ?? '0'}'
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                fontSize: 12,
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
                            '\$${hotelbookingitem.bookingResponse?.data?.booking?.total ?? 0} ',
                            style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black,
                            )),
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
                            controller:
                                _firstNameController, // Added controller
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
                          Text('Last Name*'.tr.tr,
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
                            decoration:_greyFilledDecoration(
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
                            hint: Text('Select your country'.tr, style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                            items: hotelbookingitem.countryResponse?.data
                                .map<DropdownMenuItem<String>>((Country value) {
                              return DropdownMenuItem<String>(
                                value: value.code, // Cast to String
                                child: Text(value.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCountry = value;
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
                          // City
                          SizedBox(height: 12.0),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              border: Border(
                                left:
                                    BorderSide(color: Colors.grey, width: 1.0),
                                top: BorderSide(color: Colors.grey, width: 1.0),
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1.0),
                                right:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              ),
                            ),
                            child: RadioListTile(
                              title: Text('Offline Payment'.tr,style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black,
                              )),
                              value: "offline",
                              groupValue: hotelbookingitem.paymentMethod,
                              onChanged: (value) {
                                hotelbookingitem.paymentMethod = value!;
                                setState(() {});
                              },
                            ),
                          ),
                          // _buildPaymentTypeSelection(),
                          SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              border: Border(
                                left:
                                    BorderSide(color: Colors.grey, width: 1.0),
                                top: BorderSide(color: Colors.grey, width: 1.0),
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1.0),
                                right:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              ),
                            ),
                            child: RadioListTile(
                              title: Text('Online Payment'.tr,style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black,
                              )),
                              value: "online",
                              groupValue: hotelbookingitem.paymentMethod,
                              onChanged: (value) {
                                hotelbookingitem.paymentMethod = value!;
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(height: 8),
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
                              Text(
                                'I have read and accept the Terms & Conditions'
                                    .tr,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,


                                  )
                              )
                            ],
                          ),
                          SizedBox(height: 16),
                          TertiaryButton(
                            text: "Submit".tr,
                            press: _submitBooking,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

//   Widget _buildPaymentTypeSelection() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.white,
//       ),
//       child: Column(
//         children: [
//           RadioListTile<bool>(
//             title: Text('Online Payment'),
//             value: true,
//             groupValue: _isOnlinePayment,
//             onChanged: (value) {
//               setState(() {
//                 _isOnlinePayment = value!;
//               });
//             },
//             activeColor: Colors.blue,
//             contentPadding: EdgeInsets.symmetric(horizontal: 16),
//           ),
//           Divider(height: 1),
//           RadioListTile<bool>(
//             title: Text('Offline Payment'),
//             value: false,
//             groupValue: _isOnlinePayment,
//             onChanged: (value) {
//               setState(() {
//                 _isOnlinePayment = value!;
//               });
//             },
//             activeColor: Colors.blue,
//             contentPadding: EdgeInsets.symmetric(horizontal: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOnlinePaymentContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: List.generate(
//             _paymentMethods.length,
//             (index) => Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 4),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _selectedTabIndex = index;
//                     });
//                   },
//                   child: Text(_paymentMethods[index]),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _selectedTabIndex == index
//                         ? kSecondaryColor
//                         : Colors.white,
//                     foregroundColor: _selectedTabIndex == index
//                         ? Colors.white
//                         : Colors.black,
//                     elevation: 0,
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       side: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 24),
//         _buildPaymentForm(),
//       ],
//     );
//   }

//   Widget _buildPaymentForm() {
//     switch (_selectedTabIndex) {
//       case 0:
//         return _buildCreditCardForm();
//       case 1:
//         return _buildDebitCardForm();
//       case 2:
//         return _buildBankTransferForm();
//       default:
//         return _buildCreditCardForm();
//     }
//   }

//   Widget _buildCreditCardForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _formLabel('Email'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Email',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//           keyboardType: TextInputType.emailAddress,
//         ),
//         SizedBox(height: 16),
//         _formLabel('Card Information'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//             hintText: 'Card Information',
//             suffixIcon: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.network(
//                     'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png',
//                     width: 40),
//                 SizedBox(width: 8),
//                 Image.network(
//                     'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
//                     width: 40),
//                 SizedBox(width: 12),
//               ],
//             ),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _formLabel('Expiry Date'),
//                   SizedBox(height: 8),
//                   TextField(
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       hintText: 'MM/YY',
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _formLabel('CVC'),
//                   SizedBox(height: 8),
//                   TextField(
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       hintText: 'CVC',
//                       suffixIcon: Icon(Icons.credit_card, color: Colors.grey),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         _formLabel('Name on Card'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Name',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         _formLabel('Country or Region'),
//         SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: 'India',
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//           items: ['India', 'USA', 'UK', 'Canada', 'Australia']
//               .map((country) => DropdownMenuItem(
//                     value: country,
//                     child: Text(country),
//                   ))
//               .toList(),
//           onChanged: (value) {},
//         ),
//         SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _buildDebitCardForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _formLabel('Email'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Email',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//           keyboardType: TextInputType.emailAddress,
//         ),
//         SizedBox(height: 16),
//         _formLabel('Debit Card Information'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Debit Card Number',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//             suffixIcon: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.network(
//                     'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png',
//                     width: 40),
//                 SizedBox(width: 8),
//                 Image.network(
//                     'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
//                     width: 40),
//                 SizedBox(width: 12),
//               ],
//             ),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _formLabel('Expiry Date'),
//                   SizedBox(height: 8),
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'MM/YY',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _formLabel('CVV'),
//                   SizedBox(height: 8),
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'CVV',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       suffixIcon: Icon(Icons.credit_card, color: Colors.grey),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         _formLabel('Name on Card'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Name',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         _formLabel('Country or Region'),
//         SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: 'India',
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//           items: ['India', 'USA', 'UK', 'Canada', 'Australia']
//               .map((country) => DropdownMenuItem(
//                     value: country,
//                     child: Text(country),
//                   ))
//               .toList(),
//           onChanged: (value) {},
//         ),
//         SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _buildBankTransferForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _formLabel('Bank Name'),
//         SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             hintText: 'Bank Name',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//           items: ['HDFC Bank', 'ICICI Bank', 'SBI', 'Axis Bank', 'PNB']
//               .map((bank) => DropdownMenuItem(
//                     value: bank,
//                     child: Text(bank),
//                   ))
//               .toList(),
//           onChanged: (value) {},
//         ),
//         SizedBox(height: 16),
//         _formLabel('Account Holder Name'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Account Holder Name',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         _formLabel('Account Number'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Account Number',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         SizedBox(height: 16),
//         _formLabel('SWIFT/IBC Code'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'SWIFT/IBC Code',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         _formLabel('Bank Branch'),
//         SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: 'Branch Location',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         _formLabel('Payment Proof'),
//         SizedBox(height: 8),
//         Container(
//           width: double.infinity,
//           height: 120,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey, style: BorderStyle.solid),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: InkWell(
//             onTap: () {},
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
//                 SizedBox(height: 8),
//                 Text(
//                   'Upload payment receipt',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'PDF, JPG or PNG (max. 5MB)',
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _formLabel(String label) {
//     return Text(
//       label,
//       style: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: Colors.black87,
//       ),
//     );
//   }
// }
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