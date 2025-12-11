// ignore_for_file: unnecessary_const, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unused_local_variable, avoid_print, use_build_context_synchronously

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/data_models/room_detail_screen_data.dart' as rd;
import 'package:moonbnd/modals/hotel_detail_model.dart';
import 'package:moonbnd/modals/room_model.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/hotel/booking_screen.dart';
import 'package:moonbnd/widgets/enquiry_bottomsheet.dart';
import 'package:moonbnd/widgets/guest_bottomsheet.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:moonbnd/widgets/room_widget.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../constants.dart';

class RoomDetailScreen extends StatefulWidget {
  final int hotelId;
  final Room? room; // Add this line
  RoomDetailScreen(
      {super.key, required this.hotelId, this.room}); // Update this line

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>
    with TickerProviderStateMixin {
  int currentPage = 0;
  bool isBookTab = true;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  RoomResponse? roomResponse;
  String selectedGuests = "1 ${'adults'.tr}, 0 ${'children'.tr}";
  bool loading = false;
  // Add this new variable
  int total = 0;
  int extraPrice = 0;
  // Add this variable to track selected rooms
  Map<int, int> selectedRooms = {};

  // Add this variable with other class variables
  double bookingFee = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true; // Set loading to true when fetching data
    });
    Provider.of<HomeProvider>(context, listen: false)
        .fetchHotelDetails(widget.hotelId)
        .then((hotelDetail) {
      setState(() {
        loading = false; // Set loading to false when data is fetched
        // Calculate booking fee from hotel details
        bookingFee = double.parse(hotelDetail?.data?.bookingFee
            ?.firstWhere(
              (fee) => fee.name == "Service fee",
          orElse: () => BookingFee(name: "Service fee".tr, price: "0"),
        )
            .price ??
            "0");
      });
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate = DateTime.now();

    // If checking out, use check-in date + 1 day as initial date if check-in is selected
    if (!isCheckIn && checkInDate != null) {
      initialDate = checkInDate!.add(Duration(days: 1));
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCheckIn ? DateTime.now() : checkInDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = pickedDate;
          // Reset checkout date if it's before the new check-in date
          if (checkOutDate != null && checkOutDate!.isBefore(pickedDate)) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = pickedDate;
        }
      });
    }
  }

  Future<void> _checkAvailability() async {
    // Parse adults and children from selectedGuests
    final adults = int.parse(selectedGuests.split(',')[0].split(' ')[0]);
    final children = int.parse(selectedGuests.split(',')[1].split(' ')[1]);

    // Check if both adults and children are 0
    if (adults == 0 && children == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one guest'.tr)),
      );
      return;
    }

    if (checkInDate == null || checkOutDate == null) {
      // Show an error message if dates are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select check-in and check-out dates'.tr)),
      );
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final result = await homeProvider.checkHotelAvailability(
      hotelId: widget.hotelId.toString(),
      startDate: checkInDate!,
      endDate: checkOutDate!,
      adults: adults,
      children: children,
    );

    if (result != null) {
      setState(() {
        roomResponse = RoomResponse.fromJson(result);
        selectedRooms = {for (var room in roomResponse!.rooms) room.id: 0};
      });
      if (roomResponse!.rooms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No rooms available'.tr)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Availability checked successfully'.tr)),
        );
      }
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check availability'.tr)),
      );
    }
  }

  void _showGuestBottomSheet() {
    final guestParts = selectedGuests.split(',');
    final adults =
    int.parse(RegExp(r'\d+').firstMatch(guestParts[0])?.group(0) ?? '1');
    final children =
    int.parse(RegExp(r'\d+').firstMatch(guestParts[1])?.group(0) ?? '0');

    showGuestBottomSheet(
      context,
      initialAdults: adults,
      initialChildren: children,
      onSave: (adults, children) {
        setState(() {
          selectedGuests = "$adults ${'adults'.tr}, $children ${'children'.tr}";
        });
      },
    );
  }

  // Add this method to update selected rooms
  void updateSelectedRooms(int roomId, int quantity) {
    print('Room selected: Room ID $roomId, Quantity $quantity');
    setState(() {
      selectedRooms[roomId] = quantity;
    });
  }
  Widget _buildAmenityPill(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.black87),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final item = Provider.of<HomeProvider>(context, listen: true);
    print('Item: $item');
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor)) // Show loading indicator
          : SafeArea(
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //appbar + haven slider
                  // This replaces the entire previous Stack(children: [...]) structure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Back and Favorite Buttons (App Bar)
                      // This section maintains the exact style and logic you provided
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Back button
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200, // Use Colors.white or theme color
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),

                              Spacer(),

                              // Favorite button
                              // InkWell(
                              //   onTap: () async {
                              //     log("message");
                              //     final homeProvider =
                              //     Provider.of<HomeProvider>(context, listen: false);
                              //     final success = await homeProvider.addToWishlist(
                              //       '${widget.hotelId}',
                              //       'hotel',
                              //     );
                              //     homeProvider.fetchHotelDetails(widget.hotelId);
                              //     await homeProvider.hotellistapi(1, searchParams: {});
                              //
                              //     if (success == "Added to wishlist") {
                              //       setState(() {
                              //         item.hotelDetail?.data?.isInWishlist = true;
                              //       });
                              //     } else if (success == "Removed from wishlist") {
                              //       setState(() {
                              //         item.hotelDetail?.data?.isInWishlist = false;
                              //       });
                              //     }
                              //
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(content: Text(success)),
                              //     );
                              //   },
                              //   child: Padding(
                              //     padding: EdgeInsets.symmetric(horizontal: 12),
                              //     child: Container(
                              //       height: 32,
                              //       width: 32,
                              //       decoration: BoxDecoration(
                              //         color: Colors.grey.shade200, // Use Colors.white or theme color
                              //         borderRadius: BorderRadius.circular(50),
                              //       ),
                              //       child: Icon(
                              //         item.hotelDetail?.data?.isInWishlist == true
                              //             ? Icons.favorite
                              //             : Icons.favorite_border,
                              //         color: item.hotelDetail?.data?.isInWishlist == true
                              //             ? Colors.red
                              //             : Colors.black,
                              //         size: 18,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),

                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  item.hotelDetail?.data?.title ?? ''.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700, // Bold
                                    fontSize: 24,
                                    height: 32 / 24,
                                    letterSpacing: 0,
                                    color: Colors.black,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Colors.black54),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        (item.hotelDetail?.data?.address ?? '').tr, // <-- .tr ONLY here
                                        style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.w400, // Regular weight
                                          fontSize: 14,
                                          height: 19.5 / 14, // line-height
                                          letterSpacing: 0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "${item.hotelDetail?.data?.reviewScore?.totalReview ?? 0} Reviews".tr, // .tr ONLY here
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w400, // Regular
                                    fontSize: 13,
                                    height: 19.5 / 13, // line-height
                                    letterSpacing: 0,
                                    color: const Color(0xFF65758B), // #65758B
                                  ),
                                ),
                              ),

                              // ───────────────────────────────
                              // 1. IMAGE SLIDER (wrapped inside rounded top)
                              // ───────────────────────────────
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                ),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 250,
                                      width: MediaQuery.of(context).size.width,
                                      child: PageView.builder(
                                        onPageChanged: (value) {
                                          setState(() {
                                            currentPage = value;
                                          });
                                        },
                                        itemCount:
                                        item.hotelDetail?.data?.gallery?.length ?? 0,
                                        itemBuilder: (context, index) => SliderContent(
                                          imageUrl: item.hotelDetail?.data?.gallery?[index] ?? '',
                                        ),
                                        physics: const ClampingScrollPhysics(),
                                      ),
                                    ),

                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          // borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          '${currentPage + 1} / ${item.hotelDetail?.data?.gallery?.length}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            fontFamily: 'Inter'.tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // ───────────────────────────────
                              // 2. HOTEL TITLE + RATING BADGE
                              // ───────────────────────────────



                              // ───────────────────────────────
                              // 3. LOCATION ROW
                              // ───────────────────────────────



                              // ───────────────────────────────
                              // 4. REVIEW COUNT
                              // ───────────────────────────────



                              // ───────────────────────────────
                              // 5. ABOUT THIS HOTEL
                              // ───────────────────────────────
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildAmenityPill('Wifi',Icons.wifi),

                                    _buildAmenityPill('Pool',Icons.pool),
                                    _buildAmenityPill('Restaurant',Icons.restaurant_menu),


                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   'About this hotel'.tr,
                                    //   style: TextStyle(
                                    //     fontSize: 18,
                                    //     fontWeight: FontWeight.w600,
                                    //     fontFamily: 'Inter'.tr,
                                    //     color: Colors.black,
                                    //   ),
                                    // ),
                                    const SizedBox(height: 10),

                                    ExpandableHtmlContent(
                                      content: item.hotelDetail?.data?.content ?? '',
                                      primaryColor: kPrimaryColor,
                                      textStyle: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w400, // Regular
                                        fontSize: 14,
                                        height: 21 / 14, // line-height
                                        letterSpacing: 0,
                                        color: const Color(0xFF65758B), // #65758B
                                      ),
                                      readMoreText: 'Read more'.tr, // .tr ONLY here
                                    ),


                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),




                      //     Padding(
                      //   padding: EdgeInsets.all(20.0),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.grey.withOpacity(0.3),
                      //           spreadRadius: 2,
                      //           blurRadius: 5,
                      //         ),
                      //       ],
                      //       border: Border.all(color: Colors.grey.shade300),
                      //     ),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         // Tabs: Book and Enquiry
                      //         Row(
                      //           children: [
                      //             Expanded(
                      //               child: InkWell(
                      //                 onTap: () {
                      //                   setState(() {
                      //                     isBookTab = true;
                      //                   });
                      //                 },
                      //                 child: Container(
                      //                   padding: EdgeInsets.all(15),
                      //                   alignment: Alignment.center,
                      //                   child: Text(
                      //                     'Book'.tr,
                      //                     style: TextStyle(
                      //                       fontFamily: 'Inter'.tr,
                      //                       color:
                      //                           isBookTab ? kSecondaryColor : grey,
                      //                       fontSize: 14,
                      //                       fontWeight: isBookTab
                      //                           ? FontWeight.bold
                      //                           : FontWeight.normal,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             Expanded(
                      //               child: InkWell(
                      //                 onTap: () {
                      //                   setState(() {
                      //                     isBookTab = false;
                      //                   });
                      //                   EnquiryBottomSheet.show(
                      //                     context,
                      //                     serviceId: item.hotelDetail?.data?.id
                      //                             .toString() ??
                      //                         '',
                      //                     serviceType: 'hotel',
                      //                     onEnquirySubmit:
                      //                         (name, email, phone, note) {
                      //                       print(
                      //                           'Enquiry submitted: $name, $email, $phone, $note');
                      //                     },
                      //                     onClose: () {
                      //                       setState(() {
                      //                         isBookTab = true;
                      //                       });
                      //                     },
                      //                   );
                      //                 },
                      //                 child: Container(
                      //                   padding: EdgeInsets.all(15),
                      //                   alignment: Alignment.center,
                      //                   child: Text(
                      //                     'Enquiry'.tr,
                      //                     style: TextStyle(
                      //                       fontFamily: 'Inter'.tr,
                      //                       color:
                      //                           !isBookTab ? kSecondaryColor : grey,
                      //                       fontSize: 14,
                      //                       fontWeight: !isBookTab
                      //                           ? FontWeight.bold
                      //                           : FontWeight.normal,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //
                      //         Row(
                      //           children: [
                      //             Expanded(
                      //               child: Divider(
                      //                 height: isBookTab ? 3 : 1,
                      //                 thickness: isBookTab ? 3 : 1,
                      //                 color: isBookTab ? kSecondaryColor : grey,
                      //               ),
                      //             ),
                      //             Expanded(
                      //               child: Divider(
                      //                 height: isBookTab ? 1 : 3,
                      //                 thickness: isBookTab ? 1 : 3,
                      //                 color: !isBookTab ? kSecondaryColor : grey,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //
                      //         // Only show content for Book tab
                      //         if (isBookTab) ...[
                      //           // Pricing or Enquiry Message based on Tab
                      //           Padding(
                      //             padding: EdgeInsets.all(16.0),
                      //             child: Align(
                      //               alignment: Alignment.centerLeft,
                      //               child: roomResponse != null &&
                      //                       roomResponse!.rooms.isNotEmpty
                      //                   ? Text(
                      //                       '\$${roomResponse!.rooms[0].price.toStringAsFixed(2)}',
                      //                       style: TextStyle(
                      //                         fontSize: 20,
                      //                         fontFamily: 'Inter'.tr,
                      //                         fontWeight: FontWeight.w600,
                      //                         color: kPrimaryColor,
                      //                       ),
                      //                     )
                      //                   : Text(
                      //                       'Check availability for pricing'.tr,
                      //                       style: TextStyle(
                      //                         fontSize: 16,
                      //                         fontFamily: 'Inter'.tr,
                      //                         fontWeight: FontWeight.w500,
                      //                         color: Colors.grey,
                      //                       ),
                      //                     ),
                      //             ),
                      //           ),
                      //
                      //           // Container for Check-in, Check-out, and Guests
                      //           Padding(
                      //             padding: EdgeInsets.symmetric(
                      //                 vertical: 15.0, horizontal: 15),
                      //             child: Container(
                      //               padding: EdgeInsets.all(10),
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(15),
                      //                 border:
                      //                     Border.all(color: Colors.grey.shade300),
                      //               ),
                      //               child: Column(
                      //                 children: [
                      //                   Row(
                      //                     children: [
                      //                       // Check-in date
                      //                       Expanded(
                      //                         child: GestureDetector(
                      //                           onTap: () {
                      //                             _selectDate(context, true);
                      //                           },
                      //                           child: Column(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                             children: [
                      //                               Text(
                      //                                 "Check-in".tr,
                      //                                 style: TextStyle(
                      //                                   fontFamily: 'Inter'.tr,
                      //                                   color: kPrimaryColor,
                      //                                   fontSize: 12,
                      //                                 ),
                      //                               ),
                      //                               SizedBox(height: 5),
                      //                               Container(
                      //                                 padding: EdgeInsets.all(8),
                      //                                 decoration: BoxDecoration(
                      //                                   borderRadius:
                      //                                       BorderRadius.circular(
                      //                                           8),
                      //                                   border: Border.all(
                      //                                       color: Colors
                      //                                           .grey.shade300),
                      //                                 ),
                      //                                 child: Text(
                      //                                   checkInDate != null
                      //                                       ? DateFormat(
                      //                                               'd/MM/yyyy')
                      //                                           .format(
                      //                                               checkInDate!)
                      //                                       : 'Select date'.tr,
                      //                                   style: TextStyle(
                      //                                     color: checkInDate != null
                      //                                         ? Colors.black
                      //                                         : Colors.grey,
                      //                                     fontWeight: checkInDate !=
                      //                                             null
                      //                                         ? FontWeight.normal
                      //                                         : FontWeight.w300,
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                       ),
                      //
                      //                       // Vertical line
                      //                       Container(
                      //                         width: 1,
                      //                         height: 60,
                      //                         color: Colors.grey,
                      //                         margin: EdgeInsets.symmetric(
                      //                             horizontal: 10),
                      //                       ),
                      //
                      //                       // Check-out date
                      //                       Expanded(
                      //                         child: GestureDetector(
                      //                           onTap: () {
                      //                             _selectDate(context, false);
                      //                           },
                      //                           child: Column(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.center,
                      //                             children: [
                      //                               Text("Check-out".tr,
                      //                                   style: TextStyle(
                      //                                     fontFamily: 'Inter'.tr,
                      //                                     color: kPrimaryColor,
                      //                                     fontSize: 12,
                      //                                   )),
                      //                               SizedBox(height: 5),
                      //                               Container(
                      //                                 padding: EdgeInsets.all(8),
                      //                                 decoration: BoxDecoration(
                      //                                   borderRadius:
                      //                                       BorderRadius.circular(
                      //                                           8),
                      //                                   border: Border.all(
                      //                                       color: Colors
                      //                                           .grey.shade300),
                      //                                 ),
                      //                                 child: Text(
                      //                                   checkOutDate != null
                      //                                       ? (checkOutDate!.isAfter(
                      //                                               checkInDate ??
                      //                                                   DateTime
                      //                                                       .now())
                      //                                           ? DateFormat(
                      //                                                   'd/MM/yyyy')
                      //                                               .format(
                      //                                                   checkOutDate!)
                      //                                           : 'Invalid date'.tr)
                      //                                       : 'Select date'.tr,
                      //                                   style: TextStyle(
                      //                                     color: checkOutDate !=
                      //                                             null
                      //                                         ? (checkOutDate!.isAfter(
                      //                                                 checkInDate ??
                      //                                                     DateTime
                      //                                                         .now())
                      //                                             ? Colors.black
                      //                                             : Colors.red)
                      //                                         : Colors.grey,
                      //                                     fontWeight:
                      //                                         checkOutDate != null
                      //                                             ? FontWeight
                      //                                                 .normal
                      //                                             : FontWeight.w300,
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //
                      //                   // Guests Dropdown
                      //                   Divider(
                      //                     thickness: 1,
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.only(top: 5),
                      //                     child: Column(
                      //                       crossAxisAlignment:
                      //                           CrossAxisAlignment.start,
                      //                       children: [
                      //                         Text(
                      //                           "Guests".tr,
                      //                           style: TextStyle(
                      //                               fontSize: 12,
                      //                               fontFamily: 'Inter'.tr,
                      //                               fontWeight: FontWeight.w600,
                      //                               color: kPrimaryColor),
                      //                         ),
                      //                         InkWell(
                      //                           onTap: _showGuestBottomSheet,
                      //                           child: Container(
                      //                             padding: EdgeInsets.symmetric(
                      //                                 horizontal: 12, vertical: 8),
                      //                             decoration: BoxDecoration(
                      //                               border: Border.all(
                      //                                   color:
                      //                                       Colors.grey.shade300),
                      //                               borderRadius:
                      //                                   BorderRadius.circular(8),
                      //                             ),
                      //                             child: Row(
                      //                               mainAxisAlignment:
                      //                                   MainAxisAlignment
                      //                                       .spaceBetween,
                      //                               children: [
                      //                                 Text(
                      //                                   selectedGuests,
                      //                                   style: TextStyle(
                      //                                     fontFamily: 'Inter'.tr,
                      //                                     fontSize: 14,
                      //                                   ),
                      //                                 ),
                      //                                 Icon(Icons.arrow_drop_down),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //
                      //           SizedBox(height: 20),
                      //
                      //           // Check Availability Button
                      //           Padding(
                      //             padding: EdgeInsets.symmetric(horizontal: 15),
                      //             child: TertiaryButton(
                      //               text: "Check Availability".tr,
                      //               press: _checkAvailability,
                      //             ),
                      //           ),
                      //
                      //           SizedBox(height: 20),
                      //         ],
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      if (roomResponse != null)
                        ...roomResponse!.rooms.map((room) => RoomWidget(
                          room: room,
                          onQuantityChanged: updateSelectedRooms,
                        )),

                      SizedBox(
                        height: 5,
                      ),


                      SizedBox(
                        height: 10,
                      ),  // Divider(
                      //   thickness: 1,
                      //   endIndent: 30,
                      //   indent: 30,
                      // ),

                      ...item.hotelDetail?.data?.terms?.map((term) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Category Heading ---
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                term.parent?.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Wrap(
                                runSpacing: 0, // Vertical spacing between lines
                                spacing: 0, // Horizontal spacing between items
                                children: term.child?.map((facility) {
                                  String iconPath = facility.imageUrl ??
                                      'assets/haven/wifi.png';
                                  return _buildFacilityItem(
                                      iconPath, facility.title ?? '');
                                }).toList() ??
                                    <Widget>[],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        );
                      }) ??
                          [],

                      SizedBox(
                        height: 10,
                      ),


                      SizedBox(
                        height: 5,
                      ),
                      // Padding(
                      //   padding: EdgeInsets.all(20.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text('Rules'.tr,
                      //           style: TextStyle(
                      //               color: kPrimaryColor,
                      //               fontSize: 18,
                      //               fontFamily: 'Inter'.tr,
                      //               fontWeight: FontWeight.w600)),
                      //       SizedBox(height: 20),
                      //       _buildRuleItem('Check in'.tr,
                      //           item.hotelDetail?.data?.checkInTime ?? ''),
                      //       SizedBox(height: 10),
                      //       _buildRuleItem('Check out'.tr,
                      //           item.hotelDetail?.data?.checkOutTime ?? ''),
                      //       SizedBox(height: 20),
                      //       Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: item.hotelDetail?.data?.policy
                      //                 ?.map((policy) {
                      //               return Column(
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     policy.title ?? '',
                      //                     style: TextStyle(
                      //                       fontFamily: 'Inter'.tr,
                      //                       fontWeight: FontWeight.w600,
                      //                       fontSize: 16,
                      //                       color: kPrimaryColor,
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 8),
                      //                   Text(
                      //                     policy.content ?? '',
                      //                     style: TextStyle(
                      //                       fontFamily: 'Inter'.tr,
                      //                       fontSize: 14,
                      //                       color: Colors.grey[600],
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 16),
                      //                 ],
                      //               );
                      //             }).toList() ??
                      //             [],
                      //       ),
                      //       SizedBox(height: 20),
                      //       Divider(
                      //         thickness: 1,
                      //         indent: 20,
                      //         endIndent: 20,
                      //       )
                      //     ],
                      //   ),
                      // ),
                      //
                      // SizedBox(
                      //   height: 5,
                      // ),

                      //map

                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 20),
                      //   child: Text("Location".tr,
                      //       style: TextStyle(
                      //           fontFamily: 'Inter'.tr,
                      //           color: kPrimaryColor,
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.w600)),
                      // ),
                      // SizedBox(
                      //   height: 12,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20),
                      //   child: Container(
                      //     height: 200,
                      //     child: GoogleMap(
                      //       initialCameraPosition: CameraPosition(
                      //         target: LatLng(
                      //             double.parse(
                      //                 item.hotelDetail?.data?.mapLat ?? '0'),
                      //             double.parse(
                      //                 item.hotelDetail?.data?.mapLng?.toString() ??
                      //                     '0')),
                      //         zoom: double.parse(
                      //             item.hotelDetail?.data?.mapZoom?.toString() ??
                      //                 '12'),
                      //       ),
                      //       markers: {
                      //         Marker(
                      //           markerId: MarkerId('hotel'),
                      //           position: LatLng(
                      //             double.parse(
                      //                 item.hotelDetail?.data?.mapLat ?? '0'),
                      //             double.parse(
                      //                 item.hotelDetail?.data?.mapLng?.toString() ??
                      //                     '0'),
                      //           ),
                      //         ),
                      //       },
                      //     ),
                      //   ),
                      // ),
                      //
                      // SizedBox(
                      //   height: 32,
                      // ),
                      //
                      // Divider(
                      //   thickness: 1,
                      //   indent: 20,
                      //   endIndent: 20,
                      // ),
                      // //review slider
                      // SizedBox(
                      //   height: 12,
                      // ),
                      _buildRatingSection(item.hotelDetail!),
                      _buildRatingBars(item.hotelDetail!),
                      ...(item.hotelDetail?.data?.reviewLists?.data ?? [])
                          .map((review) => _buildReviewItem(review)),
                      SizedBox(
                        height: 5,
                      ),

                      //This seciton is being comment out because it is the section where we are writing the review ...

                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 20),
                      //   child: Text("Write a Review".tr,
                      //       style: TextStyle(
                      //           color: kPrimaryColor,
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.w600)),
                      // ),
                      //
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // _buildReviewWidget(item.hotelDetail ?? HotelDetail()),
                      // SizedBox(height: 10),
                      // Divider(thickness: 1),
                      // ...(item.hotelDetail?.data?.extraPrice ?? []).map((element) {
                      //   return Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: 15),
                      //     child: Row(
                      //       children: [
                      //         Checkbox(
                      //             materialTapTargetSize:
                      //                 MaterialTapTargetSize.shrinkWrap,
                      //             value: element.valueType,
                      //             onChanged: (bool? value) {
                      //               if (value != null) {
                      //                 element.valueType = value;
                      //
                      //                 if (element.valueType == true) {
                      //                   extraPrice +=
                      //                       int.parse(element.price ?? "0");
                      //                 } else {
                      //                   extraPrice -=
                      //                       int.parse(element.price ?? "0");
                      //                 }
                      //                 setState(() {});
                      //               }
                      //             }),
                      //         Text(element.name ?? ""),
                      //         Spacer(),
                      //         Text("\$${element.price}"),
                      //       ],
                      //     ),
                      //   );
                      // }),
                      // _buildExtraServicesWidget(
                      //     item.hotelDetail ?? HotelDetail(), selectedRooms),

                      Divider(),

                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                    ],
                  ),

                  //price & reserve button
                ] )),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //price
              SizedBox(
                height: 44,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                              () {
                            double totalPrice = 0;
                            if (roomResponse != null &&
                                roomResponse!.rooms.isNotEmpty) {
                              selectedRooms.forEach((roomId, quantity) {
                                var room = roomResponse!.rooms
                                    .firstWhere((r) => r.id == roomId);
                                totalPrice += room.price * quantity;
                              });
                              // Add service fee to the total price
                              totalPrice += bookingFee + extraPrice;
                              return "\$${totalPrice.toStringAsFixed(2)}".tr;
                            }

                            return "\$${bookingFee.toStringAsFixed(2)}".tr;
                          }(),
                          style: TextStyle(
                            fontFamily: 'Inter'.tr,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          " / night".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter'.tr,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      checkInDate != null && checkOutDate != null
                          ? "${DateFormat('MMM d').format(checkInDate!)} - ${DateFormat('MMM d').format(checkOutDate!)}"
                          : "Select dates".tr,
                      style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          decoration: TextDecoration.underline),
                    )
                  ],
                ),
              ),

              //reserve button
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('userToken');

                    if (token == null) {
                      // Show the custom bottom sheet
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        builder: (context) => CustomBottomSheet(
                          title: 'Log in to complete',
                          content: 'your booking',
                          onCancel: () {
                            Navigator.of(context).pop(); // Close the bottom sheet
                          },
                          onLogin: () {
                            // Close the bottom sheet
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()),
                            ); // Navigate to SignInScreen
                          },
                        ),
                      );
                      return; // Exit the function if token is null
                    }
                    if (checkInDate == null || checkOutDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Please select check-in and check-out dates'.tr)),
                      );
                      return;
                    }

                    if (roomResponse == null || roomResponse!.rooms.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please check availability first'.tr)),
                      );
                      return;
                    }

                    final selectedRoomsList = selectedRooms.entries
                        .where((entry) => entry.value > 0)
                        .map((entry) => {
                      'id': entry.key,
                      'number_selected': entry.value,
                    })
                        .toList();

                    if (selectedRoomsList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please select at least one room'.tr)),
                      );
                      return;
                    }
                    // extraPrice.((serviceName, isSelected) {
                    //   if (isSelected) {
                    //     print('$serviceName added to cart');
                    //   }
                    // });

                    final homeProvider =
                    Provider.of<HomeProvider>(context, listen: false);

                    final result = await homeProvider.addToCartForHotel(
                      serviceId: item.hotelDetail?.data?.id.toString() ?? '',
                      serviceType: 'hotel',
                      startDate: checkInDate!,
                      endDate: checkOutDate!,
                      extraPrices: item.hotelDetail?.data?.extraPrice,
                      adults: int.parse(
                          selectedGuests.split(',')[0].trim().split(' ')[0]),
                      children: int.tryParse(selectedGuests
                          .split(',')[1]
                          .trim()
                          .split(' ')[0]) ??
                          0,
                      rooms: selectedRoomsList,
                    );

                    if (result != null && result['status'] == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully added to booking')),
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => BookingScreenForHotel(
                                bookingCode: result['booking_code'])),
                      );
                      print("Booking Code: ${result['booking_code']}");
                      // NavNigate to cart screen or show confirmation dialog
                    } else {
                      String errorMessage = 'Failed to add to booking';
                      if (result != null && result['errors'] != null) {
                        if (result['errors']['rooms'] != null) {
                          errorMessage = result['errors']['rooms'][0];
                        } else {
                          errorMessage = result['errors'].values.join(', ');
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  },
                  child: Text("Book Now".tr),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//review slider item

class ReviewSliderItem extends StatelessWidget {
  ReviewSliderItem({
    super.key,
    required this.dataSrc,
  });

  final rd.ReviewData dataSrc;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: 0.75 * screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //rating, time
          Row(
            children: [
              RatingBarIndicator(
                rating: dataSrc.rating,
                itemCount: 5,
                itemSize: 12,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                Icons.fiber_manual_record,
                size: 4,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                dataSrc.date,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),

          //review content
          Text(
            dataSrc.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Show more".tr,
            style: TextStyle(
              fontFamily: 'Inter'.tr,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(
            height: 16,
          ),

          //avatar, name, country
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(dataSrc.avatar),
                radius: 24,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataSrc.name,
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dataSrc.location,
                    style: TextStyle(
                      color: kColor1,
                      fontSize: 12,
                      fontFamily: 'Inter'.tr,
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

//offer item

class OfferItem extends StatelessWidget {
  OfferItem({
    super.key,
    required this.dataSrc,
  });

  final rd.OfferData dataSrc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(dataSrc.kIcon),
          SizedBox(
            width: 12,
          ),
          Text(
            dataSrc.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

//room specification item

class RoomSpecsItem extends StatelessWidget {
  RoomSpecsItem({
    super.key,
    required this.dataSrc,
  });

  final rd.RoomSpecsData dataSrc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              dataSrc.kIcon,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dataSrc.title,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  dataSrc.subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 12,
                    color: kColor1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildRatingSection(HotelDetail hotelDetail) {
  const Color textColor = Colors.white;

  return Center(
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF05A8C7),
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 120.0,vertical: 6),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text(
                '${hotelDetail.data?.reviewScore?.scoreTotal ?? '0'}/5',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700, // Bold
                  fontSize: 36,
                  height: 40 / 36, // line-height
                  letterSpacing: 0,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),
              Text(
                (hotelDetail.data?.reviewScore?.scoreText ?? 'Very Good').tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w400, // Regular
                  fontSize: 14,
                  height: 20 / 14,
                  letterSpacing: 0,
                  color: textColor,
                ),
              ),

            ],
          ),
        ],
      ),
    ),
  );
}

// Assuming HotelDetail is defined in your project
// Assuming kSecondaryColor is defined

Widget _buildRatingBar(String title, double ratio) {
  final double score = ratio * 5.0;

  return Padding(
    // Added bottom padding to create separation between different bars
    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
      children: [
        // 1. Bar and Title Section (The left and central part of the visual)
        Expanded(
          // Takes up most of the horizontal space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 20 / 14,
                  letterSpacing: 0,
                  color: Color(0xff1D2025),
                ),
              ),


              const SizedBox(height: 4), // Space between title and bar

              // --- Rating Bar (Covers full width of this Expanded area) ---
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Background Bar (Light Grey)
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Foreground Bar (Secondary Color)
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: kSecondaryColor, // Assuming kSecondaryColor is the blue color
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Score Value (Right-aligned, outside the bar's Expanded area)
        const SizedBox(width: 8),
        Text(
          score.toStringAsFixed(1),
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w500, // Medium
              fontSize: 14,
              height: 20 / 14, // line-height
              letterSpacing: 0,
              color: Color(0xff1D2025)
          ),
        ),

      ],
    ),
  );
}

// ----------------------------------------------------------------------
// NOTE: The _buildRatingBars widget remains mostly the same, as the changes
// are contained within the _buildRatingBar helper.
// ----------------------------------------------------------------------

Widget _buildRatingBars(HotelDetail hotelDetail) {
  final rateScores = hotelDetail.data?.reviewScore?.rateScore ?? [];

  return Container(
    // 1. Card Styling
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),

    // 2. Inner Padding and Content
    child: Padding(
      // Padding inside the card
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          for (var score in rateScores)
            _buildRatingBar(
              score.title ?? '',
              (score.percent ?? 0).toDouble() / 100,
            ),
        ],
      ),
    ),
  );
}

