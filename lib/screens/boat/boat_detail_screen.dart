// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/modals/boat_detail_model.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/boat/boat_booking_screen.dart';
import 'package:moonbnd/widgets/guest_tour_sheet.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BoatDetailsScreen extends StatefulWidget {
  final int boatId;

  BoatDetailsScreen({super.key, required this.boatId}); //
  @override
  _CarRentalDetailsScreenState createState() => _CarRentalDetailsScreenState();
}

class _CarRentalDetailsScreenState extends State<BoatDetailsScreen> {
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

    log("${widget.boatId} boatId");

    setState(() {
      loading = true;
    });
    Provider.of<BoatProvider>(context, listen: false)
        .fetchBoatDetails(widget.boatId)
        .then((value) {
      String convertHtmlToText(String html) {
        // Remove HTML tags using a regular expression
        final RegExp exp =
            RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
        return html.replaceAll(exp, '').replaceAll('\n', ' ').trim();
      }

      final Set<Marker> markers = {
        Marker(
          markerId: MarkerId('marker1'),
          position: LatLng(
              double.parse(Provider.of<BoatProvider>(context, listen: false)
                      .boatDetail
                      ?.data
                      .mapLat ??
                  "0"),
              double.parse(Provider.of<BoatProvider>(context, listen: false)
                      .boatDetail
                      ?.data
                      .mapLng ??
                  "0")), // San Francisco
          infoWindow:
              InfoWindow(title: 'San Francisco', snippet: 'A cool city!'),
        ),
      };

      setMarkers = markers;

// Example usage
      String htmlContent = Provider.of<BoatProvider>(context, listen: false)
              .boatDetail
              ?.data
              .content ??
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
    final item = Provider.of<BoatProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading:  //back button
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Color(0xffF1F5F9),
               shape: BoxShape.circle
              ),
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ), 
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
                              item.boatDetail?.data?.title ?? "",
                              style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold),
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
                                  child:  Text(item.boatDetail?.data?.location?.name ?? "",
                                      style: GoogleFonts.spaceGrotesk(color: Colors.grey)),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${item.boatDetail?.data?.reviewScore?.totalReview ?? 0} Reviews',
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
                    SizedBox(height: 10),
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
                                item.boatDetail?.data.gallery.length ?? 0,
                            itemBuilder: (context, index) => SliderContent(
                              imageUrl:
                                  item.boatDetail?.data.gallery[index] ?? '',
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
                            //             '${item.boatDetail?.data.shareUrl}');
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
                            //         final homeProvider =
                            //             Provider.of<HomeProvider>(context,
                            //                 listen: false);
                            //         final boatProvider =
                            //             Provider.of<BoatProvider>(context,
                            //                 listen: false);
                            //
                            //         final success =
                            //             await homeProvider.addToWishlist(
                            //           widget.boatId.toString(),
                            //           'boat',
                            //         );
                            //
                            //         await boatProvider
                            //             .fetchBoatDetails(widget.boatId);
                            //
                            //         if (success == "Added to wishlist") {
                            //           setState(() {
                            //             item.boatDetail?.data.isInWishlist =
                            //                 true;
                            //           });
                            //         } else if (success ==
                            //             "Removed from wishlist") {
                            //           setState(() {
                            //             item.boatDetail?.data.isInWishlist =
                            //                 false;
                            //           });
                            //         }
                            //         await boatProvider
                            //             .boatlistapi(7, searchParams: {});
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
                            //             item.boatDetail?.data.isInWishlist ==
                            //                     true
                            //                 ? Icons.favorite
                            //                 : Icons.favorite_border,
                            //             color: item.boatDetail?.data
                            //                         .isInWishlist ==
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
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              '${currentPage + 1} / ${item.boatDetail?.data.gallery.length}',
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
                              await launch(item.boatDetail?.data.video ?? "");
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
                                    'Boat Video'.tr,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,

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


                          // Text(
                          //   item.boatDetail?.data.title ?? "",
                          //   style: TextStyle(
                          //       fontSize: 24, fontWeight: FontWeight.bold),
                          // ),
                          // Text(
                          //   item.boatDetail?.data.location.name ?? "",
                          // ),

                          // Divider(
                          //   thickness: 1,
                          // ),
                          // SizedBox(height: 9),
                          // Row(
                          //   children: [
                          //     Container(
                          //       margin: EdgeInsets.only(top: 10),
                          //       child: CircleAvatar(
                          //         backgroundImage: NetworkImage(
                          //             item.boatDetail?.data.vendor?.avatarUrl ??
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
                          //                 text: item.boatDetail?.data.vendor
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
                          // SizedBox(
                          //   height: 15,
                          // ),
                          // Divider(
                          //   thickness: 1,
                          // ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description'.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.black,
                                    fontSize: 18,

                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Container(
                                //   height: 200,
                                //   child: Image.network(
                                //     item.boatDetail?.data.image ?? "",
                                //     width: 400,
                                //     height: 200,
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
                                // SizedBox(height: 8),
                                // SizedBox(height: 8),
                                // HtmlWidget(item.boatDetail?.data.content ?? ""),
                                ExpandableHtmlContent(
                                  content: item.boatDetail?.data?.content ?? "".tr,
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
                              ],
                            ),
                          ),
                          if (item.boatDetail?.data.terms == null ||
                              item.boatDetail!.data.terms.isNotEmpty)
                            SizedBox(height: 24),
                          if (item.boatDetail?.data.terms == null ||
                              item.boatDetail!.data.terms.isNotEmpty)
                            Text(
                              'Boat Features'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                            ),
                          if (item.boatDetail?.data.terms == null ||
                              item.boatDetail!.data.terms.isNotEmpty)
                            SizedBox(height: 14),

                          ...(item.boatDetail?.data.terms == null ||
                                      item.boatDetail!.data.terms.isEmpty
                                  ? []
                                  : item.boatDetail?.data.terms[0].child)!
                              .map((element) {
                            return _buildFeatureItem(element.title ?? "");
                          }),
                          if (item.boatDetail?.data.faqs.length != 0)
                            SizedBox(height: 26),
                          if (item.boatDetail?.data.faqs.length != 0)
                            Text('FAQ\'s'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),
                          if (item.boatDetail?.data.faqs.length != 0)
                            SizedBox(height: 20),

                          ...(item.boatDetail?.data.faqs ?? []).map((element) {
                            {
                              return _buildFAQItem(
                                  element.title, element.content);
                            }
                          }),
                          // SizedBox(height: 19),
                          // Text(
                          //   'Location'.tr,
                          //   style: TextStyle(
                          //       fontSize: 18, fontWeight: FontWeight.bold),
                          // ),
                          // SizedBox(height: 10),
                          // Text(item.boatDetail?.data.location.name ?? ""),
                          // SizedBox(height: 10),
                          // Container(
                          //   height: 200,
                          //   child: GoogleMap(
                          //     onMapCreated: _onMapCreated,
                          //     markers: setMarkers!,
                          //     initialCameraPosition: CameraPosition(
                          //       target: LatLng(
                          //           double.parse(
                          //               item.boatDetail?.data.mapLat ?? "0"),
                          //           double.parse(
                          //               item.boatDetail?.data.mapLng ?? "0")),
                          //       zoom: double.parse(
                          //           item.boatDetail?.data.mapZoom.toString() ??
                          //               "12"),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 16),
                          // SizedBox(
                          //   height: 32,
                          // ),
                          //
                          // Divider(
                          //   thickness: 1,
                          //   indent: 20,
                          //   endIndent: 20,
                          // ),
                          //review slider
                          SizedBox(height: 12),
                          _buildRatingSection(item.boatDetail!),
                          SizedBox(height: 12),
                          _buildRatingBars(item.boatDetail!),
                          SizedBox(height: 12),
                          ...(item.boatDetail?.data.reviewLists?.data ?? [])
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
                          _buildReviewWidget(item.boatDetail!),
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
                      "\$${item.boatDetail?.data.salePrice == 0 ? item.boatDetail?.data.price : item.boatDetail?.data.salePrice}",
                      style:
                      GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (item.boatDetail?.data.salePrice != 0)
                    Text(
                        item.boatDetail?.data.salePrice == 0
                            ? "\$${item.boatDetail?.data.salePrice}"
                            : "\$${item.boatDetail?.data.price}",
                        style:
                        GoogleFonts.spaceGrotesk(decoration: TextDecoration.lineThrough)),
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
                      context, item.boatDetail); // Call the modal sheet method
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff05A8C7),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Book Now'.tr,style: GoogleFonts.spaceGrotesk(),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2022),
  //     lastDate: DateTime(2030),
  //   );
  //   if (pickedDate != null) {
  //     setState(() {
  //       if (isCheckIn) {
  //         checkInDate = pickedDate;
  //       } else {
  //         checkOutDate = pickedDate;
  //       }
  //     });
  //   }
  // }

  void _showBottomModalSheet(
      BuildContext context, BoatDetailModel? txBoatDetail) async {
    log("$isBookTab isBookTab");

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();

    if (txBoatDetail?.data.extraPrice != null) {
      for (var price in txBoatDetail!.data.extraPrice) {
        price.valueType =
            false; // Assuming valueType is a property of the price object
      }
    }

    List<PersonTypeForBoat> personTypes = [
      PersonTypeForBoat(
          name: "Hours".tr,
          desc: "Return on same-day".tr,
          min: 0,
          max: 23,
          price: double.parse(txBoatDetail?.data.pricePerHour ?? "0"),
          countValue: 0),
      PersonTypeForBoat(
        name: "Days".tr,
        desc: "Return on another-day".tr,
        min: 0,
        max: 364,
        price: double.parse(txBoatDetail?.data.pricePerDay ?? "0"),
        countValue: 0,
      ),
    ];

    double totalValue = 0;
    String selectedDropdownValue = "00:00";
    double total = 0;
    double extraPriceValue = 0;
    int days = 0;

    DateTime? startDate;

    Map<String, int> guestCounts = {};
    // Initialize counts based on minimum values
    for (var type in personTypes) {
      guestCounts[type.name] = type.min;
    }

    void calculateTotalPrice(String name) {
      double total = 0;

      totalValue = 0;

      log("$totalValue totlavalue 1");

      if (name == "Hours") {
        for (var type in personTypes) {
          total += (guestCounts[type.name] ?? 0) * type.price;
        }
      } else {
        for (var type in personTypes) {
          total += (guestCounts[type.name] ?? 0) * type.price;
        }
      }

      totalValue = total;

      log("$totalValue totlavalue 2");

      setState(() {});
    }

    if (txBoatDetail?.data.bookingFee != null) {
      for (var fee in txBoatDetail!.data.bookingFee) {
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
                    log("${guestCounts[personTypes[0].name]} totlavalue 3");
                    log("${guestCounts[personTypes[1].name]} totlavalue 4");
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
                                          style: GoogleFonts.spaceGrotesk(

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
                                  child: Row(
                                    children: [
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '\$${txBoatDetail?.data.pricePerHour}/hour'
                                                .tr,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 20,

                                              fontWeight: FontWeight.w600,
                                              color: kPrimaryColor,
                                            ),
                                          )),
                                      Spacer(),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '\$${txBoatDetail?.data.pricePerDay}/day',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 20,

                                              fontWeight: FontWeight.w600,
                                              color: kPrimaryColor,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),

                                // Container for Check-in, Check-out, and Guests
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

                                                        color: kPrimaryColor,
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
                                                        style: GoogleFonts.spaceGrotesk(
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
                                                    log('$value xxyyy');
                                                    if (valuess.name ==
                                                        "Hours") {
                                                      guestCounts[personTypes[0]
                                                          .name] = value;
                                                      guestCounts[personTypes[1]
                                                          .name] = 0;
                                                    } else {
                                                      guestCounts[personTypes[0]
                                                          .name] = 0;
                                                      guestCounts[personTypes[1]
                                                          .name] = value;
                                                    }

                                                    calculateTotalPrice(
                                                        valuess.name);
                                                    setState1(() {});
                                                  },
                                                );
                                              })
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text("Start Time".tr,
                                              style: GoogleFonts.spaceGrotesk(

                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700)),
                                        ),

                                        SizedBox(height: 10),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          alignment: Alignment.centerLeft,
                                          width: double.infinity,
                                          child: DropdownButton<String>(
                                            value: selectedDropdownValue,
                                            items: [
                                              "00:00",
                                              "00:30",
                                              "01:00",
                                              "01:30",
                                              "02:00",
                                              "02:30",
                                              "03:00",
                                              "03:30",
                                              "04:00",
                                              "04:30",
                                              "05:00",
                                              "05:30",
                                              "06:00",
                                              "06:30",
                                              "07:00",
                                              "07:30",
                                              "08:00",
                                              "08:30",
                                              "09:00",
                                              "09:30",
                                              "10:00",
                                              "10:30",
                                              "11:00",
                                              "11:30",
                                              "12:00",
                                              "12:30",
                                              "13:00",
                                              "13:30",
                                              "14:00",
                                              "14:30",
                                              "15:00",
                                              "15:30",
                                              "16:00",
                                              "16:30",
                                              "17:00",
                                              "17:30",
                                              "18:00",
                                              "18:30",
                                              "19:00",
                                              "19:30",
                                              "20:00",
                                              "20:30",
                                              "21:00",
                                              "21:30",
                                              "22:00",
                                              "22:30",
                                              "23:00",
                                              "23:30",
                                            ].map((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState1(() {
                                                selectedDropdownValue =
                                                    value ?? "";
                                              });
                                            },
                                          ),
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

                                if (txBoatDetail?.data.extraPrice != null)
                                  ...(txBoatDetail?.data.extraPrice)!
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
                                          Text(element.name ?? "",style: GoogleFonts.spaceGrotesk(),),
                                          Spacer(),
                                          Text("\$${element.price}",style: GoogleFonts.spaceGrotesk(),),
                                        ],
                                      ),
                                    );
                                  }),

                                Divider(),

                                SizedBox(height: 10),

                                ...(txBoatDetail?.data.bookingFee)!
                                    .map((element) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                        bottom: 10, left: 15, right: 15),
                                    child: Row(
                                      children: [
                                        Text(element.name),
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
                                            style: GoogleFonts.spaceGrotesk(
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

                                      if (totalValue == 0) {
                                        EasyLoading.showToast(
                                            "Please select Hours or Days".tr,
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        return;
                                      }

                                      // if (selectedGuests.isEmpty) {
                                      //   EasyLoading.showToast(
                                      //       "Please select a passenger",
                                      //       maskType: EasyLoadingMaskType.black);

                                      //   return;
                                      // }

                                      // Calculate total price for selected services

                                      final boatProvider =
                                          Provider.of<BoatProvider>(context,
                                              listen: false);

                                      final result =
                                          await boatProvider.addToCartForBoat(
                                        serviceId:
                                            txBoatDetail?.data.id.toString() ??
                                                '',
                                        serviceType: 'tour',
                                        startDate: startDate!,
                                        day: (guestCounts[personTypes[1].name])
                                            .toString(),
                                        hour: (guestCounts[personTypes[0].name])
                                            .toString(),
                                        extraPrices:
                                            txBoatDetail?.data.extraPrice,
                                        startTime: selectedDropdownValue,
                                        number: 1,
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
                                                  BookingScreenForBoat(
                                                    bookingCode:
                                                        result['booking_code'],
                                                    totalPrice: total
                                                        .toInt(), // Cast to int
                                                    extraPrice: extraPriceValue
                                                        .toInt(), // Cast to int
                                                  )),
                                        );

                                        log("Booking Code: ${result['booking_code']}");
                                        // NavNigate to booking screen or show confirmation dialog
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
                                          style: GoogleFonts.spaceGrotesk(height: 1),
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
                                          style: GoogleFonts.spaceGrotesk(height: 1),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your email'
                                                  .tr;
                                            }
                                            if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid email address';
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
                                          style: GoogleFonts.spaceGrotesk(height: 1),
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
                                                      "${txBoatDetail?.data.id}",
                                                  serviceType: "boat",
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
    required PersonTypeForBoat type,
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
                  type.desc,
                  style: GoogleFonts.spaceGrotesk(

                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "\$${type.price.toStringAsFixed(2)}",
                  style: GoogleFonts.spaceGrotesk(
                    color: kSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
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
        Text(
          "/ ${type.name}",
          style: TextStyle(fontSize: 12, color: grey),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget _buildHighlightItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green),
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
          Text(text,style: GoogleFonts.spaceGrotesk(color: Colors.black38),),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question,style: GoogleFonts.spaceGrotesk(),),
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(answer,style: GoogleFonts.spaceGrotesk(color: Colors.black38),),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BoatDetailModel boatDetail) {
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
                    color: const Color(0xFF05A8C7),
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
                            '${boatDetail.data?.reviewScore?.scoreTotal ?? '0'}/5',
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
                            (boatDetail.data?.reviewScore?.scoreText ?? 'Very Good').tr,
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
                            'Based on ${boatDetail.data?.reviewScore?.totalReview ?? 0} reviews'
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

  // Widget _buildRatingSection(BoatDetailModel boatDetail) {
  //   log("${boatDetail.data.reviewScore!.scoreTotal} scorechecing");
  //   return Container(
  //     width: double.infinity,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Text(
  //               '${boatDetail.data.reviewScore!.scoreTotal}/5',
  //               style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               // ignore: unnecessary_string_interpolations
  //               '${boatDetail.data.reviewScore!.scoreText ?? 'Very Good'}',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  //             ),
  //             Text(
  //               'Based on ${boatDetail.data.reviewScore!.totalReview ?? 0} reviews'
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

  Widget _buildRatingBars(BoatDetailModel boatDetail) {
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

  // Widget _buildRatingBars(BoatDetailModel boatDetail) {
  //   final rateScores = boatDetail.data.reviewScore!.rateScore ?? [];
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: Column(
  //       children: [
  //         for (var score in rateScores)
  //           _buildRatingBar(
  //             "${score.title}",
  //             (score.percent)!.toDouble() / 100,
  //             score.total ?? 0,
  //           ),
  //       ],
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

  // Widget _buildRatingBar(String title, double ratio, int totalScore) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         // SvgPicture.asset("assets/icons/staricon.svg"),
  //         // SizedBox(width: 4),
  //         Expanded(
  //           flex: 2,
  //           child: Text(title,
  //               style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 14)),
  //         ),
  //         Expanded(
  //           flex: 5,
  //           child: Stack(
  //             children: [
  //               Container(
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey[300],
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //               FractionallySizedBox(
  //                 widthFactor: ratio,
  //                 child: Container(
  //                   height: 4,
  //                   decoration: BoxDecoration(
  //                     color: kSecondaryColor,
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(width: 8),
  //         Text('$totalScore',
  //             style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 14)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildReviewItem(Review review) {
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
                                ? Colors.yellow // Changed from kPrimaryColor to yellow for stars
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

  // Widget _buildReviewItem(Review review) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             CircleAvatar(
  //               backgroundImage: NetworkImage(review.author.avatarUrl),
  //               radius: 20,
  //             ),
  //             SizedBox(width: 12),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(review.author.name ?? "",
  //                     style: TextStyle(
  //                         fontFamily: 'Inter'.tr,
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold)),
  //                 // Text(review.author?.lastName ?? '',
  //                 //     style: TextStyle(
  //                 //         fontFamily: 'Inter'.tr, color: Colors.grey)),
  //               ],
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 8),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: List.generate(
  //                 5,
  //                 (index) => Icon(
  //                   Icons.star,
  //                   color: index < (review.rateNumber)
  //                       ? kPrimaryColor
  //                       : Colors.grey,
  //                   size: 18,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 8),
  //             Text(
  //                 DateFormat('dd MMM yyyy')
  //                     .format(DateTime.parse(review.createdAt)),
  //                 style: TextStyle(fontFamily: 'Inter'.tr, color: Colors.grey)),
  //           ],
  //         ),
  //         SizedBox(height: 8),
  //         Text(
  //           review.content,
  //           style: TextStyle(fontFamily: 'Inter'.tr, color: Colors.grey[600]),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildReviewWidget(BoatDetailModel boatDetail) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    Map<String, int> ratings = {
      'Equipment'.tr: 0,
      'Comfortable'.tr: 0,
      'Climate Control'.tr: 0,
      'Facility'.tr: 0,
      'Aftercare'.tr: 0,
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
                        final boatProvider =
                            Provider.of<BoatProvider>(context, listen: false);

                        setState(() {
                          loading = true;
                        });
                        final result = await boatProvider.leaveReviewForBoat(
                          reviewTitle: titleController.text,
                          reviewContent: contentController.text,
                          reviewStats: ratings,
                          serviceId: boatDetail.data.id.toString(),
                          serviceType: 'boat',
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
                          final updatedHotelDetail = await boatProvider
                              .fetchBoatDetails(boatDetail.data.id);
                          if (updatedHotelDetail != null) {
                            // Update the state of the parent widget
                            (context as Element).markNeedsBuild();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to submit review'.tr)),
                          );
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
}

class PersonTypeForBoat {
  final String name;
  final String desc;
  int min;
  final int max;
  final int countValue;
  final double price;

  PersonTypeForBoat({
    required this.name,
    required this.desc,
    required this.min,
    required this.max,
    required this.price,
    required this.countValue,
  });
}
