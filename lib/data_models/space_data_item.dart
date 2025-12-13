import 'dart:developer';

import 'package:moonbnd/Provider/space_provider.dart';
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





// ================ SPACE PROPERTY CARD ================
class SpaceItem extends StatefulWidget {
  const SpaceItem({
    super.key,
    required this.dataSrc,
    required this.press,
  });

  final SpaceData dataSrc;
  final VoidCallback press;

  @override
  State<SpaceItem> createState() => _SpaceItemState();
}

class _SpaceItemState extends State<SpaceItem> {


  Future<void> _handleWishlistTap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      showLoginBottomSheet(context);
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);
    final success = await homeProvider.addToWishlist(
      widget.dataSrc.id.toString(),
      'space',
    );

    homeProvider.homelistapi(0);
    spaceProvider.fetchSpaceDetails(widget.dataSrc.id ?? 0);
    await spaceProvider.spacelistapi(3, searchParams: {});

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


    // Convert rating to double
    double rating;
    try {
      rating = double.tryParse(widget.dataSrc.reviewscore) ?? 0.0;
    } catch (e) {
      rating = 0.0;
    }

    // Prepare features list
    final features = [
      '${widget.dataSrc.passenger} ${'people'.tr}',
      '${widget.dataSrc.bed} ${'beds'.tr}',
      '${widget.dataSrc.bathroom} ${'bathrooms'.tr}',
      '${widget.dataSrc.squarefeet} ${'sqft'.tr}',
    ];

    return buildPropertyCard(
      context: context,
      images: widget.dataSrc.images,
      title: widget.dataSrc.propertyName,
      subtitle: widget.dataSrc.address,
      rating: rating,
      reviewCount: int.tryParse(widget.dataSrc.reviewcount ?? "0") ?? 0,
      reviewText: widget.dataSrc.reviewtext,
      price: widget.dataSrc.price,
      isWishlist: widget.dataSrc.isWishlist,
      isFeatured: widget.dataSrc.isfeatured == 1,
      discount: widget.dataSrc.discount,
      onTap: widget.press,
      onWishlistTap: _handleWishlistTap,
      type: 'space',
      id: widget.dataSrc.id.toString(),
      badgeText: 'SPACE',
      badgeColor: Colors.teal,
      priceSuffix: '/day',
      features: features,
    );
  }
}


// class SpaceItem extends StatefulWidget {
//   const SpaceItem({
//     super.key,
//     required this.dataSrc,
//     required this.press,
//   });
//
//   final SpaceData dataSrc;
//   final VoidCallback press;
//
//   @override
//   State<SpaceItem> createState() => _SpaceItemState();
// }
//
// class _SpaceItemState extends State<SpaceItem> {
//   @override
//   Widget build(BuildContext context) {
//     final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);
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
//                       final success = await homeProvider.addToWishlist(
//                         widget.dataSrc.id.toString(),
//                         'space',
//                       );
//                       homeProvider.homelistapi(0);
//                       spaceProvider.fetchSpaceDetails(widget.dataSrc.id ?? 0);
//                       await spaceProvider.spacelistapi(3, searchParams: {});
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
//                 Positioned(
//                   bottom: 8,
//                   left: 8,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     child: Row(
//                       children: List.generate(
//                         5,
//                         (index) => Icon(
//                           index <
//                                   double.parse(widget.dataSrc.reviewscore)
//                                       .round()
//                               ? Icons.star
//                               : Icons.star_border,
//                           color: flutterpads,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
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
//                       fontSize: 16,
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
//                   Row(
//                     children: [
//                       Text(
//                         "${widget.dataSrc.passenger} people".tr,
//                         style: TextStyle(
//                           fontFamily: 'Inter'.tr,
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         " • ",
//                         style: TextStyle(
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         "${widget.dataSrc.bed} beds".tr,
//                         style: TextStyle(
//                           fontFamily: 'Inter'.tr,
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         " • ",
//                         style: TextStyle(
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         "${widget.dataSrc.bathroom} bathrooms".tr,
//                         style: TextStyle(
//                           fontFamily: 'Inter'.tr,
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         " • ".tr,
//                         style: TextStyle(
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         "${widget.dataSrc.squarefeet} sqft".tr,
//                         style: TextStyle(
//                           fontFamily: 'Inter'.tr,
//                           color: darkgrey,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
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
//                       // Text(
//                       //   "\$${dataSrc.salePrice}",
//                       //   style: TextStyle(
//                       //     fontFamily: 'Inter'.tr,
//                       //     fontWeight: FontWeight.w600,
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
//                           decoration: TextDecoration.underline,
//                           decorationThickness: 1.5,
//                           decorationColor: Colors.black,
//                         ),
//                       ),
//                       Text(
//                         "/day".tr,
//                         style: TextStyle(
//                           color: kPrimaryColor,
//                           fontFamily: 'Inter'.tr,
//                           decoration: TextDecoration.underline,
//                           decorationThickness: 1.5,
//                           decorationColor: Colors.black,
//                         ),
//                       ),
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
