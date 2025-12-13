// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/language/language_controller.dart';
import 'package:moonbnd/screens/auth/login_secuirty_screen.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/screens/manage%20coupon/all_manage_coupon_screen.dart';
import 'package:moonbnd/screens/profile/edit_profile.dart';
import 'package:moonbnd/screens/profile/update_verification.dart';
import 'package:moonbnd/vendor/boat/mange_boat_screen.dart';
import 'package:moonbnd/vendor/car/managecarscreen.dart';
import 'package:moonbnd/vendor/credit/wallet.dart';
import 'package:moonbnd/vendor/event/all_event_screen.dart';

import 'package:moonbnd/vendor/flight/manage_all_flight_screen.dart';
import 'package:moonbnd/vendor/hotel/manage_hotel_screen.dart';
import 'package:moonbnd/vendor/space/all_space_screen.dart';
import 'package:moonbnd/vendor/tour/manage_tour_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../notification/notifications_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              // Main content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40), // Space for the close button
                  Text(
                    'Are you sure you want to logout?'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 140,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: flutterpads),
                            foregroundColor: flutterpads,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            bool rememberMee =
                                prefs.getBool('remember_me') ?? false;
                            String email = prefs.getString('email') ?? '';
                            String password = prefs.getString('password') ?? '';

                            await prefs.clear();
                            prefs.setBool('remember_me', rememberMee);
                            prefs.setString('email', email);
                            prefs.setString('password', password);

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) {
                                  return SignInScreen();
                                },
                              ),
                              (route) => false,
                            );
                          },
                          child: Text('Log Out'.tr, style: GoogleFonts.spaceGrotesk(color: Colors.black,fontWeight: FontWeight.w500),),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'.tr,style: GoogleFonts.spaceGrotesk(color: Colors.white,fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Close button
              // Positioned(
              //   top: 0,
              //   right: 0,
              //   child: IconButton(
              //     icon: const Icon(Icons.close),
              //     onPressed: () => Navigator.pop(context),
              //     tooltip: 'Close'.tr,
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  String? token;
  bool isLoadingToken = true;
  @override
  void initState() {
    super.initState();

    Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchunreadnotificationcount()
        .then((value) {
      setState(() {});
    });
    _getToken();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('userToken');
      isLoadingToken = false;
    });
  }

  /*Future<void> _refreshData() async {
    // Call your data fetching methods here
    await Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchunreadnotificationcount();

    // Add any other data fetching logic you need
  }*/
  Future<void> _refreshData() async {
    await Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchunreadnotificationcount();
    await Provider.of<VendorAuthProvider>(context, listen: false).getMe();
  }

  // bool _isExpanded = false;
  // bool _isExpandedForSpace = false;
  final LanguageController languageController = Get.find<LanguageController>();
  late String currentLanguage =
      Get.locale?.languageCode == 'ar' ? 'Arabic' : 'English';
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);
    final provider2 = Provider.of<VendorAuthProvider>(context, listen: true);

    log("${provider.myProfile?.data?.avatarUrl} avatarurl");

    log("${Platform.localeName} language");

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: token == null
            ? SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile".tr,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Log in to start planning!".tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TertiaryButton(
                            text: "Log in".tr,
                            press: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => SignInScreen()),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              )
            : SafeArea(
                child: ListView(
                    children: [
                         Container(
                           color: Color(0xff05A8C7),
                           child: Column(
                             children: [
                               Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 20),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text(
                                       "Profile".tr,
                                       style: GoogleFonts.spaceGrotesk(
                                         fontWeight: FontWeight.w400,
                                         color: Colors.white,
                                         fontSize: 24,

                                       )
                                     ),

                                   ],
                                 ),
                               ),
                               const SizedBox(height: 15),

                               // Show profile
                               Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 20),
                                 child: InkWell(
                                   onTap: () {},
                                   child: Row(
                                     children: [
                                       Container(
                                         padding: EdgeInsets.all(2),
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           border: Border.all(color: kColor1, width: 1),
                                         ),
                                         child: CircleAvatar(
                                           backgroundImage: provider.myProfile?.data?.avatarUrl != null
                                               ? NetworkImage(provider.myProfile!.data!.avatarUrl!)
                                               : const AssetImage("assets/haven/avatar_6.jpg")
                                           as ImageProvider<Object>,
                                           radius: 30,
                                         ),
                                       ),
                                       SizedBox(width: 12),
                                       Flexible(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.stretch,
                                           children: [
                                             Row(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     Text(
                                                       provider.myProfile?.data?.name?.tr ?? "",
                                                       style: GoogleFonts.spaceGrotesk(
                                                         fontWeight: FontWeight.w400,
                                                         color: Colors.white,
                                                         fontSize: 16
                                                       )
                                                     ),
                                                     SizedBox(height: 2),


                                                     Padding(
                                                       padding: const EdgeInsets.all(6.0),
                                                       child: Text(
                                                         provider.myProfile?.data!.phone??'',

                                                         style: GoogleFonts.spaceGrotesk(
                                                           fontWeight: FontWeight.w400,
                                                           color: Colors.white,
                                                         )
                                                       ),
                                                     )
                                                   ],
                                                 ),
                                                 SizedBox(width: 10),
                                                 Image.asset('assets/haven/verified.png'),
                                                 SizedBox(width: 4),
                                               ],
                                             ),
                                           ],
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),

                               const SizedBox(height: 14),
                             ],
                           ),
                         ),

                         const SizedBox(
                           height: 12,
                         ),
                         provider.myProfile?.status == 0
                             ? SizedBox()
                             : Padding(
                                 padding: const EdgeInsets.only(left: 20, right: 20),
                                 child: InkWell(
                                   onTap: () {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                           builder: (context) => BottomNav()),
                                     );
                                     provider2.becomevendor().then((value) {
                                       if (value == true) {
                                         provider.getMe();
                                       }
                                     });
                                   },
                                   child: Padding(
                                     padding: const EdgeInsets.only(bottom: 20),
                                     child: Container(
                                       decoration: BoxDecoration(
                                         color: kBackgroundColor,
                                         borderRadius: BorderRadius.circular(10),
                                         boxShadow: [
                                           BoxShadow(
                                               color: Colors.grey.shade400,
                                               blurRadius: 5),
                                         ],
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.all(16),
                                         child: Row(
                                           children: [
                                             Expanded(
                                               child: Column(
                                                 crossAxisAlignment:
                                                     CrossAxisAlignment.stretch,
                                                 children: [
                                                   Text(
                                                     "Become a Vendor".tr,
                                                     style: GoogleFonts.spaceGrotesk(
                                                       color: Colors.black,
                                                       fontWeight: FontWeight.w500,
                                                       fontSize: 16
                                                     )
                                                   ),
                                                   SizedBox(
                                                     height: 8,
                                                   ),
                                                   Text(
                                                     "Join our community to unlock your greatest asset."
                                                         .tr,
                                                     style: GoogleFonts.spaceGrotesk(
                                                         color: Color(0xff65758B),
                                                         fontWeight: FontWeight.w400,
                                                         fontSize: 12
                                                     ))
                                                 ],
                                               ),
                                             ),

                                             //home image
                                             Image.asset(
                                               "assets/haven/vendor.png",
                                               width: 84,
                                             )
                                           ],
                                         ),
                                       ),
                                     ),
                                   ),
                                 ),
                               ),
                         SettingItem(
                           showDropdown: true,
                           press: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => EditProfile()),
                             );
                           },
                           kIcon: 'assets/icons/profile.svg',
                           title: 'My Profile'.tr,
                         ),
                         SettingItem(
                           showDropdown: true,
                           press: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => WalletScreen()),
                             );
                           },
                           kIcon: 'assets/icons/iconoir_wallet.svg',
                           title: 'Wallet'.tr,
                         ),
                         SettingItem(
                           showDropdown: true,
                           press: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => BookingHistoryScreen()),
                             );
                           },
                           kIcon: 'assets/icons/history.svg',
                           title: 'Booking History'.tr,
                         ),

                         SettingItem(
                           showDropdown: true,
                           press: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) => LoginSecurityScreen()),
                             );
                           },
                           kIcon: 'assets/icons/Lock.svg',
                           title: 'Login and Security'.tr,
                         ),
                         SettingItem(
                           showDropdown: true,
                           press: () {
                             _showLanguageBottomSheet(context);
                           },
                           kIcon: 'assets/icons/language.svg',
                           title: 'Preferred Language'.tr,
                         ),
                         SettingItem(
                           showDropdown: true,
                           press: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                   builder: (context) =>
                                       UpdateVerificationDataScreen()),
                             );
                           },
                           kIcon: 'assets/icons/Handshake.svg',
                           title: 'Verification Status'.tr,
                         ),

                         SizedBox(height: 5),
                         provider.myProfile?.status == 0
                             ? Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Padding(
                                     padding:
                                         const EdgeInsets.only(left: 20, top: 10),
                                     child: Text(
                                       "Hosting".tr,
                                       style: TextStyle(
                                         fontSize: 20,
                                         fontFamily: 'Inter'.tr,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                   ),
                                   if(enableHotel)
                                   SettingItem(
                                     showDropdown: true,
                                     press: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) =>
                                                 ManageHotelScreen()),
                                       );
                                     },
                                     kIcon: 'assets/haven/Hotel.svg',
                                     title: 'Manage Hotel'.tr,
                                   ),
                                   if(enableTour)
                                   SettingItem(
                                     showDropdown: true,
                                     press: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) =>
                                                 ManageTourScreen()),
                                       );
                                     },
                                     kIcon: 'assets/icons/managetour.svg',
                                     title: 'Manage Tour'.tr,
                                   ),
                                   if(enableSpace)
                                   GestureDetector(
                                     onTap: () {},
                                     child: SettingItem(
                                       showDropdown: true,
                                       press: () {
                                         Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                               builder: (context) =>
                                                   AllSpaceScreen()),
                                         );
                                       },
                                       kIcon: 'assets/icons/space.svg',
                                       title: 'Manage Space'.tr,
                                     ),
                                   ),
                                   if(enableFlight)
                                   SettingItem(
                                     showDropdown: true,
                                     press: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) =>
                                                 ManageAllFlightScreen()),
                                       );
                                     },
                                     kIcon: 'assets/icons/plane.svg',
                                     title: 'Manage Flight'.tr,
                                   ),
                                   if(enableCar)
                                   GestureDetector(
                                     onTap: () {},
                                     child: SettingItem(
                                       showDropdown: true,
                                       press: () {
                                         Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                               builder: (context) =>
                                                   ManageCarScreen()),
                                         );
                                       },
                                       kIcon: 'assets/icons/managecar.svg',
                                       title: 'Manage Car'.tr,
                                     ),
                                   ),
                                   if(enableBoat)
                                   SettingItem(
                                     showDropdown: true,
                                     press: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) =>
                                                 ManageBoatScreen()),
                                       );
                                     },
                                     kIcon: 'assets/icons/boat.svg',
                                     title: 'Manage Boat'.tr,
                                   ),
                                   if(enableEvent)
                                   SettingItem(
                                     showDropdown: true,
                                     press: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) => AllEventScreen()),
                                       );
                                     },
                                     kIcon: 'assets/icons/event.svg',
                                     title: 'Manage Event'.tr,
                                   ),
                                   SettingItem(
                                     showDropdown: true,
                                     press: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) =>
                                                 AllManageCouponScreen()),
                                       );
                                     },
                                     kIcon: 'assets/icons/managecoupon.svg',
                                     title: 'Manage Coupon'.tr,
                                   ),
                                 ],
                               )
                             : SizedBox(),
                         Divider(),
                         SettingItem(
                           showDropdown: true,
                           press: () async {
                             _showLogoutConfirmation(context);
                             // Navigator.of(context).push(MaterialPageRoute(
                             //   builder: (context) {
                             //     return DemoScreen();
                             //   },
                             // ));
                           },
                           kIcon: 'assets/icons/logout.svg',
                           title: 'Logout'.tr,
                         ),
                         SizedBox(height: 8),
                         Center(
                           child: Text(
                             '${'Version:'.tr} 1.0',
                             style: TextStyle(
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontFamily: 'Inter',
                                 fontWeight: FontWeight.w400),
                           ),
                         ),
                         SizedBox(height: 8),
              ])),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Language'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('English'.tr),
                  trailing: currentLanguage == 'English'
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: currentLanguage == 'English'
                            ? Colors.grey
                            : Colors.transparent,
                        width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    setState(() {
                      currentLanguage = 'English';
                      languageController.changeLanguage('en');
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Arabic'.tr),
                  trailing: currentLanguage == 'Arabic'
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: currentLanguage == 'Arabic'
                            ? Colors.grey
                            : Colors.transparent,
                        width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    setState(() {
                      currentLanguage = 'Arabic';
                      languageController.changeLanguage('ar');
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//setting item widget

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.press,
    required this.kIcon,
    required this.title,
    this.showDropdown = false,
  });

  final VoidCallback press;
  final String kIcon;
  final String title;
  final bool showDropdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero, // keeps spacing same as before
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // keeps same look as Container
        ),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: press,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // icon + title
                        Row(
                          children: [
                            SvgPicture.asset(kIcon),
                            const SizedBox(width: 16),

                            Text(
                              title,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        if (showDropdown)
                          Icon(Icons.arrow_forward_ios_rounded, size: 20),
                      ],
                    ),
                  ),
                ),

                Divider(
                  height: 4,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

