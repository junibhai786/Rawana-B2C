import 'dart:developer';

import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/Imagecarouselwithdots.dart';
import 'package:moonbnd/data_models/home_screen_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/card_widget.dart';


// ================ BOAT PROPERTY CARD ================
class BoatItem extends StatefulWidget {
  const BoatItem({
    super.key,
    required this.dataSrc,
    required this.press,
  });

  final BoatData dataSrc;
  final VoidCallback press;
  @override
  State<BoatItem> createState() => _BoatItemState();
}

class _BoatItemState extends State<BoatItem> {


  Future<void> _handleWishlistTap() async {
    log("fav 1");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      showLoginBottomSheet(context);
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final boatProvider = Provider.of<BoatProvider>(context, listen: false);
    final success = await homeProvider.addToWishlist(
      widget.dataSrc.id.toString(),
      'boat',
    );

    homeProvider.homelistapi(0);
    await boatProvider.boatlistapi(7, searchParams: {});

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

  @override
  Widget build(BuildContext context) {
    // Convert reviewcount to int
    int reviewCount;
    try {
      reviewCount = int.tryParse(widget.dataSrc.reviewcount?.toString() ?? '0') ?? 0;
    } catch (e) {
      reviewCount = 0;
    }

    // Convert rating to double
    double rating;
    try {
      rating = double.tryParse(widget.dataSrc.reviewscore) ?? 0.0;
    } catch (e) {
      rating = 0.0;
    }

    // Prepare features list
    final features = [
      '${widget.dataSrc.maxpassenger} ${'guests'.tr}',
      '${widget.dataSrc.cabin} ${'cabin'.tr}',
    ];

    return buildPropertyCard(
      context: context,
      images: widget.dataSrc.images,
      title: widget.dataSrc.propertyName,
      subtitle: widget.dataSrc.address,
      rating: rating,
      reviewCount: reviewCount,
      reviewText: widget.dataSrc.reviewtext,
      price: widget.dataSrc.price,
      isWishlist: widget.dataSrc.isWishlist,
      isFeatured: false,
      discount: 0,
      onTap: widget.press,
      onWishlistTap: _handleWishlistTap,
      type: 'boat',
      id: widget.dataSrc.id.toString(),
      badgeText: 'BOAT',
      badgeColor: AppColors.accent,
      priceSuffix: '',
      features: features,
    );
  }
}


// class BoatItem extends StatefulWidget {
//   const BoatItem({
//     super.key,
//     required this.dataSrc,
//     required this.press,
//   });
//
//   final BoatData dataSrc;
//   final VoidCallback press;
//
//   @override
//   State<BoatItem> createState() => _BoatItemState();
// }
//
// class _BoatItemState extends State<BoatItem> {
//   @override
//   Widget build(BuildContext context) {
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
//                       final boatProvider =
//                           Provider.of<BoatProvider>(context, listen: false);
//
//                       final success = await homeProvider.addToWishlist(
//                         widget.dataSrc.id.toString(),
//                         'boat',
//                       );
//                       homeProvider.homelistapi(0);
//                       await boatProvider.boatlistapi(7, searchParams: {});
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
//                       Text(
//                         widget.dataSrc.propertyName,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Inter'.tr,
//                           fontSize: 16,
//                         ),
//                         maxLines: 1,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         widget.dataSrc.address,
//                         style:
//                             TextStyle(fontFamily: 'Inter'.tr, color: darkgrey),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Text(
//                             '${widget.dataSrc.reviewscore}/5',
//                             style: TextStyle(
//                                 fontFamily: 'Inter'.tr,
//                                 fontWeight: FontWeight.w400,
//                                 color: flutterpads,
//                                 fontSize: 14),
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
//                       Row(
//                         children: [
//                           Text(
//                             "${widget.dataSrc.maxpassenger} guests".tr,
//                             style: TextStyle(
//                               fontFamily: 'Inter'.tr,
//                               color: darkgrey,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             " • ",
//                             style: TextStyle(
//                               color: darkgrey,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             "${widget.dataSrc.cabin} cabin".tr,
//                             style: TextStyle(
//                               fontFamily: 'Inter'.tr,
//                               color: darkgrey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Text(
//                             "from ".tr,
//                             style: TextStyle(
//                               fontFamily: 'Inter'.tr,
//                               fontWeight: FontWeight.w500,
//                               decoration: TextDecoration.underline,
//                               decorationThickness: 1.5,
//                               decorationColor: Colors.black,
//                             ),
//                           ),
//                           Text(
//                             "\$${widget.dataSrc.price}",
//                             style: TextStyle(
//                               fontFamily: 'Inter'.tr,
//                               fontWeight: FontWeight.w600,
//                               decoration: TextDecoration.underline,
//                               decorationThickness: 1.5,
//                               decorationColor: Colors.black,
//                             ),
//                           ),
//                           // Text(
//                           //   "/night".tr,
//                           //   style: TextStyle(
//                           //     color: darkgrey,
//                           //     fontFamily: 'Inter'.tr,
//                           //     decoration: TextDecoration.underline,
//                           //     decorationThickness: 1.5,
//                           //     decorationColor: Colors.black,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // Row(
//                       //   children: [
//                       //     const Icon(
//                       //       Icons.star,
//                       //       color: Colors.black,
//                       //       size: 14,
//                       //     ),
//                       //     const SizedBox(width: 4),
//                       //     Text(
//                       //       '${dataSrc.rating}',
//                       //       style: const TextStyle(
//                       //         color: kPrimaryColor,
//                       //         fontSize: 12,
//                       //         fontWeight: FontWeight.w500,
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       const SizedBox(height: 36),
//                       Text(
//                         '${widget.dataSrc.reviewcount} reviews'.tr,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontFamily: 'Inter'.tr,
//                           color: darkgrey,
//                         ),
//                       ),
//                       SizedBox(height: 2),
//                       // Text(
//                       //   '5 hours'.tr,
//                       //   style: TextStyle(
//                       //     fontSize: 10,
//                       //     fontFamily: 'Inter'.tr,
//                       //     color: darkgrey,
//                       //   ),
//                       // ),
//                     ],
//                   ),
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
