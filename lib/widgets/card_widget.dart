// Professional Card Design for All Property Types

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/Imagecarouselwithdots.dart';

import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/event/event_detail_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'dart:developer';



// Common Card Styling Constants
class CardStyle {
  static const double borderRadius = 12.0;
  static const double elevation = 2.0;
  static const Color shadowColor = Color(0x0A000000);
  static const double contentPadding = 16.0;
  static const double imageHeight = 180.0;
  static const double iconSize = 20.0;
}

// ================ UNIVERSAL CARD BUILDER ================
Widget buildPropertyCard({
  required BuildContext context,
  required List<String> images,
  required String title,
  required String subtitle,
  required double rating,
  required int reviewCount,
  required String reviewText,
  required dynamic price,
  required bool isWishlist,
  required bool isFeatured,
  required int discount,
  required VoidCallback onTap,
  required VoidCallback? onWishlistTap,
  required String type,
  required String id,
  required String badgeText,
  required Color badgeColor,
  required String priceSuffix,
  List<String>? features,
  dynamic salePrice,
  String? status,
  bool manageView = false,
  String? extraInfo,
String? duration,
}) {
  return GestureDetector(
    onTap: onTap, // This will now trigger navigation
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CardStyle.borderRadius),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: CardStyle.shadowColor,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(CardStyle.borderRadius),
                  topRight: Radius.circular(CardStyle.borderRadius),
                ),
                child: ImageCarouselWithDots(
                  images: images,

                ),
              ),

              // Type Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Featured Badge
              if (isFeatured)
                Positioned(
                  top: 40,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Featured'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Discount Badge
              if (discount > 0)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${discount}% OFF'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Status Badge (for manage view)
              if (manageView && status != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'publish' ? AppColors.secondary : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Wishlist Heart
              if (onWishlistTap != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        isWishlist ? 'assets/icons/like.svg' : 'assets/icons/heart.svg',
                        color: isWishlist ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(CardStyle.contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Rating Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:  GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,

                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,

                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Rating Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: flutterpads.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: flutterpads,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style:  GoogleFonts.spaceGrotesk(
                              color: flutterpads,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Features/Chips Section
                if (features != null && features.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features.map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          feature.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                if (features != null && features.isNotEmpty)
                  const SizedBox(height: 12),

                // Extra Info (for events)
                if (extraInfo != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        extraInfo,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                // Duration (for events)
                if (duration != null)
                  Text(
                    '${duration} ${duration == 1 ? 'hour' : 'hours'}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                // Bottom Row (Price and Reviews)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price Section
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (salePrice != null)
                            Text(
                              '\$$salePrice',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'from ',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,

                                  ),
                                ),
                                TextSpan(
                                  text: '\$$price',
                                  style:  GoogleFonts.spaceGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,

                                  ),
                                ),
                                if (priceSuffix.isNotEmpty)
                                  TextSpan(
                                    text: priceSuffix.tr,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,

                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reviews
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$reviewCount reviews'.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey.shade600,

                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reviewText,
                          style:  GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey,

                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}








// Helper function for login bottom sheet
void showLoginBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    builder: (context) => CustomBottomSheet(
      title: 'Log in to add to'.tr,
      content: 'wishlists'.tr,
      onCancel: () => Navigator.of(context).pop(),
      onLogin: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      },
    ),
  );
}