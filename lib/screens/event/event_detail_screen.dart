// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/modals/event_detail_model.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/event/event_booking_screen.dart';
import 'package:moonbnd/widgets/guest_tour_sheet.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/room_detail_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsDetailsScreen extends StatefulWidget {
  final int eventId;

  EventsDetailsScreen({super.key, required this.eventId}); //
  @override
  _CarRentalDetailsScreenState createState() => _CarRentalDetailsScreenState();
}

class _CarRentalDetailsScreenState extends State<EventsDetailsScreen> {
  bool loading = false;
  // late VideoPlayerController _controller;
  late GoogleMapController mapController;
  Set<Marker>? setMarkers;
  bool isBookTab = true;
  final formKey = GlobalKey<FormState>();

  DateTime? checkInDate;
  DateTime? checkOutDate;
  String dropdownText = "1 Passenger";

  String description = "";
  // bool _isPlaying = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    log("${widget.eventId} boatId");

    setState(() {
      loading = true;
    });
    Provider.of<EventProvider>(context, listen: false)
        .fetchEventDetails(widget.eventId)
        .then((value) {
      String convertHtmlToText(String html) {
        // Remove HTML tags using a regular expression
        final RegExp exp =
            RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
        return html.replaceAll(exp, '').replaceAll('\n', ' ').trim();
      }

      final Set<Marker> _markers = {
        Marker(
          markerId: MarkerId('marker1'),
          position: LatLng(
              double.parse(Provider.of<EventProvider>(context, listen: false)
                      .eventDetail
                      ?.data
                      ?.mapLat ??
                  ""),
              double.parse(Provider.of<EventProvider>(context, listen: false)
                      .eventDetail
                      ?.data
                      ?.mapLng ??
                  "")), // San Francisco
          infoWindow:
              InfoWindow(title: 'San Francisco', snippet: 'A cool city!'),
        ),
      };

      setMarkers = _markers;

// Example usage
      String htmlContent = Provider.of<EventProvider>(context, listen: false)
              .eventDetail
              ?.data
              ?.content ??
          "";
      String readableText = convertHtmlToText(htmlContent);
      description = readableText;
      setState(() {});
    }).then((va) {
      setState(() {
        loading = false;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {});
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<EventProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading:    //back button
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
                color: Color(0xffF1F5F9),
                shape: BoxShape.circle,
                // Makes it perfectly circular
              ),
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
            ),
          ),
        )
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SafeArea(
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Make sure text aligns left
                          children: [
                            Text(
                              item.eventDetail?.data?.title ?? "",
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff1D2025)
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/location.svg',
                                  width: 16,
                                  height: 16,
                                  color: Color(0xff65758B),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.eventDetail?.data?.location?.name ?? "",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff65758B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${item.eventDetail?.data?.reviewScore?.totalReview ?? 0} Reviews',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: const Color(0xFF65758B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Stack(
                      children: [
                        //haven
                        SizedBox(
                          height: 330,
                          child: PageView.builder(
                            onPageChanged: (value) {
                              setState(() {
                                currentPage = value;
                              });
                            },
                            itemCount:
                                item.eventDetail?.data?.gallery?.length ?? 0,
                            itemBuilder: (context, index) => SliderContent(
                              imageUrl:
                                  item.eventDetail?.data?.gallery?[index] ?? '',
                            ),
                            physics: const ClampingScrollPhysics(),
                          ),
                        ),
                        //appbar
                        SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            // child: Row(
                            //   children: [
                            //
                            //
                            //     Spacer(),
                            //
                            //     //share button
                            //     InkWell(
                            //       onTap: () async {
                            //         await Share.share(
                            //             '${item.eventDetail?.data?.shareUrl}');
                            //       },
                            //       child: Padding(
                            //         padding: EdgeInsets.only(right: 12),
                            //         child: Container(
                            //           height: 32,
                            //           width: 32,
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             borderRadius: BorderRadius.circular(50),
                            //           ),
                            //           child: Icon(
                            //             Icons.share,
                            //             color: kPrimaryColor,
                            //             size: 18,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //
                            //     //favorite button
                            //     InkWell(
                            //       onTap: () async {
                            //         log("message");
                            //         final homeProvider =
                            //             Provider.of<HomeProvider>(context,
                            //                 listen: false);
                            //         final eventProvider =
                            //             Provider.of<EventProvider>(context,
                            //                 listen: false);
                            //         final success =
                            //             await homeProvider.addToWishlist(
                            //           '${widget.eventId}',
                            //           'event',
                            //         );
                            //         // ignore: use_build_context_synchronously
                            //         Provider.of<EventProvider>(context,
                            //                 listen: false)
                            //             .fetchEventDetails(widget.eventId);
                            //
                            //         await eventProvider
                            //             .eventlistapi(5, searchParams: {});
                            //
                            //         if (success == "Added to wishlist") {
                            //           setState(() {
                            //             item.eventDetail?.data?.isInWishlist =
                            //                 true;
                            //           });
                            //         } else if (success ==
                            //             "Removed from wishlist") {
                            //           setState(() {
                            //             item.eventDetail?.data?.isInWishlist =
                            //                 false;
                            //           });
                            //         }
                            //
                            //         // Notify listeners to rebuild the widget
                            //
                            //         // ignore: use_build_context_synchronously
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           SnackBar(content: Text(success)),
                            //         );
                            //       },
                            //       child: Padding(
                            //         padding: EdgeInsets.only(right: 12),
                            //         child: Container(
                            //           height: 32,
                            //           width: 32,
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             borderRadius: BorderRadius.circular(50),
                            //           ),
                            //           child: Icon(
                            //             item.eventDetail?.data?.isInWishlist ==
                            //                     true
                            //                 ? Icons.favorite
                            //                 : Icons.favorite_border,
                            //             color: item.eventDetail?.data
                            //                         ?.isInWishlist ==
                            //                     true
                            //                 ? Colors.red
                            //                 : kPrimaryColor,
                            //             size: 18,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ),
                        ),
                        //slider navigation
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            child: Text(
                              '${currentPage + 1} / ${item.eventDetail?.data?.gallery?.length}',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () async {
                              await launch(item.eventDetail?.data?.video ?? "");
                              // await _launchYouTubeVideo(boatDetail?.data?.video);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                      'assets/icons/Hotel_video.svg'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Event Video'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'Inter'.tr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Row(
                          //   children: [
                          //     Container(
                          //       margin: EdgeInsets.only(top: 10),
                          //       child: CircleAvatar(
                          //         backgroundImage: NetworkImage(
                          //             item.eventDetail?.data?.vendor?.avatarUrl ??
                          //                 ""),
                          //         radius: 25,
                          //       ),
                          //     ),
                          //     SizedBox(width: 8),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         SizedBox(
                          //           height: 8,
                          //         ),
                          //         Text('Rented by'.tr,
                          //             style: TextStyle(
                          //                 color: grey,
                          //                 fontFamily: 'Inter'.tr,
                          //                 fontSize: 12,
                          //                 fontWeight: FontWeight.w500)),
                          //         SizedBox(
                          //           height: 8,
                          //         ),
                          //         RichText(
                          //           text: TextSpan(
                          //             children: [
                          //               TextSpan(
                          //                 text: item.eventDetail?.data?.vendor
                          //                         ?.name ??
                          //                     "",
                          //                 style: TextStyle(
                          //                     fontFamily: 'Inter'.tr,
                          //                     color: kPrimaryColor,
                          //                     fontWeight: FontWeight.w500,
                          //                     fontSize: 16),
                          //               ),
                          //               TextSpan(
                          //                 text: ' · Member since Feb 2023'.tr,
                          //                 style: TextStyle(
                          //                     color: grey,
                          //                     fontFamily: 'Inter'.tr,
                          //                     fontSize: 13,
                          //                     fontWeight: FontWeight.w400),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ],
                          // ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Description'.tr,
                                //   style: TextStyle(
                                //     color: kPrimaryColor,
                                //     fontSize: 18,
                                //     fontFamily: 'Inter'.tr,
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                // SizedBox(height: 8),
                                // Container(
                                //   height: 200,
                                //   child: Image.network(
                                //     item.eventDetail?.data?.image ?? "",
                                //     width: 400,
                                //     height: 200,
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
                                // SizedBox(height: 8),
                                const SizedBox(height: 10),

                                ExpandableHtmlContent(
                                  content: item.eventDetail?.data?.content ?? "".tr,
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
                          if (item.eventDetail?.data?.terms?.length != 0)
                            SizedBox(height: 8),
                          if (item.eventDetail?.data?.terms?.length != 0)
                            SizedBox(height: 16),
                          if (item.eventDetail?.data?.terms?.length != 0)
                            Text(
                              'Event Features'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                            ),
                          if (item.eventDetail?.data?.terms?.length != 0)
                            SizedBox(height: 14),

                          if (item.eventDetail?.data?.terms?.length != 0)
                            ...(item.eventDetail?.data?.terms == null
                                    ? []
                                    : item.eventDetail?.data?.terms?[0].child)!
                                .map((element) {
                              return _buildFeatureItem(element.title ?? "");
                            }).toList(),
                          if (item.eventDetail?.data?.faqs != null)
                            SizedBox(height: 26),
                          if (item.eventDetail?.data?.faqs != null)
                            Text('FAQ\'s'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),
                          SizedBox(height: 20),

                          ...(item.eventDetail?.data?.faqs ?? []).map((element) {
                            {
                              return _buildFAQItem(
                                  element.title ?? "", element.content ?? "");
                            }
                          }).toList(),
                          // SizedBox(height: 19),
                          // Text(
                          //   'Location'.tr,
                          //   style: TextStyle(
                          //       fontSize: 18, fontWeight: FontWeight.bold),
                          // ),
                          // SizedBox(height: 10),
                          // Text(item.eventDetail?.data?.location?.name ?? ""),
                          // SizedBox(height: 10),
                          // Container(
                          //   height: 200,
                          //   child: GoogleMap(
                          //     onMapCreated: _onMapCreated,
                          //     markers: setMarkers!,
                          //     initialCameraPosition: CameraPosition(
                          //       target: LatLng(
                          //           double.parse(
                          //               item.eventDetail?.data?.mapLat ?? ""),
                          //           double.parse(
                          //               item.eventDetail?.data?.mapLng ?? "")),
                          //       zoom: double.parse(
                          //           item.eventDetail?.data?.mapZoom.toString() ??
                          //               "12"),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 16),
                          // SizedBox(
                          //   height: 32,
                          // ),

                          Divider(
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          //review slider
                          SizedBox(height: 12),
                          buildRatingSection(item.eventDetail!),
                          SizedBox(height: 12),
                          _buildRatingBars(item.eventDetail!),
                          SizedBox(height: 12),
                          ...(item.eventDetail?.data?.reviewLists?.data ?? [])
                              .map((review) => _buildReviewItem(review)),

                          SizedBox(
                            height: 5,
                          ),
                          // ...(hotelDetail.data?.reviewLists?.data ?? [])
                          //     .map((review) => _buildReviewItem(review)),

                          SizedBox(
                            height: 5,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Write a Review".tr,
                                style: GoogleFonts.spaceGrotesk(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                          ),

                          SizedBox(
                            height: 5,
                          ),
                          _buildReviewWidget(item.eventDetail!),
                          SizedBox(height: 20),

                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "\$${item.eventDetail?.data?.salePrice == 0 ? item.eventDetail?.data?.price : item.eventDetail?.data?.salePrice}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (item.eventDetail?.data?.salePrice != 0)
                    Text(
                        item.eventDetail?.data?.salePrice == 0
                            ? "\$${item.eventDetail?.data?.salePrice}"
                            : "\$${item.eventDetail?.data?.price}",
                        style:
                            TextStyle(decoration: TextDecoration.lineThrough)),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  log("message");
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
                        title: 'Log in to add to'.tr,
                        content: 'your booking'.tr,
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
                  _showBottomModalSheet(
                      context, item.eventDetail); // Call the modal sheet method
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Book Now'.tr,style: GoogleFonts.spaceGrotesk(fontSize: 16,fontWeight: FontWeight.w400),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomModalSheet(
      BuildContext context, EventDetailModal? txBoatDetail) async {
    log("$isBookTab isBookTab");

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();

    if (txBoatDetail?.data?.extraPrice != null) {
      for (var price in txBoatDetail?.data?.extraPrice ?? []) {
        price.valueType =
            false; // Assuming valueType is a property of the price object
      }
    }

    double totalValue = 0;
    String selectedDropdownValue = "00:00";
    double total = 0;
    double extraPriceValue = 0;
    int days = 0;

    DateTime? startDate;

    List<PersonTypeForEvent> personTypes = [
      ...(txBoatDetail?.data?.ticketTypes ?? []).map((element) {
        return PersonTypeForEvent(
            name: element.name ?? "",
            codes: element.code ?? "",
            desc: "${element.price.toString()} per ticket",
            min: 0,
            max: 10,
            price: double.parse(element.price.toString()),
            countValue: 0);
      }).toList()
    ];

    Map<String, int> guestCounts = {};
    // Initialize counts based on minimum values
    for (var type in personTypes) {
      guestCounts[type.name] = type.min;
    }

    double calculateTotalPrice() {
      double total = 0;
      for (var type in personTypes) {
        total += (guestCounts[type.name] ?? 0) * type.price;
      }
      totalValue = total;
      setState(() {});
      return total;
    }

    // Initialize counts based on minimum values

    if (txBoatDetail?.data?.bookingFee != null) {
      for (var fee in txBoatDetail!.data?.bookingFee ?? []) {
        if (fee.price != null) {
          total += double.parse(fee.price ?? "0");
        }
      }

      setState(() {});
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Stack(
            children: [
              FractionallySizedBox(
                heightFactor: 0.8,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState1) {
                    return Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tabs: Book and Enquiry
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState1(() {
                                          isBookTab = true;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Book'.tr,
                                          style: GoogleFonts.spaceGrotesk(

                                            color: isBookTab
                                                ? kSecondaryColor
                                                : grey,
                                            fontSize: 14,
                                            fontWeight: isBookTab
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState1(() {
                                          isBookTab = false;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Enquiry'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Inter'.tr,
                                            color: !isBookTab
                                                ? kSecondaryColor
                                                : grey,
                                            fontSize: 14,
                                            fontWeight: !isBookTab
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      height: isBookTab ? 3 : 1,
                                      thickness: isBookTab ? 3 : 1,
                                      color: isBookTab ? kSecondaryColor : grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      height: isBookTab ? 1 : 3,
                                      thickness: isBookTab ? 1 : 3,
                                      color:
                                          !isBookTab ? kSecondaryColor : grey,
                                    ),
                                  ),
                                ],
                              ),

                              ///////// Book Tab

                              if (isBookTab) ...[
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'From \$${txBoatDetail?.data?.salePrice == 0 ? txBoatDetail?.data?.price : txBoatDetail?.data?.salePrice}'
                                            .tr,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 20,


                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      )),
                                ), // Container for Check-in, Check-out, and Guests
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Check-in date
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2030),
                                                  );
                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      startDate = pickedDate;
                                                    });
                                                    days = 1;
                                                    setState1(() {});
                                                    setState(() {});
                                                  }
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Start Date".tr,
                                                      style: GoogleFonts.spaceGrotesk(

                                                        color: Colors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                      ),
                                                      child: Text(
                                                        startDate != null
                                                            ? DateFormat(
                                                                    'd/MM/yyyy')
                                                                .format(
                                                                    startDate!)
                                                            : 'Select date'.tr,
                                                        style: TextStyle(
                                                          color:
                                                              startDate != null
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                          fontWeight:
                                                              startDate != null
                                                                  ? FontWeight
                                                                      .normal
                                                                  : FontWeight
                                                                      .w300,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Guests Dropdown
                                        Divider(
                                          thickness: 1,
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ...(personTypes).map((valuess) {
                                                return _buildGuestTypeSelector(
                                                  type: valuess,
                                                  value: guestCounts[
                                                          valuess.name] ??
                                                      0,
                                                  onChanged: (value) {
                                                    log('${valuess.name} value');

                                                    valuess.countValue = value;

                                                    // PersonTypeForEvent
                                                    //     txpersonTypes =
                                                    //     personTypes
                                                    //         .firstWhere((test) {
                                                    //   return test.name == test.name;
                                                    // });

                                                    // if (valuess.name ==
                                                    //     "Ticket Vip") {
                                                    // personTypes[0].countValue =
                                                    //     value;
                                                    // } else if (valuess.name ==
                                                    //     "Group Tickets") {
                                                    // personTypes[1].countValue =
                                                    //     value;
                                                    // }

                                                    setState1(() {
                                                      guestCounts[
                                                          valuess.name] = value;
                                                      calculateTotalPrice();
                                                    });
                                                  },
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        ),

                                        Divider(
                                          thickness: 1,
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),

                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  alignment: Alignment.centerLeft,
                                  child: Text("Extra Prices:".tr,
                                      style: GoogleFonts.spaceGrotesk(

                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                ),

                                if (txBoatDetail?.data?.extraPrice != null)
                                  ...(txBoatDetail?.data?.extraPrice)!
                                      .map((element) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: element.valueType,
                                              onChanged: (value) {
                                                log("$value on value change");

                                                element.valueType = value;

                                                log("${element.valueType} on click change");

                                                if (element.valueType == true) {
                                                  extraPriceValue +=
                                                      double.parse(
                                                          element.price ?? "0");
                                                } else {
                                                  extraPriceValue -=
                                                      double.parse(
                                                          element.price ?? "0");
                                                }

                                                setState1(() {});
                                              }),
                                          Text(element.name ?? ""),
                                          Spacer(),
                                          Text("\$${element.price}"),
                                        ],
                                      ),
                                    );
                                  }).toList(),

                                Divider(),

                                SizedBox(height: 10),

                                ...(txBoatDetail?.data?.bookingFee)!
                                    .map((element) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                        bottom: 10, left: 15, right: 15),
                                    child: Row(
                                      children: [
                                        Text(element.name ?? ""),
                                        Spacer(),
                                        Text("\$${element.price}"),
                                      ],
                                    ),
                                  );
                                }),

                                SizedBox(height: 10),

                                Divider(),
                                SizedBox(height: 10),

                                if (totalValue != 0)
                                  Container(
                                    padding: EdgeInsets.only(
                                        bottom: 10, left: 15, right: 15),
                                    child: Row(
                                      children: [
                                        Text("Total".tr,
                                            style: GoogleFonts.spaceGrotesk(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        Spacer(),
                                        Text(
                                            "\$${totalValue + total + extraPriceValue}",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: 10),

                                // Check Availability Button
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: TertiaryButton(
                                    text: "Book Now".tr,
                                    press: () async {
                                      log("Book Now");
                                      if (startDate == null) {
                                        EasyLoading.showToast(
                                            "Please select start date".tr,
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        return;
                                      }

                                      final eventProvider =
                                          Provider.of<EventProvider>(context,
                                              listen: false);

                                      final result =
                                          await eventProvider.addToCartForEvent(
                                        serviceId:
                                            txBoatDetail?.data?.id.toString() ??
                                                '',
                                        serviceType: 'event',
                                        startDate: startDate!,
                                        personType: personTypes,
                                        extraPrices:
                                            txBoatDetail?.data?.extraPrice ??
                                                [],
                                      );

                                      if (result != null &&
                                          result['status'] == 1) {
                                        EasyLoading.showToast(
                                            "Successfully added to booking".tr,
                                            maskType:
                                                EasyLoadingMaskType.black);

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BookingScreenForEvent(
                                                    bookingCode:
                                                        result['booking_code'],
                                                    txpersonTypes: personTypes,
                                                    totalPrice: total
                                                        .toInt(), // Cast to int
                                                    extraPrice: extraPriceValue
                                                        .toInt(), // Cast to int
                                                  )),
                                        );

                                        log("Booking Code: ${result['booking_code']}");
                                        // NavNigate to cart screen or show confirmation dialog
                                      } else {
                                        String errorMessage =
                                            'Failed to add to booking'.tr;
                                        if (result != null &&
                                            result['errors'] != null) {}
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(errorMessage)),
                                        );
                                      }
                                    },
                                  ),
                                ),

                                SizedBox(height: 20),
                              ],

                              ///////// Enquiry Tab

                              if (isBookTab == false) ...[
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    left: 16,
                                    right: 16,
                                    top: 16,
                                  ),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Enquiry'.tr,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        Divider(thickness: 1),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            labelText: 'Name*'.tr,
                                            border: OutlineInputBorder(),
                                          ),
                                          style: TextStyle(height: 1),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your name'
                                                  .tr;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: 'Email*'.tr,
                                            border: OutlineInputBorder(),
                                          ),
                                          style: TextStyle(height: 1),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your email'
                                                  .tr;
                                            }
                                            if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid email address'
                                                  .tr;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText: 'Phone*'.tr,
                                            border: OutlineInputBorder(),
                                          ),
                                          style: TextStyle(height: 1),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your phone number'
                                                  .tr;
                                            }
                                            if (!RegExp(r'^\+?[\d\s-]{10,}$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid phone number'
                                                  .tr;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: noteController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            labelText: 'Note*'.tr,
                                            border: OutlineInputBorder(),
                                          ),
                                          style: GoogleFonts.spaceGrotesk(height: 1),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a note'.tr;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        Divider(thickness: 1),
                                        SizedBox(
                                          width: 150,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                final homeProvider =
                                                    Provider.of<HomeProvider>(
                                                        context,
                                                        listen: false);
                                                final result =
                                                    await homeProvider
                                                        .sendEnquiry(
                                                  serviceId:
                                                      "${txBoatDetail?.data?.id}",
                                                  serviceType: "event",
                                                  name: nameController.text,
                                                  email: emailController.text,
                                                  phone: phoneController.text,
                                                  note: noteController.text,
                                                );

                                                if (result != null &&
                                                    result['status'] == 1) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(result[
                                                                'message'] ??
                                                            'Enquiry submitted successfully'
                                                                .tr)),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Error: ${result?['message'] ?? ''}')),
                                                  );
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kSecondaryColor,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(0, 55),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              'Send Now'.tr,
                                              style: GoogleFonts.spaceGrotesk(
                                                color: kBackgroundColor,
                                                fontSize: 16,

                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(thickness: 1),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 10,
                top: 6,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget _buildGuestTypeSelector({
    required PersonTypeForEvent type,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.name,
                  style: GoogleFonts.spaceGrotesk(

                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "/ \$${type.desc}",
                  style: GoogleFonts.spaceGrotesk(fontSize: 12, color: grey),
                ),
              ],
            ),
            QuantitySelector(
              value: value,
              onChanged: (newValue) {
                if (newValue >= type.min && newValue <= type.max) {
                  onChanged(newValue);
                }
              },
            ),
          ],
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget _buildHighlightItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.secondary),
        SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/feature_check.svg',
          ),
          SizedBox(
            width: 8,
          ),
          Text(text,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xff65758B), // Change text color
            ),),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        question,
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0,
          color: Color(0xff1D2025),
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(left: 0, right: 16, bottom: 16),
          child: Text(
            answer,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 21 / 14,
              letterSpacing: 0,
              color: Color(0xff65758B),
            ),
          ),
        ),
      ],
    );
  }
  Widget buildRatingSection(EventDetailModal eventDetails) {
    const Color textColor = Colors.white;

    return Column(
        children: [
          Column(
            children: [
              // Guest Review Text above the container (centered)
              Padding(
                padding: const EdgeInsets.only(right: 210),
                child: Text(
                  'Guest Review'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xff1D2025),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 100.0,vertical: 6),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${eventDetails.data?.reviewScore?.scoreTotal ?? '0'}/5',
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
                            (eventDetails.data?.reviewScore?.scoreText ?? 'Very Good').tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w400, // Regular
                              fontSize: 14,
                              height: 20 / 14,
                              letterSpacing: 0,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Based on ${eventDetails.data?.reviewScore?.totalReview ?? 0} reviews'
                                .tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk( fontWeight: FontWeight.w400, // Regular
                              fontSize: 14,
                              height: 20 / 14,
                              letterSpacing: 0,
                              color: textColor,),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )]);
  }
  // Widget _buildRatingSection(EventDetailModal boatDetail) {
  //   log("${boatDetail.data?.reviewScore?.scoreTotal} scorechecing");
  //   return Container(
  //     width: double.infinity,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Text(
  //               '${boatDetail.data?.reviewScore?.scoreTotal}/5',
  //               style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               // ignore: unnecessary_string_interpolations
  //               '${boatDetail.data?.reviewScore?.scoreText ?? 'Very Good'}',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  //             ),
  //             Text(
  //               'Based on ${boatDetail.data?.reviewScore?.totalReview ?? 0} reviews'
  //                   .tr,
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 14, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 16),
  //         // Add rating bars here
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRatingBars(EventDetailModal boatDetail) {
    final rateScores = boatDetail.data?.reviewScore?.rateScore ?? [];

    return Container(
      // 1. Card Styling - matches your room detail screen
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            for (var score in rateScores)
              _buildRatingBar(
                score.title ?? '',
                (score.percent ?? 0).toDouble() / 100,
                score.total ?? 0,
              ),
          ],
        ),
      ),
    );
  }
  // Widget _buildRatingBars(EventDetailModal boatDetail) {
  //   final rateScores = boatDetail.data?.reviewScore?.rateScore ?? [];
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: Container(
  //
  //       child: Column(
  //         children: [
  //           for (var score in rateScores)
  //             _buildRatingBar(
  //               "${score.title}",
  //               (score.percent)!.toDouble() / 100,
  //               score.total ?? 0,
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRatingBar(String title, double ratio, int totalScore) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // SvgPicture.asset("assets/icons/staricon.svg"),
          // SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Text(title,
                style: GoogleFonts.spaceGrotesk( fontSize: 14,color: Color(0xff65758B))),
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text('$totalScore',
              style: GoogleFonts.spaceGrotesk( fontSize: 14,  color: Color(0xff65758B),)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewData review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                              style:  GoogleFonts.spaceGrotesk(

                                  fontWeight: FontWeight.w500, // "Medium" in Figma = w500
                                  fontSize: 14,
                                  height: 20 / 14, // line-height = 20px
                                  letterSpacing: 0,
                                  color: Color(0xff1D2025)
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(
                              DateTime.parse(
                                review.createdAt ?? DateTime.now().toString(),
                              ),
                            ),
                            style:  GoogleFonts.spaceGrotesk(

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
                                ? AppColors.accent // Changed from kPrimaryColor to yellow for stars
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
              style: GoogleFonts.spaceGrotesk(

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

  Widget _buildReviewWidget(EventDetailModal eventDetail) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    Map<String, int> ratings = {
      'Service'.tr: 0,
      'Organization'.tr: 0,
      'Friendliness'.tr: 0,
      'Area Expert'.tr: 0,
      'Safety'.tr: 0,
    };

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState1) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title'.tr,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  filled: true, // Add this
                  fillColor: Color(0xFFF5F5F5),
                  labelStyle: GoogleFonts.spaceGrotesk(color: grey),
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
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Review Content'.tr,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  filled: true, // Add this
                  fillColor: Color(0xFFF5F5F5),
                  labelStyle: GoogleFonts.spaceGrotesk(color: grey),
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
                                    style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w400,
                                        color: grey,
                                        fontSize: 14)),
                                SizedBox(height: 5),
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
                                              setState1(() {
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
                        // ignore: use_build_context_synchronously
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
                            Navigator.of(context)
                                .pop(); // Close the bottom sheet
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
                    if (formKey.currentState!.validate()) {
                      if (ratings.values.every((rating) => rating > 0)) {
                        final eventProvider =
                            Provider.of<EventProvider>(context, listen: false);

                        setState(() {
                          loading = true;
                        });
                        final result = await eventProvider.leaveReviewForEvent(
                          reviewTitle: titleController.text,
                          reviewContent: contentController.text,
                          reviewStats: ratings,
                          serviceId: eventDetail.data!.id.toString(),
                          serviceType: 'event',
                        );

                        setState(() {
                          loading = false;
                        });

                        if (result != null) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Review submitted successfully'.tr)),
                          );
                          // Clear the form
                          titleController.clear();
                          contentController.clear();
                          setState1(() {
                            ratings.updateAll((key, value) => 0);
                          });

                          // Refresh hotel details
                          final updatedHotelDetail = await eventProvider
                              .fetchEventDetails(eventDetail.data?.id ?? 1);
                          if (updatedHotelDetail != null) {
                            // Update the state of the parent widget
                            (context as Element).markNeedsBuild();
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to submit review'.tr)),
                          );
                        }
                      } else {
                        // ignore: use_build_context_synchronously
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
}
// const int _kMaxChars = 300;
//
// class ExpandableHtmlContent extends StatefulWidget {
//   final String content;
//   final String readMoreText;
//   final TextStyle textStyle;
//   final TextStyle readMoreStyle;
//   final Color primaryColor; // Assuming kPrimaryColor is passed in
//
//   const ExpandableHtmlContent({
//     required this.content,
//     required this.primaryColor,
//     this.readMoreText = 'Read more',
//     this.textStyle = const TextStyle(color: Colors.black54),
//     this.readMoreStyle = const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _ExpandableHtmlContentState createState() => _ExpandableHtmlContentState();
// }
//
// class _ExpandableHtmlContentState extends State<ExpandableHtmlContent> {
//   late bool _isExpanded;
//
//   @override
//   void initState() {
//     super.initState();
//     // Default to collapsed if content exceeds the limit
//     _isExpanded = widget.content.length <= _kMaxChars;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine if we need to truncate
//     final bool isTruncated = widget.content.length > _kMaxChars;
//
//     // Get the content to display: full text if expanded, or truncated text otherwise
//     final String displayedContent =
//     _isExpanded || !isTruncated
//         ? widget.content
//         : widget.content.substring(0, _kMaxChars) + '...';
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 1. HTML Content
//         Padding(
//           padding: const EdgeInsets.only(left: 15),
//           child: HtmlWidget(
//             displayedContent,
//             textStyle: widget.textStyle,
//           ),
//         ),
//
//         // 2. Read More Button (only shown if truncation occurred and it's not yet expanded)
//         if (isTruncated)
//           Padding(
//             padding: const EdgeInsets.only(left: 15, top: 8),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   _isExpanded = !_isExpanded;
//                 });
//               },
//               child: Text(
//                 _isExpanded ? 'Show less' : widget.readMoreText,
//                 style: widget.readMoreStyle.copyWith(
//                   color: widget.primaryColor, // Use kPrimaryColor for the link
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
class PersonTypeForEvent {
  final String name;
  final String desc;
  int min;
  final int max;
  final String codes;

  int countValue;
  final double price;

  PersonTypeForEvent({
    required this.name,
    required this.codes,
    required this.desc,
    required this.min,
    required this.max,
    required this.price,
    required this.countValue,
  });
}
