// ignore_for_file: prefer_const_constructors

import 'dart:developer';

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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: kBorderColor, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: 'assets/icons/bottom_search.svg',
                  activeIcon: 'assets/icons/search_filled.svg',
                  label: 'Explore'.tr,
                ),
                _buildNavItem(
                  index: 1,
                  icon: 'assets/icons/img.svg',
                  activeIcon: 'assets/icons/img.svg',
                  label: 'Wishlist'.tr,
                ),
                if (enableMyPlain)
                  _buildNavItem(
                    index: 2,
                    icon: 'assets/icons/home_profile.svg',
                    activeIcon: 'assets/icons/home_profile.svg',
                    label: 'My Plans'.tr,
                  ),
                _buildNavItem(
                  index: enableMyPlain ? 3 : 2,
                  icon: 'assets/icons/profile_icon.svg',
                  activeIcon: 'assets/icons/profile_filled.svg',
                  label: 'Profile'.tr,
                ),
              ],
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
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? activeIcon : icon,
              colorFilter: ColorFilter.mode(
                isSelected ? kPrimaryColor : kNavInactiveColor,
                BlendMode.srcIn,
              ),
              height: 22,
              width: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? kPrimaryColor : kNavInactiveColor,
                height: 1.2,
              ),
            ),
          ],
        ),
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
