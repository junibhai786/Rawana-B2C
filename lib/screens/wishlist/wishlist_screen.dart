// ignore_for_file: prefer_const_constructors

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/boat/boat_detail_screen.dart';
import 'package:moonbnd/screens/car/car_details_screen.dart';
import 'package:moonbnd/screens/event/event_detail_screen.dart';
import 'package:moonbnd/screens/hotel/room_detail_screen.dart';
import 'package:moonbnd/screens/space/space_details_screen.dart';
import 'package:moonbnd/screens/tour/tour_details_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/data_models/wishlist_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool isEditMode = false;
  bool isLoading = false;
  bool isGuest = false; // Indicates if the user is not logged in
  WishlistResponse? wishlistItems;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if the token exists
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      if (token == null) {
        setState(() {
          isGuest = true;
        });
        return; // Exit the function if the user is not logged in
      }

      // Fetch wishlist if logged in
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final wishlistResponse = await homeProvider.fetchWishlist();

      if (wishlistResponse != null) {
        setState(() {
          wishlistItems = WishlistResponse(
            data: wishlistResponse.data,
            totalPages: wishlistResponse.totalPages,
            total: wishlistResponse.total,
          );
        });
      } else {
        // Handle the case when wishlist fetch fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch wishlist. Please try again.'.tr)),
        );
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.'.tr)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // AppBar with editable text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Wishlists".tr,
                              style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 18)),
                          if (!isGuest) // Show Edit button only if logged in
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isEditMode = !isEditMode;
                                });
                              },
                              child: Text(isEditMode ? 'Done'.tr : 'Edit'.tr,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w400,
                                  )),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Show "Login Required" if not logged in
                    if (isGuest)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Log in to view your wishlist.".tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
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
                    if (!isGuest && wishlistItems != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                          ),
                          itemCount: wishlistItems?.data.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return WishlistItemsss(
                              dataSrc: wishlistItems!.data[index],
                              isEditMode: isEditMode,
                              onDelete: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                final homeProvider = Provider.of<HomeProvider>(
                                    context,
                                    listen: false);
                                final success =
                                    await homeProvider.addToWishlist(
                                  wishlistItems!.data[index].objectId
                                      .toString(),
                                  wishlistItems!.data[index].objectModel
                                      .toString(),
                                );

                                if (success ==
                                    "Removed from wishlist successfully !") {
                                  wishlistItems!.data.removeWhere((test) {
                                    return test.id ==
                                        wishlistItems!.data[index].id;
                                  });
                                  setState(() {});
                                }
                                setState(() {
                                  isLoading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(success)),
                                );
                              },
                              press: () {
                                // Navigate to respective detail screens
                                if (wishlistItems?.data[index].objectModel ==
                                    "hotel") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RoomDetailScreen(
                                          hotelId: (wishlistItems
                                                      ?.data[index].objectId ??
                                                  '0')
                                              .toString()),
                                    ),
                                  );
                                } else if (wishlistItems
                                        ?.data[index].objectModel ==
                                    "tour") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TourPage(
                                          tourId: wishlistItems
                                                  ?.data[index].objectId ??
                                              1),
                                    ),
                                  );
                                } else if (wishlistItems
                                        ?.data[index].objectModel ==
                                    "space") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpacePage(
                                          spaceId: wishlistItems
                                                  ?.data[index].objectId ??
                                              1),
                                    ),
                                  );
                                } else if (wishlistItems
                                        ?.data[index].objectModel ==
                                    "car") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CarRentalDetailsScreen(
                                              carId: wishlistItems
                                                      ?.data[index].objectId ??
                                                  1),
                                    ),
                                  );
                                } else if (wishlistItems
                                        ?.data[index].objectModel ==
                                    "event") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventsDetailsScreen(
                                          eventId: wishlistItems
                                                  ?.data[index].objectId ??
                                              1),
                                    ),
                                  );
                                } else if (wishlistItems
                                        ?.data[index].objectModel ==
                                    "boat") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BoatDetailsScreen(
                                          boatId: wishlistItems
                                                  ?.data[index].objectId ??
                                              1),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
    );
  }
}

// Wishlist item with editable and deletable functionality
class WishlistItemsss extends StatelessWidget {
  const WishlistItemsss({
    super.key,
    required this.dataSrc,
    required this.isEditMode,
    required this.onDelete,
    required this.press,
  });

  final WishlistItem dataSrc;
  final bool isEditMode;
  final VoidCallback onDelete;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: press,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    dataSrc.service.image,
                    fit: BoxFit.cover,
                    height: 160,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                dataSrc.service.title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 4,
              ),
              // Text(
              //   "${dataSrc.wishlistAmount} saved",
              //   style: const TextStyle(
              //     color: kColor1,
              //     fontSize: 12,
              //   ),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
        ),
        if (isEditMode)
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: onDelete,
              child: SvgPicture.asset(
                'assets/icons/close_icon.svg',
              ),
            ),
          ),
      ],
    );
  }
}