Widget _buildReviewItem(ReviewData review) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: Color(0xffFFFFFF),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(review.author?.avatarUrl ?? ''),
                radius: 20,
              ),
              const SizedBox(width: 12),

              // ★ FIX: Give bounded width to this Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// NAME + DATE ROW FIXED
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(
                              review.author?.name ?? '',
                              style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontWeight: FontWeight.w500, // "Medium" in Figma = w500
                                  fontSize: 14,
                                  height: 20 / 14, // line-height = 20px
                                  letterSpacing: 0,
                                  color: Color(0xff1D2025)
                              ),
                              overflow: TextOverflow.ellipsis,
                            )

                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(
                            DateTime.parse(
                              review.createdAt ??
                                  DateTime.now().toString(),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w400, // Regular
                            fontSize: 12,
                            height: 16 / 12, // exact line-height from Figma
                            letterSpacing: 0,
                            color: Color(0xff65758B),
                          ),

                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          Icons.star,
                          color: index < (review.rateNumber ?? 0)
                              ? Colors.yellow
                              : Colors.grey,
                          size: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            review.content ?? '',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w400, // Regular
              fontSize: 14,
              height: 21 / 14, // Figma line-height (21px)
              letterSpacing: 0,
              color: Color(0xff65758B),
            ),
          )

        ],
      ),
    ),
  );
}

