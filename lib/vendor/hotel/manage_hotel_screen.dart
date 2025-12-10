import 'dart:developer';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/all_hotel_vendor_model.dart';
import 'package:moonbnd/vendor/hotel/add_hotel_screen.dart';
import 'package:moonbnd/vendor/hotel/edit/hotel_edit_one_screen.dart';
import 'package:moonbnd/vendor/hotel/hotel_detail_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Provider/hotel_provider.dart';

class ManageHotelScreen extends StatefulWidget {
  const ManageHotelScreen({super.key});

  @override
  State<ManageHotelScreen> createState() => _ManageHotelScreenState();
}

class _ManageHotelScreenState extends State<ManageHotelScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Provider.of<VendorHotelProvider>(context, listen: false)
        .fetchallhotelvendor()
        .then(
      (value) {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider =
        Provider.of<VendorHotelProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Hotels'.tr,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... existing code ...
          /*Padding(
            padding: const EdgeInsets.only(left: 18,bottom: 10),
            child: Text("Showing 10 out of 20 Hotels"),
          ),*/
          Expanded(
            child: ListView.builder(
              itemCount: homeProvider.hotellists?.data?.length, // Example count
              itemBuilder: (context, index) {
                return HotelCard(
                  hotel: homeProvider.hotellists?.data?[index],
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddNewHotelScreen()),
                  ); // Add hotel action
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.black, // Border color
                      width: 1, // Border width
                    ),
                    // Rounded corners
                  ),
                  elevation: 5, // Shadow elevation
                  backgroundColor: Colors.white, // Background color
                  foregroundColor: Colors.black, // Text color
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Add Hotel'.tr,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class HotelCard extends StatefulWidget {
  HotelCard({super.key, required this.hotel});
  HDatum? hotel;

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _showDeleteConfirmation(
      BuildContext context, VendorHotelProvider homeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Are you sure?'.tr,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: kPrimaryColor,
                        fontFamily: 'Inter'.tr),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Hotel Delete Permanently'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: kPrimaryColor,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: flutterpads),
                        foregroundColor: flutterpads,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => homeProvider
                          .deletehotelvendor(
                              id: widget.hotel?.id.toString() ?? "")
                          .then((value) {
                        if (value == true) {
                          homeProvider.fetchallhotelvendor();
                          Navigator.pop(context);
                        }
                      }),
                      child: Text('Delete'.tr),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return "Unknown"; // Handle null timestamps
    }
    try {
      String formattedDate = DateFormat('MM/dd/yyyy HH:mm').format(timestamp);
      return formattedDate;
    } catch (e) {
      return "Invalid Date"; // Handle unexpected errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider =
        Provider.of<VendorHotelProvider>(context, listen: true);

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.hotel?.gallery?.length ??
                        0, // Count of gallery images
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewScreen(
                                appbartitle: "Hotel Details",
                                url: "${widget.hotel?.detailsUrl}",
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Image.network(
                            widget.hotel?.gallery?[index] ??
                                '', // Load image from URL
                            height: 260,
                            width: double.infinity,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                width: double.infinity,
                                color: Colors
                                    .grey.shade200, // Fallback background color
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
              ),
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.hotel?.gallery?.length ?? 0,
                      (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index ? kSecondaryColor : Colors.white,
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                  top: 12,
                  left: 20,
                  child: InkWell(
                    onTap: () async {
                      final userhomeProvider =
                          Provider.of<HomeProvider>(context, listen: false);
                      final success = await userhomeProvider.addToWishlist(
                        widget.hotel?.id.toString() ?? "",
                        'hotel',
                      );
                      homeProvider.fetchallhotelvendor();

                      if (success == "Added to wishlist") {
                        setState(() {
                          widget.hotel?.isInWishlist = true;
                        });
                      } else if (success == "Removed from wishlist") {
                        setState(() {
                          widget.hotel?.isInWishlist = false;
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success)),
                      );
                    },
                    child: SvgPicture.asset(
                      widget.hotel?.isInWishlist == true
                          ? 'assets/icons/like.svg'
                          : 'assets/icons/heart.svg',
                      width: 24,
                      height: 20,
                    ),
                  )),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _showDeleteConfirmation(context, homeProvider);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.red),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.hotel?.status == 'publish') {
                          homeProvider
                              .hidehotelvendor(
                                  id: widget.hotel?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                homeProvider.fetchallhotelvendor();
                              }
                            },
                          );
                        } else {
                          homeProvider
                              .publishhotelvendor(
                                  id: widget.hotel?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                homeProvider.fetchallhotelvendor();
                              }
                            },
                          );
                        }
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: widget.hotel?.status == 'publish'
                                  ? Colors.green
                                  : Colors.grey),
                          child: Icon(
                              widget.hotel?.status == 'publish'
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(8.0),
            child: Text('${widget.hotel?.title}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text(
              '${'Location:'.tr} ${widget.hotel?.location?.name ?? ''}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text(
              '${'Price:'.tr} \$${widget.hotel?.price}',
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text('Status:'.tr, style: TextStyle(color: Colors.green)),
                  SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        /* homeProvider
                            .publishhotelvendor(
                                id: widget.hotel?.id.toString() ?? "")
                            .then(
                          (value) {
                            if (value == true) {
                              homeProvider.fetchallhotelvendor();
                            }
                          },
                        );*/
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                            side: BorderSide.none),
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                      ),
                      child: Text(' ${widget.hotel?.status}'.tr,
                          style: TextStyle(color: Colors.white)))
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${'Last Updated:'.tr} ${formatTimestamp(widget.hotel?.updatedAt)}',
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        appbartitle: "Hotel Details".tr,
                        url: "${widget.hotel?.detailsUrl}",
                      ),
                    ),
                  );
                },
                child: Text('View'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF17A2B8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  homeProvider
                      .clonehotelvendor(id: widget.hotel?.id.toString() ?? "")
                      .then(
                    (value) {
                      if (value == true) {
                        homeProvider.fetchallhotelvendor();
                      }
                    },
                  );
                },
                child: Text('Clone'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF1A2B47),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditHotelScreen(id: "${widget.hotel?.id}")));

                  /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHotelScreen(


                          */ /*title: value[0].title,
                          content: value[0].content,
                          youtubeVideo: value[0].video,
                          bannerimage: value[0].bannerImage,
                          galaryimage: value[0].gallery,
                          starrate:  value[0].starRate,
                          featuredImage: value[0].image,

                          locationid: value[0].location.id??0,
                          policys:value[0].policy,
                          address: value[0].address,
                          maplatitude: value[0].mapLat,
                          maplongitude: value[0].mapLng,
                          checkintime: value[0].checkInTime,
                          checkouttime: value[0].checkOutTime,
                          minreservation:value[0].minDayBeforeBooking.toString(),
                          minreq: value[0].minDayStays.toString(),
                          price: value[0].price,
                          extraprice: value[0].extraPrice,
                          terms: value[0].terms,*/ /*
                          id: widget.hotel?.id.toString()??"",
                         */ /* data: value,*/ /*



                        ),
                      ),
                    );*/
                  /* }).catchError((error) {

                    print("Error fetching hotel details: $error");
                  });*/
                },
                child: Text('Edit'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  log('${widget.hotel?.availablility}');
                  // ignore: deprecated_member_use
                  await launch(widget.hotel?.availablility ?? "");
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF1A2B47),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 41, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/available.svg',
                    ),
                    SizedBox(width: 10),
                    Text('Availability'.tr),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
