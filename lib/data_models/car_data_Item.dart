import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_one_screen.dart';
import 'package:moonbnd/vendor/hotel/hotel_detail_webview.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/Imagecarouselwithdots.dart';
import 'package:moonbnd/data_models/home_screen_data.dart';
import 'package:moonbnd/modals/car_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/card_widget.dart';



// ================ CAR PROPERTY CARD ================
class CarDataItem extends StatefulWidget {
  CarDataItem({
    super.key,
    required this.dataSrc,
    required this.press,
    this.managecar,
  });

  final bool? managecar;
  final CarData dataSrc;
  final VoidCallback press;

  @override
  State<CarDataItem> createState() => _CarDataItemState();
}

class _CarDataItemState extends State<CarDataItem> {
  @override
  Widget build(BuildContext context) {
    final features = widget.managecar != true
        ? [
      '${widget.dataSrc.passenger} passengers',
      widget.dataSrc.gear ?? '',
      '${widget.dataSrc.baggage} baggage',
      '${widget.dataSrc.door} doors',
    ]
        : null;

    return buildPropertyCard(
      context: context,
      images: widget.dataSrc.images ?? [],
      title: widget.dataSrc.title ?? '',
      subtitle: widget.dataSrc.address ?? '',
      rating: double.tryParse(widget.dataSrc.reviewScore.toString()) ?? 0.0,

      reviewCount: 0,
      reviewText: widget.dataSrc.reviewText ?? '',
      price: widget.dataSrc.saleprice == 0 || widget.dataSrc.saleprice == null
          ? widget.dataSrc.price ?? 0
          : widget.dataSrc.saleprice ?? 0,
      salePrice: widget.dataSrc.saleprice != 0 && widget.dataSrc.saleprice != null
          ? widget.dataSrc.price
          : null,
      isWishlist: widget.dataSrc.isWishlist,
      isFeatured: widget.dataSrc.isfeatured == 1,
      discount: 0,
      onTap: widget.press,
      onWishlistTap: widget.managecar == true ? null : _handleWishlistTap,
      type: 'car',
      id: widget.dataSrc.id.toString(),
      badgeText: 'CAR',
      badgeColor: AppColors.secondary,
      priceSuffix: '/day',
      features: features,
      status: widget.dataSrc.status,
      manageView: widget.managecar == true,
    );
  }

  Future<void> _handleWishlistTap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      showLoginBottomSheet(context);
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final success = await homeProvider.addToWishlist(
      widget.dataSrc.id.toString(),
      'car',
    );

    homeProvider.homelistapi(0);
    homeProvider.fetchCarvendorDetails();
    await homeProvider.carlistapi(4, searchParams: {});