Widget _buildReviewWidget(HotelDetail hotelDetail) {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Map<String, int> ratings = {
    'Service'.tr: 0,
    'Organization'.tr: 0,
    'Friendliness'.tr: 0,
    'Area Expert'.tr: 0,
    'Safety'.tr: 0,
  };

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title'.tr,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: kColor1),
                ),
                labelStyle: TextStyle(color: grey),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Review Content'.tr,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: kColor1),
                ),
                labelStyle: TextStyle(color: grey),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your review'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kColor1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: ratings.entries
                    .map((entry) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(entry.key,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: grey,
                              fontSize: 14)),
                      Row(
                        children: List.generate(
                            5,
                                (index) => GestureDetector(
                              child: Icon(
                                index < entry.value
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.black,
                                size: 24,
                              ),
                              onTap: () {
                                setState(() {
                                  ratings[entry.key] = index + 1;
                                });
                              },
                            )),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
              ),
              child: TertiaryButton(
                text: "Leave a Review".tr,
                press: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('userToken');

                  if (token == null) {
                    // Show the custom bottom sheet
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => CustomBottomSheet(
                        title: 'Log in to leave a review'.tr,
                        content: '',
                        onCancel: () {
                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                        onLogin: () {
                          // Close the bottom sheet
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()),
                          ); // Navigate to SignInScreen
                        },
                      ),
                    );
                    return; // Exit the function if token is null
                  }
                  if (_formKey.currentState!.validate()) {
                    if (ratings.values.every((rating) => rating > 0)) {
                      final homeProvider =
                      Provider.of<HomeProvider>(context, listen: false);
                      final result = await homeProvider.leaveReview(
                        reviewTitle: _titleController.text,
                        reviewContent: _contentController.text,
                        reviewStats: ratings,
                        serviceId: hotelDetail.data?.id.toString() ?? '',
                        serviceType: 'hotel',
                        context: context,
                      );

                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                              Text('Review submitted successfully'.tr)),
                        );
                        // Clear the form
                        _titleController.clear();
                        _contentController.clear();
                        setState(() {
                          ratings.updateAll((key, value) => 0);
                        });
                      } else {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Failed to submit review.')),
                        // );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please rate all categories'.tr)),
                      );
                    }
                  }
                },
              ),
            ),
          ]),
        ),
      );
    },
  );
}

