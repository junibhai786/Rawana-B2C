// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/payment_screen.dart';
import 'package:moonbnd/screens/space/space_confirm_screen.dart';
import 'package:moonbnd/widgets/separator.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpaceBookingScreen extends StatefulWidget {
  final String bookingCode;
  final int? totalPrice;
  final int? extraPrice;

  SpaceBookingScreen({
    super.key,
    required this.bookingCode,
    this.totalPrice,
    this.extraPrice = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<SpaceBookingScreen> {
  DateTime? startDate;
  DateTime? endDate;
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;

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
  bool _isCouponApplied = false;
  int txdaysDifference = 0;

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
    _fetchBookingDetails().then((value) {
      _fetchCountries();
    });
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
        // Navigate to confirmation screen after successful submission
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpaceConfirmScreen(
                bookingCode: widget.bookingCode,
                txdaysDifference: (txdaysDifference + 1)),
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
          log("----------------------------");

          if (urlGo.contains("https://travolyo.com/api/booking/confirm/")) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpaceConfirmScreen(
                    bookingCode: widget.bookingCode,
                    txdaysDifference: (txdaysDifference + 1)),
              ),
            );
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpaceConfirmScreen(
                  bookingCode: widget.bookingCode,
                  txdaysDifference: (txdaysDifference + 1)),
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
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.UserCreditbalance();
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {});
  }

  int calculateNights(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 0;

    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays; // Calculate difference in days
  }

  @override
  Widget build(BuildContext context) {
    log("${widget.totalPrice} total");
    final spacebookingitem = Provider.of<HomeProvider>(context, listen: true);

    log("${spacebookingitem.countries} countryes");

    if (spacebookingitem.bookingResponse == null) {
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
                    spacebookingitem
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
                    spacebookingitem
                            .bookingResponse?.data?.booking?.service?.address?.tr ??
                        "".tr,
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
                          spacebookingitem.bookingResponse?.data?.booking
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
                      //           //           Icon(Icons.star, color: Colors.yellow),
                      //           //     ),
                      //           //     SizedBox(width: 8),

                      //           //     // Review Text
                      //           //     Text(
                      //           //       '${spacebookingitem.bookingResponse?.data?.booking?.service?.reviewScore ?? ""} (20 Reviews)'
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
                        spacebookingitem.bookingResponse?.data?.booking?.service
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
                              spacebookingitem.bookingResponse?.data?.booking
                                      ?.startDate ??
                                  '')),
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )
                      ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       "${startDate != null ? DateFormat("MMM dd").format(startDate!) : ''}  ${endDate != null ? DateFormat("MMM dd").format(endDate!) : '5-8 Nov'.tr}",
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontFamily: 'Inter'.tr,
                      //         fontWeight: FontWeight.w400,
                      //         color: grey,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 8),
                      //     GestureDetector(
                      //       onTap: () {
                      //         showCustomDateRangePicker(
                      //           context,
                      //           dismissible: true,
                      //           minimumDate:
                      //               DateTime.now().subtract(Duration(days: 90)),
                      //           maximumDate: DateTime.now().add(Duration(days: 90)),
                      //           endDate: endDate,
                      //           startDate: startDate,
                      //           backgroundColor: kBackgroundColor,
                      //           primaryColor: kPrimaryColor,
                      //           onApplyClick: (start, end) {
                      //             setState(() {
                      //               endDate = end;
                      //               startDate = start;
                      //             });
                      //           },
                      //           onCancelClick: () {
                      //             setState(() {
                      //               endDate = null;
                      //               startDate = null;
                      //             });
                      //           },
                      //         );
                      //       },
                      //       child: SvgPicture.asset(
                      //         'assets/icons/edit_icon.svg',
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
                          DateFormat("dd/MM/yyyy").format(DateTime.parse(
                              spacebookingitem.bookingResponse?.data?.booking
                                      ?.endDate ??
                                  '')),
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
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
                        'Days'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )
                      ),
                      Text(
                        (() {
                          final startDate = DateTime.parse(spacebookingitem
                                  .bookingResponse?.data?.booking?.startDate ??
                              '');
                          final endDate = DateTime.parse(spacebookingitem
                                  .bookingResponse?.data?.booking?.endDate ??
                              '');
                          final daysDifference =
                              endDate.difference(startDate).inDays;

                          txdaysDifference = daysDifference;
                          return '${daysDifference + 1} days';
                        })(),
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
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
                      Text('Number Of Guests'.tr,
                          style:GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          )),
                      Text(
                          "${spacebookingitem.bookingResponse?.data?.booking?.totalGuests ?? 0}",
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Adults'.tr,
                  //         style: TextStyle(
                  //             fontSize: 16,
                  //             fontFamily: 'Inter'.tr,
                  //             fontWeight: FontWeight.w500,
                  //             color: kPrimaryColor)),
                  //     Row(
                  //       children: [
                  //         Text('2 adults',
                  //             style: TextStyle(
                  //                 fontSize: 16,
                  //                 fontFamily: 'Inter'.tr,
                  //                 fontWeight: FontWeight.w400,
                  //                 color: grey)),
                  //         const SizedBox(width: 8),
                  //         GestureDetector(
                  //           onTap: () {
                  //             showGuestBottomSheet(
                  //               context,
                  //               initialAdults: 2, // Set initial value to 2 adults
                  //               initialChildren: 0, // Set initial value to 0 children
                  //               onSave: (adults, children) {
                  //                 // Handle saving the selected number of guests
                  //                 setState(() {
                  //                   // Update your state variables here
                  //                 });
                  //               },
                  //             );
                  //           },
                  //           child: SvgPicture.asset(
                  //             'assets/icons/edit_icon.svg',
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),

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
                      Text(
                          ("\$${(spacebookingitem.bookingResponse?.data?.booking?.service?.salePrice == 0 ? spacebookingitem.bookingResponse?.data?.booking?.service?.price : spacebookingitem.bookingResponse?.data?.booking?.service?.salePrice) * (txdaysDifference + 1)}"),
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black54

                          )
                      ),
                    ],
                  ),

                  ...(spacebookingitem
                          .bookingResponse?.data?.booking?.buyerFees)!
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

                  ...(spacebookingitem
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

                  SizedBox(height: 18),

                  TextFormField(
                    controller: _couponCodeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Coupon Code'.tr,
                      hintStyle:  GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black54

                    ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isCouponApplied) {
                              spacebookingitem
                                  .removeCoupon(
                                spacebookingitem
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
                              spacebookingitem.applyCoupon(
                                spacebookingitem
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

                  SizedBox(height: 8),
                  Divider(), // Separator

                  SizedBox(height: 8),
// Total Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'.tr,
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,


                          )
                      ),
                      Text(
                          '\$${(spacebookingitem.bookingResponse?.data?.booking?.total ?? 0)}',
                          style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black

                      )),
                      // Text(
                      //     '\$${(spacebookingitem.bookingResponse?.data?.booking?.commission ?? 0).toInt() + int.parse("${widget.totalPrice}")}',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 18,
                      //         fontFamily: 'Inter'.tr,
                      //         color: kPrimaryColor)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  Text('Credit want to pay?'.tr,
                      style:GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,


                      )
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Left Side: Credit 0
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Credit ${spacebookingitem.creditbalance?.data?.creditBalance ?? '0'}'
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
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                          )
                      ),
                      Text(
                          '\$${spacebookingitem.bookingResponse?.data?.booking?.total ?? 0} ',
                          style:GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black

                          )),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
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
                            )


                        ),
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
                              return 'Please enter your address1'.tr;
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
                          //     return 'Please enter your address2'.tr;
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
                          items: spacebookingitem
                                  .countryResponse!.data.isNotEmpty
                              ? spacebookingitem.countryResponse!.data
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
                                    child: Text('No countries available'.tr),
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
                            style: TextStyle(
                                fontFamily: 'Inter'.tr, fontSize: 16)),
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
                              return 'Please enter your address1'.tr;
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
                            ),),
                            value: "offline",
                            groupValue: spacebookingitem.paymentMethod,
                            onChanged: (value) {
                              spacebookingitem.paymentMethod = value!;
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
                            groupValue: spacebookingitem.paymentMethod,
                            onChanged: (value) {
                              spacebookingitem.paymentMethod = value!;
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
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    )
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