    if (success == "Added to wishlist") {
      setState(() {
        widget.dataSrc.isWishlist = true;
      });
    } else if (success == "Removed from wishlist") {
      setState(() {
        widget.dataSrc.isWishlist = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}


// // ignore: must_be_immutable
// class CarDataItem extends StatefulWidget {
//   CarDataItem({
//     super.key,
//     required this.dataSrc,
//     required this.press,
//     this.managecar,
//     CarList? carList,
//   });
//   final bool? managecar;
//   CarData dataSrc;
//   final VoidCallback press;
//
//   @override
//   State<CarDataItem> createState() => _CarDataItemState();
// }
//
// class _CarDataItemState extends State<CarDataItem> {
//   String formatTimestamp(String timestamp) {
//     DateTime parsedDate = DateTime.parse(timestamp);
//     String formattedDate = DateFormat('MM/dd/yyyy HH:mm').format(parsedDate);
//     return formattedDate;
//   }
//
//   void _showDeleteConfirmation(
//       BuildContext context, HomeProvider homeProvider) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Are you sure?'.tr,
//                     style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w400,
//                         color: kPrimaryColor,
//                         fontFamily: 'Inter'.tr),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Text(
//                     'Car Delete Permanently'.tr,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: kPrimaryColor,
//                       fontFamily: 'Inter'.tr,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: flutterpads),
//                         foregroundColor: flutterpads,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       onPressed: () => homeProvider
//                           .deletevendorcar(id: widget.dataSrc.id.toString())
//                           .then(
//                         (value) {
//                           if (value == true) {
//                             homeProvider.fetchCarvendorDetails();
//                             Navigator.pop(context);
//                           }
//                         },
//                       ),
//                       child: Text('Delete'.tr),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: kSecondaryColor,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                       child: Text('Cancel'.tr),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final homeProvider = Provider.of<HomeProvider>(context, listen: true);
//
//     log("${widget.dataSrc.isWishlist} truechange");
//     return GestureDetector(
//       onTap: widget.press,
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: kColor1,
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ImageCarouselWithDots(
//                   images: widget.dataSrc.images ?? [],
//                 ),
//                 widget.managecar == true
//                     ? Positioned(
//                         top: 12,
//                         left: 12,
//                         child: InkWell(
//                           onTap: () async {
//                             log("fav 1");
//                             final homeProvider = Provider.of<HomeProvider>(
//                                 context,
//                                 listen: false);
//                             final success = await homeProvider.addToWishlist(
//                               widget.dataSrc.id.toString(),
//                               'car',
//                             );
//
//                             homeProvider.carlistapi(4, searchParams: {});
//                             homeProvider.fetchCarvendorDetails();
//                             if (success == "Added to wishlist") {
//                               setState(() {
//                                 widget.dataSrc.isWishlist = true;
//                               });
//                             } else if (success == "Removed from wishlist") {
//                               setState(() {
//                                 widget.dataSrc.isWishlist = false;
//                               });
//                             }
//
//                             // // Notify listeners to rebuild the widget
//                             // homeProvider.notifyListeners();
//
//                             // Notify listeners to rebuild the widget
//
//                             // ignore: use_build_context_synchronously
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(success)),
//                             );
//                           },
//                           child: SvgPicture.asset(
//                             widget.dataSrc.isWishlist
//                                 ? 'assets/icons/like.svg'
//                                 : 'assets/icons/heart.svg',
//                             width: 24,
//                             height: 20,
//                           ),
//                         ),
//                       )
//                     : SizedBox(),
//                 widget.managecar == true
//                     ? Positioned(
//                         top: 10,
//                         right: 10,
//                         child: Row(
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 _showDeleteConfirmation(context, homeProvider);
//                               },
//                               child: Container(
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(5),
//                                     color: Colors.red),
//                                 child: Icon(Icons.delete, color: Colors.white),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             InkWell(
//                               onTap: () {
//                                 if (widget.dataSrc.status == 'publish') {
//                                   homeProvider
//                                       .hidecarvendor(
//                                           id: widget.dataSrc.id.toString())
//                                       .then(
//                                     (value) {
//                                       if (value == true) {
//                                         homeProvider.fetchCarvendorDetails();
//                                       }
//                                     },
//                                   );
//                                 } else {
//                                   homeProvider
//                                       .publishcarvendor(
//                                           id: widget.dataSrc.id.toString())
//                                       .then(
//                                     (value) {
//                                       if (value == true) {
//                                         homeProvider.fetchCarvendorDetails();
//                                       }
//                                     },
//                                   );
//                                 }
//                               },
//                               child: Container(
//                                   height: 40,
//                                   width: 40,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5),
//                                       color: widget.dataSrc.status == 'publish'
//                                           ? AppColors.secondary
//                                           : Colors.grey),
//                                   child: Icon(
//                                       widget.dataSrc.status == 'publish'
//                                           ? Icons.visibility
//                                           : Icons.visibility_off,
//                                       color: Colors.white)),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Positioned(
//                         top: 12,
//                         right: 12,
//                         child: InkWell(
//                           onTap: () async {
//                             log("fav 1");
//                             final prefs = await SharedPreferences.getInstance();
//                             final token = prefs.getString('userToken');
//
//                             if (token == null) {
//                               // Show the custom bottom sheet
//                               showModalBottomSheet(
//                                 context: context,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(16),
//                                     topRight: Radius.circular(16),
//                                   ),
//                                 ),
//                                 builder: (context) => CustomBottomSheet(
//                                   title: 'Log in to add to'.tr,
//                                   content: 'wishlists'.tr,
//                                   onCancel: () {
//                                     Navigator.of(context)
//                                         .pop(); // Close the bottom sheet
//                                   },
//                                   onLogin: () {
//                                     // Close the bottom sheet
//                                     Navigator.of(context).pushReplacement(
//                                       MaterialPageRoute(
//                                           builder: (context) => SignInScreen()),
//                                     ); // Navigate to SignInScreen
//                                   },
//                                 ),
//                               );
//                               return; // Exit the function if token is null
//                             }
//                             final homeProvider = Provider.of<HomeProvider>(
//                                 context,
//                                 listen: false);
//                             final success = await homeProvider.addToWishlist(
//                               widget.dataSrc.id.toString(),
//                               'car',
//                             );
//                             homeProvider.homelistapi(0);
//                             homeProvider.fetchCarvendorDetails();
//                             await homeProvider.carlistapi(4, searchParams: {});
//
//                             if (success == "Added to wishlist") {
//                               setState(() {
//                                 widget.dataSrc.isWishlist = true;
//                               });
//                             } else if (success == "Removed from wishlist") {
//                               setState(() {
//                                 widget.dataSrc.isWishlist = false;
//                               });
//                             }
//
//                             // Notify listeners to rebuild the widget
//
//                             // ignore: use_build_context_synchronously
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(success)),
//                             );
//                           },
//                           child: SvgPicture.asset(
//                             widget.dataSrc.isWishlist
//                                 ? 'assets/icons/like.svg'
//                                 : 'assets/icons/heart.svg',
//                             width: 24,
//                             height: 20,
//                           ),
//                         ),
//                       ),
//
//                 widget.dataSrc.isfeatured == 1
//                     ? Positioned(
//                         top: 12,
//                         left: 12,
//                         child: Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Text(
//                               'Featured'.tr,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             )),
//                       )
//                     : SizedBox.shrink(),
//
//                 // Positioned(
//                 //   bottom: 8,
//                 //   left: 8,
//                 //   child: Container(
//                 //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 //     child: Row(
//                 //       children: List.generate(
//                 //         5,
//                 //         (index) => Icon(
//                 //           index < dataSrc.rating
//                 //               ? Icons.star
//                 //               : Icons.star_border,
//                 //           color: flutterpads,
//                 //           size: 20,
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 300,
//                         child: Text(
//                           widget.dataSrc.title ?? '',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'Inter'.tr,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       widget.managecar == true
//                           ? Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Price:".tr,
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         fontWeight: FontWeight.w500,
//                                         decorationThickness: 1.5,
//                                         decorationColor: Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       "\$${widget.dataSrc.saleprice == 0 ? widget.dataSrc.price ?? 0 : widget.dataSrc.saleprice ?? 0}",
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         color: Colors.grey,
//                                         fontWeight: FontWeight.w200,
//                                         decorationColor: Colors.grey,
//                                       ),
//                                     ),
//                                     // Text(
//                                     //   "/day".tr,
//                                     //   style: TextStyle(
//                                     //     color: darkgrey,
//                                     //     fontFamily: 'Inter'.tr,
//                                     //     decoration: TextDecoration.underline,
//                                     //     decorationThickness: 1.5,
//                                     //     decorationColor: Colors.black,
//                                     //   ),
//                                     // ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Status:".tr,
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         fontWeight: FontWeight.w500,
//                                         decorationThickness: 1.5,
//                                         decorationColor: Colors.black,
//                                       ),
//                                     ),
//                                     Container(
//                                       height: 25,
//                                       decoration: BoxDecoration(
//                                           color: kSecondaryColor,
//                                           borderRadius:
//                                               BorderRadius.circular(10)),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 20, vertical: 3),
//                                         child: Text(
//                                           "${widget.dataSrc.status} ",
//                                           style: TextStyle(
//                                             fontFamily: 'Inter'.tr,
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w200,
//                                             decorationColor: Colors.grey,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     // Text(
//                                     //   "/day".tr,
//                                     //   style: TextStyle(
//                                     //     color: darkgrey,
//                                     //     fontFamily: 'Inter'.tr,
//                                     //     decoration: TextDecoration.underline,
//                                     //     decorationThickness: 1.5,
//                                     //     decorationColor: Colors.black,
//                                     //   ),
//                                     // ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Last Updated:".tr,
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         fontWeight: FontWeight.w500,
//                                         decorationThickness: 1.5,
//                                         decorationColor: Colors.black,
//                                       ),
//                                     ),
//
//                                     Text(
//                                       formatTimestamp(
//                                           widget.dataSrc.updatedat ?? ""),
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         color: Colors.grey,
//                                         fontWeight: FontWeight.w200,
//                                         decorationColor: Colors.grey,
//                                       ),
//                                     ),
//                                     // Text(
//                                     //   "/day".tr,
//                                     //   style: TextStyle(
//                                     //     color: darkgrey,
//                                     //     fontFamily: 'Inter'.tr,
//                                     //     decoration: TextDecoration.underline,
//                                     //     decorationThickness: 1.5,
//                                     //     decorationColor: Colors.black,
//                                     //   ),
//                                     // ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     ButtonBar(
//                                       alignment: MainAxisAlignment.center,
//                                       children: [
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     WebViewScreen(
//                                                   appbartitle: "Car Details".tr,
//                                                   url:
//                                                       "${widget.dataSrc.detailsurl}",
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           child: Text('View'.tr),
//                                           style: TextButton.styleFrom(
//                                             backgroundColor: AppColors.secondary,
//                                             foregroundColor: Colors.white,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 25, vertical: 10),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                             ),
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             homeProvider
//                                                 .clonecarvendor(
//                                                     id: widget.dataSrc.id
//                                                         .toString())
//                                                 .then((value) {
//                                               if (value == true) {
//                                                 homeProvider
//                                                     .fetchCarvendorDetails();
//                                               }
//                                             });
//                                             // homeProvider
//                                             //     .clonehotelvendor(
//                                             //     id: widget.hotel?.id.toString()??"")
//                                             //     .then(
//                                             //       (value) {
//                                             //     if (value == true) {
//                                             //       homeProvider
//                                             //           .fetchallhotelvendor();
//                                             //     }
//                                             //   },
//                                             // );
//                                           },
//                                           child: Text('Clone'.tr),
//                                           style: TextButton.styleFrom(
//                                             backgroundColor: AppColors.accent,
//                                             foregroundColor: Colors.white,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 25, vertical: 10),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                             ),
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () async {
//                                             await homeProvider
//                                                 .fetchCarvendor(
//                                                     widget.dataSrc.id ?? 0)
//                                                 .then((value) => Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             EditCarScreen(
//                                                               terms: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.terms,
//                                                               zoom: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.mapZoom,
//                                                               number: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.number,
//                                                               carid: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.id,
//                                                               gallery: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.gallery,
//                                                               extraPrice: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.extraPrice,
//                                                               url: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.ical_import_url,
//                                                               saleprice: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.salePrice,
//                                                               defaultstate: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.defaultState,
//                                                               faqs: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.faqs,
//                                                               featuredimage:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.image,
//                                                               selectdoor:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.door,
//                                                               baggage: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.baggage,
//                                                               passenger: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.passenger,
//                                                               gearshift:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.gear,
//                                                               title: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.title,
//                                                               content: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.content,
//                                                               youtubeVideo:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.video,
//                                                               bannerimage: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.bannerImage,
//                                                               starrate: 0,
//                                                               featuredImage:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.isFeatured
//                                                                       .toString(),
//                                                               HotelrelatedId:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.id,
//                                                               locationid:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.location
//                                                                       ?.id,
//                                                               address: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.address,
//                                                               maplatitude:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.mapLat,
//                                                               maplongitude:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.mapLng,
//                                                               minreservation:
//                                                                   homeProvider
//                                                                       .vendorcarDetail
//                                                                       ?.data
//                                                                       ?.min_day_stays,
//                                                               minreq: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.min_day_before_booking,
//                                                               price: homeProvider
//                                                                   .vendorcarDetail
//                                                                   ?.data
//                                                                   ?.price,
//                                                               id: widget
//                                                                   .dataSrc.id,
//                                                             ))));
//                                             print(
//                                                 "valur of${homeProvider.vendorcarDetail?.data?.price}");
//                                           },
//                                           style: TextButton.styleFrom(
//                                             backgroundColor: AppColors.accent,
//                                             foregroundColor: Colors.black,
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 24, vertical: 10),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             'Edit'.tr,
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 )
//                                 //     // Text(
//                                 //     //   "/day".tr,
//                                 //     //   style: TextStyle(
//                                 //     //     color: darkgrey,
//                                 //     //     fontFamily: 'Inter'.tr,
//                                 //     //     decoration: TextDecoration.underline,
//                                 //     //     decorationThickness: 1.5,
//                                 //     //     decorationColor: Colors.black,
//                                 //     //   ),
//                                 //     // ),
//                                 //   ],
//                                 // ),
//                               ],
//                             )
//                           : Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   width: 300,
//                                   child: Text(
//                                     widget.dataSrc.address ?? "",
//                                     maxLines: null,
//                                     style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         color: darkgrey,
//                                         fontSize: 14),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       '${widget.dataSrc.reviewScore}/5',
//                                       style: TextStyle(
//                                           fontFamily: 'Inter'.tr,
//                                           fontWeight: FontWeight.w400,
//                                           color: flutterpads,
//                                           fontSize: 14),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       widget.dataSrc.reviewText ?? "",
//                                       style: TextStyle(
//                                           fontFamily: 'Inter'.tr,
//                                           color: flutterpads,
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 14),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 const SizedBox(height: 4),
//                               ],
//                             ),
//                       widget.managecar == true
//                           ? SizedBox()
//                           : Row(
//                               children: [
//                                 Text(
//                                   "${widget.dataSrc.passenger} ${'passengers'.tr}",
//                                   style: TextStyle(
//                                     fontFamily: 'Inter'.tr,
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 Text(
//                                   " • ",
//                                   style: TextStyle(
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 Text(
//                                   "${widget.dataSrc.gear}",
//                                   style: TextStyle(
//                                     fontFamily: 'Inter'.tr,
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 Text(
//                                   " • ",
//                                   style: TextStyle(
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 Text(
//                                   "${widget.dataSrc.baggage} ${'baggage'.tr}",
//                                   style: TextStyle(
//                                     fontFamily: 'Inter'.tr,
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 Text(
//                                   " • ".tr,
//                                   style: TextStyle(
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 Text(
//                                   "${widget.dataSrc.door} ${'doors'.tr}",
//                                   style: TextStyle(
//                                     fontFamily: 'Inter'.tr,
//                                     color: darkgrey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                       const SizedBox(height: 4),
//                       widget.managecar == true
//                           ? SizedBox()
//                           : Row(
//                               children: [
//                                 Text(
//                                   "from ".tr,
//                                   style: TextStyle(
//                                     fontFamily: 'Inter'.tr,
//                                     fontWeight: FontWeight.w500,
//                                     decoration: TextDecoration.underline,
//                                     decorationThickness: 1.5,
//                                     decorationColor: Colors.black,
//                                   ),
//                                 ),
//                                 Text(
//                                   "\$${widget.dataSrc.saleprice == 0 || widget.dataSrc.saleprice == null ? widget.dataSrc.price : widget.dataSrc.saleprice}",
//                                   style: TextStyle(
//                                     fontFamily: 'Inter'.tr,
//                                     fontWeight: FontWeight.w600,
//                                     decoration: TextDecoration.underline,
//                                     decorationThickness: 1.5,
//                                     decorationColor: Colors.black,
//                                   ),
//                                 ),
//                                 Text(
//                                   "/day".tr,
//                                   style: TextStyle(
//                                     color: darkgrey,
//                                     fontFamily: 'Inter'.tr,
//                                     decoration: TextDecoration.underline,
//                                     decorationThickness: 1.5,
//                                     decorationColor: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ],
//                   ),
//                   // Column(
//                   //   crossAxisAlignment: CrossAxisAlignment.end,
//                   //   children: [
//                   //     Row(
//                   //       children: [
//                   //         const Icon(
//                   //           Icons.star,
//                   //           color: Colors.black,
//                   //           size: 14,
//                   //         ),
//                   //         const SizedBox(width: 4),
//                   //         Text(
//                   //           '${dataSrc.door}',
//                   //           style: const TextStyle(
//                   //             color: kPrimaryColor,
//                   //             fontSize: 14,
//                   //             fontWeight: FontWeight.w500,
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //     const SizedBox(height: 2),
//                   //     Text(
//                   //       '${dataSrc.gear} reviews'.tr,
//                   //       style: TextStyle(
//                   //         fontSize: 10,
//                   //         fontFamily: 'Inter'.tr,
//                   //         color: darkgrey,
//                   //       ),
//                   //     ),
//                   //     SizedBox(height: 2),
//                   //     Text(
//                   //       '5 hours'.tr,
//                   //       style: TextStyle(
//                   //         fontSize: 10,
//                   //         fontFamily: 'Inter'.tr,
//                   //         color: darkgrey,
//                   //       ),x
//                   //     ),
//                   //   ],
//                   // ),
//                 ],
//               ),
//             ),
//             widget.managecar == true
//                 ? Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: TextButton(
//                         onPressed: () async {
//                           log('${widget.dataSrc.availability_url}');
//
//                           // ignore: deprecated_member_use
//                           await launch(widget.dataSrc.availability_url ?? "");
//                         },
//                         style: TextButton.styleFrom(
//                           backgroundColor: AppColors.accent,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 41, vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SvgPicture.asset(
//                               'assets/icons/available.svg',
//                             ),
//                             SizedBox(width: 10),
//                             Text('Availability'.tr),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : SizedBox(),
//             const SizedBox(height: 15),
//           ],
//         ),
//       ),
//     );
//   }
// }
