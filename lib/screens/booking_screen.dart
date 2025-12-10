// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/booking_confirm_screen.dart';
import 'package:moonbnd/widgets/separator.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
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
  String? selectedCountry; // Declare selectedCountry variable
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  final List<String> countryList = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'India',
    // Add more countries as needed
  ];

  int calculateNights(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 0;

    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays; // Calculate difference in days
  }

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
    _fetchCountries(); // Add this line to fetch countries
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {});
  }

  Future<void> _fetchCountries() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchCountries(); // Fetch countries
    setState(() {}); // Trigger a rebuild after fetching data
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
    super.dispose();
  }

  // Function to handle submission
  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate() && _termsAccepted) {
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
        'payment_gateway': 'offline',
        'term_conditions': 'accepted',
        'coupon_code': '',
        'credit': '0',
      };

      print("Booking Data: $bookingData");

      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
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
      print("API Response: $response"); // Added print statement

      if (response != null) {
        // Navigate to confirmation screen after successful submission
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingConfirmedScreen(bookingCode: widget.bookingCode),
          ),
        );
      } else {
        // Handle error case
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to submit booking. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelbookingitem = Provider.of<HomeProvider>(context, listen: true);
    final countryProvider = Provider.of<HomeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Booking'.tr),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotelbookingitem.bookingResponse?.data?.booking?.service?.title ??
                  '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
                fontFamily: 'Inter'.tr,
              ),
            ),
            SizedBox(height: 5),
            Text(
              hotelbookingitem
                      .bookingResponse?.data?.booking?.service?.address ??
                  '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: grey,
                fontFamily: 'Inter'.tr,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    hotelbookingitem.bookingResponse?.data?.booking?.service!
                            .gallery?[0] ??
                        'assets/haven/house.png',
                    height: 80,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Dylan Villa'.tr,
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.w600,
                //           color: kPrimaryColor,
                //           fontFamily: 'Inter'.tr,
                //         ),
                //       ),
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             'Vasiliki, Greece'.tr,
                //             style: TextStyle(
                //               fontSize: 14,
                //               fontWeight: FontWeight.w400,
                //               color: grey,
                //               fontFamily: 'Inter'.tr,
                //             ),
                //           ),
                //           SizedBox(height: 25),
                //           Row(
                //             children: [
                //               // Star Icons.
                //               SvgPicture.asset('assets/icons/star.svg'),
                //               // ...List.generate(
                //               //   5,
                //               //   (index) =>  Icon(Icons.star,
                //               //       color: Colors.yellow),
                //               // ),
                //               SizedBox(width: 8),

                //               // Review Text
                //               Text(
                //                 '4.82 (20 Reviews)'.tr,
                //                 style: TextStyle(
                //                   fontSize: 14,
                //                   fontFamily: 'Inter'.tr,
                //                   fontWeight: FontWeight.w400,
                //                   color: grey,
                //                 ),
                //               ),
                //             ],
                //           ),
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

            Text(
              'Your Trip'.tr,
              style: TextStyle(
                  fontFamily: 'Inter'.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor),
            ),
            SizedBox(height: 20),

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
                    DateFormat("MMM dd").format(DateTime.parse(hotelbookingitem
                            .bookingResponse?.data?.booking?.startDate ??
                        '')),
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter'.tr,
                        fontWeight: FontWeight.w400,
                        color: grey)),
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
                  style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryColor),
                ),
                Text(
                    DateFormat("MMM dd").format(DateTime.parse(hotelbookingitem
                            .bookingResponse?.data?.booking?.endDate ??
                        '')),
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter'.tr,
                        fontWeight: FontWeight.w400,
                        color: grey)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Days'.tr,
                    style: TextStyle(
                        fontFamily: 'Inter'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor)),
                Text(
                    '${calculateNights(hotelbookingitem.bookingResponse?.data?.booking?.startDate, hotelbookingitem.bookingResponse?.data?.booking?.endDate)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter'.tr,
                        fontWeight: FontWeight.w400,
                        color: grey)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adults'.tr,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter'.tr,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor)),
                Row(
                  children: [
                    Text(
                        hotelbookingitem
                                .bookingResponse?.data?.booking?.totalGuests
                                .toString() ??
                            '',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter'.tr,
                            fontWeight: FontWeight.w400,
                            color: grey)),
                    const SizedBox(width: 8),
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
                style: TextStyle(
                  fontFamily: 'Inter'.tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
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
                    style: TextStyle(
                        fontFamily: 'Inter'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor)),
                Text(
                    hotelbookingitem.bookingResponse?.data?.booking?.total ??
                        '',
                    style: TextStyle(
                        fontFamily: 'Inter'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: grey)),
              ],
            ),
            SizedBox(height: 10),

            Container(
              alignment: Alignment.centerLeft,
              child: Text("Extra Prices:".tr,
                  style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),

            SizedBox(height: 10),
            ...(hotelbookingitem
                    .bookingResponse?.data?.booking?.service?.extraPrice)!
                .map((element) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(element.name ?? "",
                      style: TextStyle(
                        fontFamily: 'Inter'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor,
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

            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(width: 1),
                ),
                hintText: 'Coupon Code'.tr,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Apply'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 2),
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
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        fontFamily: 'Inter'.tr,
                        color: kPrimaryColor)),
                Text(
                    '\$${hotelbookingitem.bookingResponse?.data?.booking?.total ?? 0}',
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
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                        return 'Please enter your first name'.tr;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // Last Name
                  Text('Last Name*'.tr.tr,
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
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                        return 'Please enter your last name'.tr;
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email'.tr;
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number'.tr;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // Address Line 1
                  Text('Address Line 1'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _addressLine1Controller, // Added controller
                    decoration: InputDecoration(
                      hintText: 'Enter your address'.tr,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                  ),
                  SizedBox(height: 12),

                  // Address Line 2
                  Text('Address Line 2'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _addressLine2Controller, // Added controller
                    decoration: InputDecoration(
                      hintText: 'Enter your address (optional)'.tr,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                  ),
                  SizedBox(height: 12),

                  // City
                  Text('City'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController, // Added controller
                    decoration: InputDecoration(
                      hintText: 'Enter your city'.tr,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                  ),
                  SizedBox(height: 12),

                  // State/Province/Region
                  Text('State/Province/Region'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _stateController, // Added controller
                    decoration: InputDecoration(
                      hintText: 'Enter your state or region'.tr,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                  ),
                  SizedBox(height: 12),

                  // ZIP code/Postal code
                  Text('ZIP Code/Postal Code'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _zipCodeController, // Added controller
                    decoration: InputDecoration(
                      hintText: 'Enter your postal code'.tr,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Set border radius
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
                  ),
                  SizedBox(height: 12),

                  // Country Dropdown
                  Text('Country*'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
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
                    items: countryProvider.countries.isNotEmpty
                        ? countryProvider.countries.map((country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
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

                  // Special Requirements
                  Text('Special Requirements'.tr,
                      style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller:
                        _specialRequirementsController, // Added controller
                    decoration: InputDecoration(
                      hintText: 'Enter any special requests'.tr,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                        bottom: BorderSide(color: Colors.grey, width: 1.0),
                        right: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    child: RadioListTile(
                      title: Text('Offline Payment'.tr),
                      value: 'offline'.tr,
                      groupValue: 'paymentMethod'.tr,
                      onChanged: (value) {},
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
                      Text('I have read and accept the Terms & Conditions'.tr),
                    ],
                  ),
                  SizedBox(height: 16),

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
                  TertiaryButton(
                    text: "Submit".tr,
                    press:
                        _submitBooking, // Updated to call the submit function
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
