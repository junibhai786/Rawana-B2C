// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';

import 'package:moonbnd/Provider/tour_provider.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/Imagecarouselwithdots.dart';
import 'package:moonbnd/data_models/home_screen_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/card_widget.dart';


// ================ TOUR PROPERTY CARD ================
class TourItem extends StatefulWidget {
  const TourItem({
    super.key,
    required this.dataSrc,
    required this.press,
  });

  final TourData dataSrc;
  final VoidCallback press;

  @override
  State<TourItem> createState() => _TourItemState();
}

class _TourItemState extends State<TourItem> {
  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);

    return buildPropertyCard(
      context: context,
      images: widget.dataSrc.images,
      title: widget.dataSrc.propertyName,
      subtitle: widget.dataSrc.address,
      rating: double.parse(widget.dataSrc.reviewscore),
      reviewCount: int.tryParse(widget.dataSrc.reviewcount ?? "0") ?? 0,
      reviewText: widget.dataSrc.reviewtext,
      price: widget.dataSrc.price,
      salePrice: widget.dataSrc.salePrice.isNotEmpty ? widget.dataSrc.salePrice : null,
      isWishlist: widget.dataSrc.isWishlist,
      isFeatured: widget.dataSrc.isfeatured == 1,
      discount: widget.dataSrc.discount,
      onTap: widget.press,
      onWishlistTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken');

        if (token == null) {
          showLoginBottomSheet(context);
          return;
        }

        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        final success = await homeProvider.addToWishlist(
          widget.dataSrc.id.toString(),
          'tour',
        );

        homeProvider.homelistapi(0);
        tourProvider.fetchTourDetails(widget.dataSrc.id ?? 0);
        await tourProvider.tourlistapi(2, searchParams: {});

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
      },
      type: 'tour',
      id: widget.dataSrc.id.toString(),
      badgeText: 'TOUR',
      badgeColor: Colors.orange,
      priceSuffix: '',
    );
  }
}


// class TourItem extends StatefulWidget {
//   const TourItem({
//     super.key,
//     required this.dataSrc,
//     required this.press,
//   });
//
//   final TourData dataSrc;
//   final VoidCallback press;
//
//   @override
//   State<TourItem> createState() => _TourItemState();
// }
//
// class _TourItemState extends State<TourItem> {
//   @override
//   Widget build(BuildContext context) {
//     final tourProvider = Provider.of<TourProvider>(context, listen: false);
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
//                   images: widget.dataSrc.images,
//                 ),
//                 Positioned(
//                   top: 12,
//                   right: 12,
//                   child: InkWell(
//                     onTap: () async {
//                       log("fav 1");
//
//                       final prefs = await SharedPreferences.getInstance();
//                       final token = prefs.getString('userToken');
//
//                       if (token == null) {
//                         // Show the custom bottom sheet
//                         showModalBottomSheet(
//                           context: context,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(16),
//                               topRight: Radius.circular(16),
//                             ),
//                           ),
//                           builder: (context) => CustomBottomSheet(
//                             title: 'Log in to add to',
//                             content: 'wishlists',
//                             onCancel: () {
//                               Navigator.of(context)
//                                   .pop(); // Close the bottom sheet
//                             },
//                             onLogin: () {
//                               // Close the bottom sheet
//                               Navigator.of(context).pushReplacement(
//                                 MaterialPageRoute(
//                                     builder: (context) => SignInScreen()),
//                               ); // Navigate to SignInScreen
//                             },
//                           ),
//                         );
//                         return; // Exit the function if token is null
//                       }
//                       final homeProvider =
//                           Provider.of<HomeProvider>(context, listen: false);
//                       final success = await homeProvider.addToWishlist(
//                         widget.dataSrc.id.toString(),
//                         'tour',
//                       );
//                       homeProvider.homelistapi(0);
//                       tourProvider.fetchTourDetails(widget.dataSrc.id ?? 0);
//                       await tourProvider.tourlistapi(2, searchParams: {});
//
//                       if (success == "Added to wishlist") {
//                         setState(() {
//                           widget.dataSrc.isWishlist = true;
//                         });
//                       } else if (success == "Removed from wishlist") {
//                         setState(() {
//                           widget.dataSrc.isWishlist = false;
//                         });
//                       }
//
//                       // ignore: use_build_context_synchronously
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(success)),
//                       );
//                     },
//                     child: SvgPicture.asset(
//                       widget.dataSrc.isWishlist
//                           ? 'assets/icons/like.svg'
//                           : 'assets/icons/heart.svg',
//                       width: 24,
//                       height: 20,
//                     ),
//                   ),
//                 ),
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
//                 widget.dataSrc.discount != 0
//                     ? Positioned(
//                         bottom: 12,
//                         right: 12,
//                         child: Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Text(
//                               '${widget.dataSrc.discount} % OFF'.tr,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             )),
//                       )
//                     : SizedBox.shrink(),
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
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.dataSrc.propertyName,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Inter'.tr,
//                       fontSize: 14,
//                     ),
//                     maxLines: 1,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.dataSrc.address,
//                     style: TextStyle(fontFamily: 'Inter'.tr, color: darkgrey),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             '${widget.dataSrc.reviewscore}/5',
//                             style: TextStyle(
//                                 fontFamily: 'Inter'.tr,
//                                 fontWeight: FontWeight.w400,
//                                 color: flutterpads,
//                                 fontSize: 12),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             widget.dataSrc.reviewtext,
//                             style: TextStyle(
//                                 fontFamily: 'Inter'.tr,
//                                 color: flutterpads,
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 14),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${widget.dataSrc.reviewcount} reviews'.tr,
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontFamily: 'Inter'.tr,
//                           color: darkgrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       // Text(
//                       //   "from ".tr,
//                       //   style: TextStyle(
//                       //     fontFamily: 'Inter'.tr,
//                       //     fontWeight: FontWeight.w500,
//                       //     decoration: TextDecoration.underline,
//                       //     decorationThickness: 1.5,
//                       //     decorationColor: Colors.black,
//                       //   ),
//                       // ),
//                       Text(
//                         "\$${widget.dataSrc.price}",
//                         style: TextStyle(
//                           fontFamily: 'Inter'.tr,
//                           fontWeight: FontWeight.w600,
//                           // decoration: TextDecoration.underline,
//                           decorationThickness: 1.5,
//                           decorationColor: Colors.black,
//                         ),
//                       ),
//
//                       // Text(
//                       //   "/night".tr,
//                       //   style: TextStyle(
//                       //     color: darkgrey,
//                       //     fontFamily: 'Inter'.tr,
//                       //     decoration: TextDecoration.underline,
//                       //     decorationThickness: 1.5,
//                       //     decorationColor: Colors.black,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                   if (widget.dataSrc.salePrice.isNotEmpty)
//                     Text("\$${widget.dataSrc.salePrice}",
//                         style: TextStyle(
//                             decoration: TextDecoration.lineThrough,
//                             color: Colors.red)),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 36,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