// Add this new widget

Widget _buildExtraServicesWidget(
    HotelDetail hotelDetail, Map<int, int> selectedRooms) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Room".tr,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: grey),
                ),
                Text(
                  (selectedRooms.values.fold(0, (sum, qty) => sum + qty))
                      .toString(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: kPrimaryColor),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hotelDetail.data?.bookingFee
                      ?.firstWhere(
                        (fee) => fee.name == "Service fee",
                    orElse: () =>
                        BookingFee(name: "Service fee", price: "0"),
                  )
                      .name ??
                      "Service fee".tr,
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter'),
                ),
                Text(
                  "\$${double.parse(hotelDetail.data?.bookingFee?.firstWhere(
                        (fee) => fee.name == "Service fee",
                    orElse: () =>
                        BookingFee(name: "Service fee", price: "0"),
                  ).price ?? "0").toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: grey),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class SliderContent extends StatelessWidget {
  SliderContent({
    super.key,
    required this.imageUrl,
  });
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 360,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text('Failed to load image'));
            },
          ),
        ),
        // gradient to make image darker
        Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff000000).withOpacity(0.7),
                Color(0xff343434).withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildFacilityItem(String svgIconPath, String label) {
  // CRITICAL: Fixed width Container to enforce two-column layout in the Wrap parent.
  return Container(
    width: 160.0, // Adjust this width as needed for your specific screen size/padding
    padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical spacing between facility rows
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Retaining your original left padding
        const SizedBox(width: 14),

        // --- Icon/Image ---
        Image.network(
          svgIconPath,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 20);
          },
        ),

        // --- Space between icon and text ---
        const SizedBox(width: 14), // Original horizontal spacing

        // --- Text label ---
        Expanded(
          child: Text(
            label.tr,
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0,
                color: Color(0xff1D2025)
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

      ],
    ),
  );
}

