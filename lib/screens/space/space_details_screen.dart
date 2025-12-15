// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/space_detail_model.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/space/space_booking_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../hotel/room_detail_screen.dart';

class SpacePage extends StatefulWidget {
  final int spaceId;
  const SpacePage({super.key, required this.spaceId});

  @override
  // ignore: library_private_types_in_public_api
  _SpacePageState createState() => _SpacePageState();
}

class _SpacePageState extends State<SpacePage> {
  // ignore: unused_field
  bool loading = false;
  // late VideoPlayerController _controller;
  late GoogleMapController mapController;
  Set<Marker>? setMarkers;
  bool isBookTab = true;
  final formKey = GlobalKey<FormState>();
  String selectedGuests = "0 adults, 0 children";
  DateTime? checkInDate;
  DateTime? checkOutDate;

  String description = "";
  int currentPage = 0;
  double guestTotalPrice = 0.0;
  int adults = 0;
  int children = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });
    Provider.of<SpaceProvider>(context, listen: false)
        .fetchSpaceDetails(widget.spaceId)
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
              // ignore: use_build_context_synchronously
              double.parse(Provider.of<SpaceProvider>(context, listen: false)
                      .spaceDetail
                      ?.data
                      ?.mapLat ??
                  "0"),
              // ignore: use_build_context_synchronously
              double.parse(Provider.of<SpaceProvider>(context, listen: false)
                      .spaceDetail
                      ?.data
                      ?.mapLng ??
                  "0")), // San Francisco
          infoWindow:
              InfoWindow(title: 'San Francisco', snippet: 'A cool city!'),
        ),
      };

      setMarkers = markers;

      // Example usage
      // ignore: use_build_context_synchronously
      String htmlContent = Provider.of<SpaceProvider>(context, listen: false)
              .spaceDetail
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
    final item = Provider.of<SpaceProvider>(context, listen: true);
    log("${item.spaceDetail?.data?.gallery?.length} message tour");
    return Scaffold(
      appBar: AppBar(
        leading:    //back button
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
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
                    buildTourDetails(),
                    SizedBox(height: 16),

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
                            itemCount: item.spaceDetail?.data?.gallery?.length ?? 0,
                            itemBuilder: (context, index) => Image.network(
                              item.spaceDetail?.data?.gallery?[index] ?? item.spaceDetail?.data?.bannerImage ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/haven/tour_descripation.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),

                        // Image counter at bottom right
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${currentPage + 1}/${item.spaceDetail?.data?.gallery?.length ?? 0}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                            //     Padding(
                            //       padding: EdgeInsets.only(right: 12),
                            //       child: InkWell(
                            //         onTap: () {
                            //           Share.share(
                            //               'Check out this space: ${item.spaceDetail?.data?.shareUrl}');
                            //         },
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
                            //     SizedBox(width: 12),
                            //
                            //     //favorite button
                            //
                            //     InkWell(
                            //       onTap: () async {
                            //         log("message");
                            //         final homeProvider =
                            //             Provider.of<HomeProvider>(context,
                            //                 listen: false);
                            //         final spaceProvider =
                            //             Provider.of<SpaceProvider>(context,
                            //                 listen: false);
                            //         final success =
                            //             await homeProvider.addToWishlist(
                            //           '${widget.spaceId}',
                            //           'space',
                            //         );
                            //         // ignore: use_build_context_synchronously
                            //         Provider.of<SpaceProvider>(context,
                            //                 listen: false)
                            //             .fetchSpaceDetails(widget.spaceId);
                            //
                            //         await spaceProvider
                            //             .spacelistapi(3, searchParams: {});
                            //
                            //         if (success == "Added to wishlist") {
                            //           setState(() {
                            //             item.spaceDetail?.data?.isInWishlist =
                            //                 true;
                            //           });
                            //         } else if (success ==
                            //             "Removed from wishlist") {
                            //           setState(() {
                            //             item.spaceDetail?.data?.isInWishlist =
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
                            //             item.spaceDetail?.data?.isInWishlist ==
                            //                     true
                            //                 ? Icons.favorite
                            //                 : Icons.favorite_border,
                            //             color: item.spaceDetail?.data
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
            
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () async {
                              await launch(item.spaceDetail?.data?.video ?? "");
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
                                    'Space Video'.tr,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(

                                children: [
                                  Row(
                                    children: [
                                      buildIconText('assets/haven/bed.png', "No. of Bed".tr,
                                          item.spaceDetail?.data?.bed?.toString() ?? ""),
                                      SizedBox(width: 50,),
                                      buildIconText('assets/haven/bathroom.png', "No. of Bathroom".tr,
                                          item.spaceDetail?.data?.bathroom?.toString() ?? ""),
                                    ],
                                  ),
                                  SizedBox(width: 60,),
                                  Row(
                                    children: [
                                      buildIconText('assets/haven/square.png', "Square".tr,
                                          item.spaceDetail?.data?.square?.toString() ?? ""),
                                      SizedBox(width: 80,),
                                      buildIconText('assets/haven/location.png', "Location".tr,
                                          item.spaceDetail?.data?.location?.name ?? ""),
                                    ],
                                  )


                                ],
                              ),
                              SizedBox(height: 8),

                              Text(
                                'Overview'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.black,
                                  fontSize: 18,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              // SizedBox(
                              //   height: 260,
                              //   width: double.infinity,
                              //   child: PageView.builder(
                              //     onPageChanged: (value) {
                              //       setState(() {
                              //         currentPage = value;
                              //       });
                              //     },
                              //     itemCount:
                              //         item.spaceDetail?.data?.gallery?.length ??
                              //             0,
                              //     itemBuilder: (context, index) => SliderContent(
                              //       imageUrl:
                              //           item.spaceDetail?.data?.gallery?[index] ??
                              //               '',
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: 8),
                              // ExpandableText(
                              //   text: description,
                              //   trimLines: 2,
                              // ),
                              ExpandableHtmlContent(
                                content: item.spaceDetail?.data?.content ?? "".tr,
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
                              SizedBox(height: 8),
                              Divider(
                                thickness: 1,
                              ),
                            ],
                          ),
                          // buildHighlightsSection(),
                          // buildIncludedExcluded(),
                          // buildItinerarySection(),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.spaceDetail?.data?.terms?.length != 0)
                                Text(
                                  'Space Types'.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                                ),
                              if (item.spaceDetail?.data?.terms?.length != 0)
                                SizedBox(height: 14),
                              if (item.spaceDetail?.data?.terms?.length != 0)
                                ...(item.spaceDetail?.data?.terms?[0].child ?? [])
                                    .map((style) => Column(
                                          children: [
                                            _buildFeatureItem(style.title ?? ""),
                                            SizedBox(height: 14),
                                          ],
                                        ))
                                    .toList(),
                              if (item.spaceDetail?.data?.terms?.length != 0)
                                SizedBox(height: 20),
                              if (item.spaceDetail?.data?.terms?.length != 0)
                                Text(
                                  'Amenities'.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                                ),
                              SizedBox(height: 14),
                              if (item.spaceDetail?.data?.terms?.length != 0)
                                ...(item.spaceDetail?.data?.terms?[1].child ?? [])
                                    .map((facility) => Column(
                                          children: [
                                            _buildFeatureItem(
                                                facility.title ?? ""),
                                            SizedBox(height: 14),
                                          ],
                                        ))
                                    .toList(),
                            ],
                          ),
                          if (item.spaceDetail?.data?.faqs != null)
                            SizedBox(height: 16),
                          if (item.spaceDetail?.data?.faqs != null)
                            Text('FAQ\'s'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),
                          // SizedBox(height: 20),
                          if (item.spaceDetail?.data?.faqs != null)
                            ...(item.spaceDetail?.data?.faqs ?? [])
                                .map((element) {
                              {
                                return _buildFAQItem(
                                    element.title ?? "", element.content ?? "");
                              }
                            }),
                          // SizedBox(height: 19),
                          // Text(
                          //   'Location'.tr,
                          //   style: TextStyle(
                          //       fontSize: 18, fontWeight: FontWeight.bold),
                          // ),
                          // SizedBox(height: 14),
                          // Text(item.spaceDetail?.data?.location?.name ?? ""),
                          // SizedBox(height: 8),
                          // SizedBox(
                          //   height: 200,
                          //   child: GoogleMap(
                          //     onMapCreated: _onMapCreated,
                          //     markers: setMarkers!,
                          //     initialCameraPosition: CameraPosition(
                          //       target: LatLng(
                          //           double.parse(
                          //               item.spaceDetail?.data?.mapLat ?? "0"),
                          //           double.parse(
                          //               item.spaceDetail?.data?.mapLng ?? "0")),
                          //       zoom: double.parse(
                          //           item.spaceDetail?.data?.mapZoom.toString() ??
                          //               "12"),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 16),
                          // SizedBox(
                          //   height: 32,
                          // ),
            
                          // Divider(
                          //   thickness: 1,
                          //   indent: 20,
                          //   endIndent: 20,
                          // ),
                          _buildRatingSection(item.spaceDetail!),
                          SizedBox(height: 16),
                          _buildRatingBars(item.spaceDetail!),
                          SizedBox(height: 5),
                          Divider(thickness: 1),
                          ...(item.spaceDetail?.data?.reviewLists?.data ?? [])
                              .map((review) => _buildReviewItem(review)),
                          SizedBox(height: 5),
                          Divider(thickness: 1),
                          Text(
                            'Write a Review'.tr,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          _buildReviewWidget(),
                          SizedBox(height: 80), // Space for the bottom bar
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
                  if (item.spaceDetail?.data?.discountPercent != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${item.spaceDetail?.data?.salePrice == 0 ? item.spaceDetail?.data?.price : item.spaceDetail?.data?.salePrice}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (item.spaceDetail?.data?.salePrice != 0)
                          Text(
                            "\$${item.spaceDetail?.data?.price}",
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    )
                  else
                    Text(
                      "\$${item.spaceDetail?.data?.price}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              ElevatedButton(
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
                      context, item.spaceDetail); // Call the modal sheet method
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Book Now'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question,style: GoogleFonts.spaceGrotesk(),),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(answer,style: GoogleFonts.spaceGrotesk(color: Colors.black38)),
        ),
      ],
    );
  }
  Widget _buildRatingSection(SpaceDetailModal spaceDetail) {
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
                            '${spaceDetail.data?.reviewScore?.scoreTotal ?? '0'}/5',
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
                            (spaceDetail.data?.reviewScore?.scoreText ?? 'Very Good').tr,
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
                            'Based on ${spaceDetail.data?.reviewScore?.totalReview ?? 0} reviews'
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


  // Widget _buildRatingSection(SpaceDetailModal spaceDetail) {
  //   log("${spaceDetail.data?.reviewScore?.scoreTotal} scorechecing");
  //   return Container(
  //     width: double.infinity,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Text(
  //               '${spaceDetail.data?.reviewScore?.scoreTotal ?? '0'}/5',
  //               style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               // ignore: unnecessary_string_interpolations
  //               '${spaceDetail.data?.reviewScore?.scoreText ?? 'Very Good'}',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  //             ),
  //             Text(
  //               'Based on ${spaceDetail.data?.reviewScore?.totalReview ?? 0} reviews'
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

  Widget _buildRatingBars(SpaceDetailModal spaceDetail) {
    final rateScores = spaceDetail.data?.reviewScore?.rateScore ?? [];

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


  // Widget _buildRatingBars(SpaceDetailModal spaceDetail) {
  //   final rateScores = spaceDetail.data?.reviewScore?.rateScore ?? [];
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

  // Widget _buildReviewItem(ReviewData review) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             CircleAvatar(
  //               backgroundImage: NetworkImage(review.author?.avatarUrl ?? ''),
  //               radius: 20,
  //             ),
  //             SizedBox(width: 12),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(review.author?.name ?? '',
  //                     style: TextStyle(
  //                         fontFamily: 'Inter'.tr,
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold)),
  //                 Text(review.author?.name ?? '',
  //                     style: TextStyle(
  //                         fontFamily: 'Inter'.tr, color: Colors.grey)),
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
  //                   color: index < (review.rateNumber ?? 0)
  //                       ? kPrimaryColor
  //                       : Colors.grey,
  //                   size: 18,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 8),
  //             Text(
  //                 DateFormat('dd MMM yyyy').format(DateTime.parse(
  //                     review.createdAt ?? DateTime.now().toString())),
  //                 style: TextStyle(fontFamily: 'Inter'.tr, color: Colors.grey)),
  //           ],
  //         ),
  //         SizedBox(height: 8),
  //         Text(
  //           review.content ?? '',
  //           style: TextStyle(fontFamily: 'Inter'.tr, color: Colors.grey[600]),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildReviewWidget() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    Map<String, int> ratings = {
      'Sleep'.tr: 0,
      'Location'.tr: 0,
      'Service'.tr: 0,
      'Clearness'.tr: 0,
      'Rooms'.tr: 0,
    };

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState1) {
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
                    borderSide: BorderSide.none,
                  ),
                  filled: true, // Add this
                  fillColor: Color(0xFFF5F5F5),
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
                    borderSide: BorderSide.none,
                  ),
                  filled: true, // Add this
                  fillColor: Color(0xFFF5F5F5),
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
                    if (_formKey.currentState!.validate()) {
                      if (ratings.values.every((rating) => rating > 0)) {
                        final spaceProvider =
                            Provider.of<SpaceProvider>(context, listen: false);

                        setState(() {
                          loading = true;
                        });
                        final result = await spaceProvider.leaveReviewForSpace(
                          reviewTitle: _titleController.text,
                          reviewContent: _contentController.text,
                          reviewStats: ratings,
                          serviceId:
                              spaceProvider.spaceDetail?.data?.id.toString() ??
                                  '',
                          serviceType: 'space',
                        );

                        setState(() {
                          loading = false;
                        });

                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Review submitted successfully'.tr)),
                          );
                          // Clear the form
                          _titleController.clear();
                          _contentController.clear();
                          setState1(() {
                            ratings.updateAll((key, value) => 0);
                          });

                          // Refresh hotel details
                          final updatedSpaceDetail =
                              await spaceProvider.fetchSpaceDetails(
                                  spaceProvider.spaceDetail?.data?.id ?? 0);
                          if (updatedSpaceDetail != null) {
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

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/feature_check.svg',
        ),
        SizedBox(
          width: 8,
        ),
        Text(text,style: GoogleFonts.spaceGrotesk(color: Colors.black38),),
      ],
    );
  }

  Widget buildTourDetails() {
    final item = Provider.of<SpaceProvider>(context, listen: true);
    return Column(
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
                  item.spaceDetail?.data?.title ?? "",
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
                      child:  Text(item.spaceDetail?.data?.location?.name ?? "",
                          style: GoogleFonts.spaceGrotesk(color: Colors.grey)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '${item.spaceDetail?.data?.reviewScore?.totalReview ?? 0} Reviews',
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

        // Text(
        //   item.spaceDetail?.data?.title ?? "",
        //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        // ),
        // Text(item.spaceDetail?.data?.location?.name ?? "",
        //     style: TextStyle(color: Colors.grey)),


        // Row(
        //   children: [
        //     Container(
        //       margin: EdgeInsets.only(top: 10),
        //       child: CircleAvatar(
        //         backgroundImage: NetworkImage(
        //             item.spaceDetail?.data?.vendor?.avatarUrl ?? ""),
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
        //                 text: item.spaceDetail?.data?.vendor?.name ?? "vendor",
        //                 style: TextStyle(
        //                     fontFamily: 'Inter'.tr,
        //                     color: kPrimaryColor,
        //                     fontWeight: FontWeight.w500,
        //                     fontSize: 16),
        //               ),
        //               TextSpan(
        //                 text:
        //                     ' · Member since ${DateFormat('dd/MM/yy').format(DateTime.parse(item.spaceDetail?.data?.vendor?.createdAt ?? DateTime.now().toString()))}'
        //                         .tr,
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
        // SizedBox(
        //   height: 15,
        // ),

      ],
    );
  }

  Widget buildIconText(String imagePath, String text, String subtext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          imagePath,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            SizedBox(height: 8),
            Text(subtext, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget buildHighlightsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Highlights",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("- Visit the Eiffel Tower"),
          Text("- Explore the Louvre Museum"),
          Text("- Take a Seine River cruise"),
          Text("- Visit the Eiffel Tower"),
          Text("- Explore the Louvre Museum"),
          Text("- Take a Seine River cruise"),
          Text("- Visit the Eiffel Tower"),
          Text("- Explore the Louvre Museum"),
          Text("- Take a Seine River cruise"),
        ],
      ),
    );
  }

  void _showBottomModalSheet(
      BuildContext context, SpaceDetailModal? txSpaceDetail) async {
    DateTime? checkInDateHere;
    DateTime? checkOutDateHere;

    log("$isBookTab isBookTab");

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();

    int total = 0;
    int extraPriceValue = 0;
    int days = 0;

    if (txSpaceDetail?.data?.bookingFee != null) {
      for (var fee in txSpaceDetail!.data!.bookingFee!) {
        if (fee.price != null) {
          total += int.parse(fee.price ?? "0");
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
                    log("$days days");
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
                                          style: TextStyle(
                                            fontFamily: 'Inter'.tr,
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
                                        // EnquiryBottomSheet.show(
                                        //   context,
                                        //   serviceId:
                                        //       item.hotelDetail?.data?.id.toString() ?? '',
                                        //   serviceType: 'hotel',
                                        //   onEnquirySubmit: (name, email, phone, note) {
                                        //     print(
                                        //         'Enquiry submitted: $name, $email, $phone, $note');
                                        //   },
                                        //   onClose: () {
                                        //     setState(() {
                                        //       isBookTab = true;
                                        //     });
                                        //   },
                                        // );
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

                              if (isBookTab) ...[
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'From \$${txSpaceDetail?.data?.discountPercent == null ? txSpaceDetail?.data?.price : (txSpaceDetail?.data?.salePrice == 0 ? txSpaceDetail?.data?.price : txSpaceDetail?.data?.salePrice)}'
                                            .tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Inter'.tr,
                                          fontWeight: FontWeight.w600,
                                          color: kPrimaryColor,
                                        ),
                                      )),
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
                                                    if (checkOutDateHere !=
                                                            null &&
                                                        pickedDate.isAfter(
                                                            checkOutDateHere!)) {
                                                      setState(() {
                                                        checkOutDateHere = null;
                                                      });
                                                    }
                                                    setState(() {
                                                      checkInDateHere =
                                                          pickedDate;
                                                    });
                                                  }
                                                  if (checkOutDateHere !=
                                                          null &&
                                                      checkInDateHere != null) {
                                                    days = checkOutDateHere!
                                                        .difference(
                                                            checkInDateHere!)
                                                        .inDays;
                                                    log("$days");
                                                  }
                                                  setState1(() {});
                                                  setState(() {});
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "From".tr,
                                                      style: TextStyle(
                                                        fontFamily: 'Inter'.tr,
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
                                                        checkInDateHere != null
                                                            ? DateFormat(
                                                                    'd/MM/yyyy')
                                                                .format(
                                                                    checkInDateHere!)
                                                            : 'Select date'.tr,
                                                        style: TextStyle(
                                                          color:
                                                              checkInDateHere !=
                                                                      null
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                          fontWeight:
                                                              checkInDateHere != null
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

                                            // Vertical line
                                            Container(
                                              width: 1,
                                              height: 60,
                                              color: Colors.grey,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                            ),

                                            // Check-out date
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (checkInDateHere == null) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Please select check-in date first'
                                                                  .tr)),
                                                    );
                                                    return;
                                                  }

                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        checkInDateHere!.add(
                                                            Duration(days: 1)),
                                                    firstDate: checkInDateHere!
                                                        .add(Duration(days: 1)),
                                                    lastDate: DateTime(2030),
                                                  );
                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      checkOutDateHere =
                                                          pickedDate;
                                                    });
                                                  }
                                                  if (checkOutDateHere !=
                                                          null &&
                                                      checkInDateHere != null) {
                                                    days = checkOutDateHere!
                                                        .difference(
                                                            checkInDateHere!)
                                                        .inDays;
                                                    log("$days");
                                                  }
                                                  log("$days");
                                                  setState1(() {});
                                                  setState(() {});
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text("To".tr,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Inter'.tr,
                                                          color: kPrimaryColor,
                                                          fontSize: 12,
                                                        )),
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
                                                        checkOutDateHere != null
                                                            ? DateFormat(
                                                                    'd/MM/yyyy')
                                                                .format(
                                                                    checkOutDateHere!)
                                                            : 'Select date'.tr,
                                                        style: TextStyle(
                                                          color: checkOutDateHere !=
                                                                  null
                                                              ? (checkOutDateHere!.isAfter(
                                                                      checkInDateHere ??
                                                                          DateTime
                                                                              .now())
                                                                  ? Colors.black
                                                                  : Colors.red)
                                                              : Colors.grey,
                                                          fontWeight:
                                                              checkOutDateHere != null
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
                                              Text(
                                                "Guests".tr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Inter'.tr,
                                                  fontWeight: FontWeight.w600,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  children: [
                                                    // Adults
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Adults".tr,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Inter'.tr,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                if (adults >
                                                                    0) {
                                                                  setState(() {
                                                                    adults--;
                                                                  });
                                                                  setState1(
                                                                      () {}); // Update bottom sheet state
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 32,
                                                                width: 32,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              kColor1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 42,
                                                              child: Center(
                                                                child: Text(
                                                                  "$adults",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                if (adults <
                                                                    10) {
                                                                  // Max 10 adults
                                                                  setState(() {
                                                                    adults++;
                                                                  });
                                                                  setState1(
                                                                      () {}); // Update bottom sheet state
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text('Maximum 10 adults allowed'.tr)),
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 32,
                                                                width: 32,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              kColor1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Icon(
                                                                    Icons.add,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(),
                                                    // Children
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Children".tr,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Inter'.tr,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                if (children >
                                                                    0) {
                                                                  setState(() {
                                                                    children--;
                                                                  });
                                                                  setState1(
                                                                      () {}); // Update bottom sheet state
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 32,
                                                                width: 32,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              kColor1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 42,
                                                              child: Center(
                                                                child: Text(
                                                                  "$children",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                if (children <
                                                                    10) {
                                                                  // Max 10 adults
                                                                  setState(() {
                                                                    children++;
                                                                  });
                                                                  setState1(
                                                                      () {}); // Update bottom sheet state
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text('Maximum 10 children allowed'.tr)),
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 32,
                                                                width: 32,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              kColor1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Icon(
                                                                    Icons.add,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Row(
                                                        //   children: [
                                                        //     IconButton(
                                                        //       icon: Icon(Icons
                                                        //           .remove_circle_outline),
                                                        //       onPressed: () {
                                                        //           if (children > 0) {
                                                        //           setState(() {
                                                        //             children--;
                                                        //           });
                                                        //           setState1(
                                                        //               () {}); // Update bottom sheet state
                                                        //         }
                                                        //       },
                                                        //     ),
                                                        //     Text(
                                                        //             "$children",
                                                        //       style: TextStyle(
                                                        //           fontSize: 16),
                                                        //     ),
                                                        //     IconButton(
                                                        //       icon: Icon(Icons
                                                        //           .add_circle_outline),
                                                        //       onPressed: () {
                                                        //         if (children < 10) {
                                                        //           // Max 10 children
                                                        //           setState(() {
                                                        //             children++;
                                                        //           });
                                                        //           setState1(
                                                        //               () {}); // Update bottom sheet state
                                                        //         } else {
                                                        //           ScaffoldMessenger
                                                        //                   .of(context)
                                                        //               .showSnackBar(
                                                        //             SnackBar(
                                                        //                 content: Text(
                                                        //                     'Maximum 10 children allowed')),
                                                        //           );
                                                        //         }
                                                        //       },
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),

                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  alignment: Alignment.centerLeft,
                                  child: Text("Extra Prices:".tr,
                                      style: TextStyle(
                                          fontFamily: 'Inter'.tr,
                                          color: kPrimaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                ),
                                if (txSpaceDetail?.data?.extraPrice != null)
                                  ...(txSpaceDetail?.data?.extraPrice)!
                                      .map((element) {
                                    log("${element.valueType} checking value");
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
                                                  extraPriceValue += int.parse(
                                                      element.price ?? "0");
                                                } else {
                                                  extraPriceValue -= int.parse(
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

                                ...(txSpaceDetail?.data?.bookingFee)!
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

                                Container(
                                  padding: EdgeInsets.only(
                                      bottom: 10, left: 15, right: 15),
                                  child: Row(
                                    children: [
                                      Text("Total".tr,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Spacer(),
                                      Text(
                                          "\$${_calculateTotalPrice(txSpaceDetail, days, total, extraPriceValue)}",
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
                                      if (checkInDateHere == null ||
                                          checkOutDateHere == null) {
                                        EasyLoading.showToast(
                                            "Please select check-in and check-out dates"
                                                .tr,
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        return;
                                      }

                                      if (adults == 0 && children == 0) {
                                        EasyLoading.showToast(
                                            "Please select at least one guest"
                                                .tr,
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        return;
                                      }

                                      final spaceProvider =
                                          Provider.of<SpaceProvider>(context,
                                              listen: false);

                                      // Create guest data structure
                                      final guestData = {
                                        'adults': adults,
                                        'children': children,
                                      };

                                      // Get selected extra prices
                                      final selectedExtraPrices = txSpaceDetail
                                          ?.data?.extraPrice
                                          ?.where((element) =>
                                              element.valueType == true)
                                          .toList();

                                      final result =
                                          await spaceProvider.addToCartForSpace(
                                        serviceId: txSpaceDetail?.data?.id
                                                .toString() ??
                                            '',
                                        serviceType: 'space',
                                        startDate: checkInDateHere!,
                                        endDate: checkOutDateHere!,
                                        number: adults + children,
                                        guestData: guestData,
                                        extraPrices: selectedExtraPrices,
                                      );

                                      if (result != null &&
                                          result['status'] == 1) {
                                        EasyLoading.showToast(
                                            "Successfully added to booking".tr,
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        log("Booking Code: ${result['booking_code']}");
                                        Get.to(() => SpaceBookingScreen(
                                            bookingCode:
                                                result['booking_code']));
                                        // Navigate to cart screen or show confirmation dialog
                                      } else {
                                        String errorMessage =
                                            'Failed to add to booking'.tr;
                                        if (result != null &&
                                            result['errors'] != null) {
                                          // Handle specific error messages if needed
                                        }
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
                                              style: TextStyle(
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
                                          style: TextStyle(height: 1),
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
                                                      "${txSpaceDetail?.data?.id}",
                                                  serviceType: "space",
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
                                              style: TextStyle(
                                                color: kBackgroundColor,
                                                fontSize: 16,
                                                fontFamily: 'Inter',
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
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  double _calculateTotalPrice(
      SpaceDetailModal? spaceDetail, int days, int total, int extraPriceValue) {
    if (spaceDetail?.data == null) return 0.0;

    double basePrice = double.tryParse(
            spaceDetail!.data!.discountPercent == null
                ? spaceDetail.data!.price.toString()
                : (spaceDetail.data!.salePrice == 0
                    ? spaceDetail.data!.price.toString()
                    : spaceDetail.data!.salePrice.toString())) ??
        0.0;

    return basePrice + extraPriceValue + total + days * basePrice;
  }
  // List<Map<String, dynamic>> _parseSelectedGuests(
  //     String selectedGuests, List<PersonType>? personTypes) {
  //   // Parse the selected guests string (e.g. "2 adults, 1 children")
  //   final parts = selectedGuests.split(', ');
  //   final guestCounts = Map<String, int>.fromEntries(parts.map((part) {
  //     final count = int.parse(part.split(' ')[0]);
  //     final type = part.split(' ')[1].toLowerCase();
  //     return MapEntry(type, count);
  //   }));

  //   // Map to the person types format expected by the API
  //   return personTypes?.asMap().entries.map((entry) {
  //         final index = entry.key;
  //         final personType = entry.value;
  //         final typeName = personType.name?.toLowerCase() ?? '';

  //         return {
  //           'name': personType.name,
  //           'desc': personType.desc,
  //           'min': personType.min,
  //           'max': personType.max,
  //           'price': personType.price,
  //           'number': guestCounts[typeName] ?? 0,
  //         };
  //       }).toList() ??
  //       [];
  // }
}
