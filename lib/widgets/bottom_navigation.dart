
// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moonbnd/screens/price/pricing_screen.dart';
import 'package:provider/provider.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../constants.dart';
import 'package:get/get.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    WishlistScreen(),
    if (enableMyPlain) PricingPackagesScreen(),
    AccountScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('Selected index: $index');
    });
  }

  @override
  void initState() {
    super.initState();
    getFCMToken();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmTokenInput = await messaging.getToken();

    if (fcmTokenInput != null) {
      Provider.of<HomeProvider>(context, listen: false)
          .saveFcmToken(fcmToken: fcmTokenInput, platform: 'android');
    } else {
      log("Failed to get FCM Token");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        // Positioning: 25px from left, 20px from bottom (since top: 767px suggests bottom positioning)
        margin: EdgeInsets.only(
          left: 25,
          right: 25,
          bottom: 20, // Approximating from top: 767px
        ),
        // Fixed width and height
        width: 344,
        height: 75,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100), // 100px border radius
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8.0,
              sigmaY: 8.0,
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                // Equal spacing with gaps
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Explore Tab - with gap
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 5), // Half of 10px gap
                      child: _buildNavItem(
                        index: 0,
                        icon: 'assets/icons/bottom_search.svg',
                        activeIcon: 'assets/icons/search_filled.svg',
                        label: 'Explore'.tr,
                      ),
                    ),
                  ),

                  // Wishlist Tab - with gaps on both sides
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5), // 10px total gap
                      child: _buildNavItem(
                        index: 1,
                        icon: 'assets/icons/img.svg',
                        activeIcon: 'assets/icons/img.svg',
                        label: 'Wishlist'.tr,
                      ),
                    ),
                  ),

                  // My Plans Tab (Conditional) - with gaps
                  if (enableMyPlain)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5), // 10px total gap
                        child: _buildNavItem(
                          index: 2,
                          icon: 'assets/icons/home_profile.svg',
                          activeIcon: 'assets/icons/home_profile.svg',
                          label: 'My Plans'.tr,
                        ),
                      ),
                    ),

                  // Profile Tab - with gap
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 5), // Half of 10px gap
                      child: _buildNavItem(
                        index: enableMyPlain ? 3 : 2,
                        icon: 'assets/icons/profile_icon.svg',
                        activeIcon: 'assets/icons/profile_filled.svg',
                        label: 'Profile'.tr,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String activeIcon,
    required String label,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with circular background when selected
          SvgPicture.asset(
            isSelected ? activeIcon : icon,
            colorFilter: ColorFilter.mode(
              isSelected ? kSecondaryColor : Color(0xff65758B),
              BlendMode.srcIn,
            ),
            height: 22,
            width: 22,
          ),
          SizedBox(height: 4),
          // Label
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? kSecondaryColor : Colors.grey[700]!.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}








// // ignore_for_file: prefer_const_constructors
//
// import 'dart:developer';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:moonbnd/Provider/home_provider.dart';
// import 'package:moonbnd/screens/home/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:moonbnd/screens/price/pricing_screen.dart';
// import 'package:provider/provider.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/wishlist/wishlist_screen.dart';
// import '../constants.dart';
// import 'package:get/get.dart';
//
// //Fixed type Bottom Navigation Bar, contains icon, badge and label.
//
// class BottomNav extends StatefulWidget {
//   const BottomNav({super.key, this.initialIndex = 0});
//   final int initialIndex;
//
//   @override
//   State<BottomNav> createState() => _BottomNavState();
// }
//
// class _BottomNavState extends State<BottomNav> {
//   int _selectedIndex = 0;
//
//   static const List<Widget> _widgetOptions = <Widget>[
//     HomeScreen(),
//     WishlistScreen(),
//     if (enableMyPlain) PricingPackagesScreen(),
//     AccountScreen()
//   ];
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       print('Selected index: $index');
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getFCMToken();
//     _selectedIndex = widget.initialIndex;
//   }
//
//   Future<void> getFCMToken() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     String? fcmTokenInput = await messaging.getToken();
//
//     if (fcmTokenInput != null) {
//       Provider.of<HomeProvider>(context, listen: false)
//           .saveFcmToken(fcmToken: fcmTokenInput, platform: 'android');
//     } else {
//       log("Failed to get FCM Token");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//         child: BottomNavigationBar(
//           items: <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icons/bottom_search.svg',
//               ),
//               activeIcon: SvgPicture.asset(
//                 'assets/icons/search_filled.svg',
//               ),
//               label: 'Explore'.tr,
//             ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icons/bottom_wishlist.svg',
//               ),
//               activeIcon: SvgPicture.asset(
//                 'assets/icons/heart_filled.svg',
//               ),
//               label: 'Wishlists'.tr,
//             ),
//             if (enableMyPlain)
//               BottomNavigationBarItem(
//                 icon: SvgPicture.asset(
//                   'assets/icons/plan_icon.svg',
//                 ),
//                 activeIcon: SvgPicture.asset(
//                   'assets/icons/plan_filled.svg',
//                 ),
//                 label: 'My Plans'.tr,
//               ),
//             BottomNavigationBarItem(
//               icon: SvgPicture.asset(
//                 'assets/icons/profile_icon.svg',
//               ),
//               activeIcon: SvgPicture.asset(
//                 'assets/icons/profile_filled.svg',
//               ),
//               label: 'Profile'.tr,
//             ),
//           ],
//           iconSize: 24,
//           currentIndex: _selectedIndex,
//           selectedItemColor: kSecondaryColor,
//           unselectedItemColor: grey,
//           onTap: _onItemTapped,
//           selectedFontSize: 10,
//           unselectedFontSize: 10,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: kBackgroundColor,
//         ),
//       ),
//     );
//   }
// }