Widget _buildRuleItem(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontFamily: 'Inter'.tr,
              color: kPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20),
        Text(value,
            style: TextStyle(
                fontFamily: 'Inter'.tr,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: grey)),
      ],
    ),
  );
}
const int _kMaxChars = 300;

class ExpandableHtmlContent extends StatefulWidget {
  final String content;
  final String readMoreText;
  final TextStyle textStyle;
  final TextStyle readMoreStyle;
  final Color primaryColor; // Assuming kPrimaryColor is passed in

  const ExpandableHtmlContent({
    required this.content,
    required this.primaryColor,
    this.readMoreText = 'Read more',
    this.textStyle = const TextStyle(color: Colors.black54),
    this.readMoreStyle = const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
    Key? key,
  }) : super(key: key);

  @override
  _ExpandableHtmlContentState createState() => _ExpandableHtmlContentState();
}

class _ExpandableHtmlContentState extends State<ExpandableHtmlContent> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Default to collapsed if content exceeds the limit
    _isExpanded = widget.content.length <= _kMaxChars;
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we need to truncate
    final bool isTruncated = widget.content.length > _kMaxChars;

    // Get the content to display: full text if expanded, or truncated text otherwise
    final String displayedContent =
    _isExpanded || !isTruncated
        ? widget.content
        : widget.content.substring(0, _kMaxChars) + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HTML Content
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: HtmlWidget(
            displayedContent,
            textStyle: widget.textStyle,
          ),
        ),

        // 2. Read More Button (only shown if truncation occurred and it's not yet expanded)
        if (isTruncated)
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Show less' : widget.readMoreText,
                style: widget.readMoreStyle.copyWith(
                  color: widget.primaryColor, // Use kPrimaryColor for the link
                ),
              ),
            ),
          ),
      ],
    );
  }
}