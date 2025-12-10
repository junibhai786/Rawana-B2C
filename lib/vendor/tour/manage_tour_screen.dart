// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/all_tour_vendor_model.dart';
import 'package:moonbnd/vendor/tour/edittour/edit_tour_one_screen.dart';
import 'package:moonbnd/vendor/tour/tour_detail_webview.dart';
import 'package:moonbnd/vendor/tour/tour_one_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageTourScreen extends StatefulWidget {
  const ManageTourScreen({super.key});

  @override
  State<ManageTourScreen> createState() => _ManageTourScreenState();
}

class _ManageTourScreenState extends State<ManageTourScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Provider.of<VendorTourProvider>(context, listen: false)
        .fetchalltourvendor()
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
    final tourProvider = Provider.of<VendorTourProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Tour'.tr,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18, bottom: 10),
                    child: Text(
                      '${'Showing'.tr} ${tourProvider.tourlists?.data?.length ?? 0} ${'Tours'.tr}',
                    ),
                  ),
                  tourProvider.tourlists?.data?.length == 0
                      ? Expanded(
                          child: Center(child: Text("No Tour Added Yet".tr)))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: tourProvider
                                .tourlists?.data?.length, // Example count
                            itemBuilder: (context, index) {
                              return HotelCard(
                                tour: tourProvider.tourlists?.data?[index],
                              );
                            },
                          ),
                        ),
                  TextIconButtom(
                    textcolor: Colors.black,
                    borderColor: Colors.black,
                    backgroudcolour: Colors.white,
                    icon: Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    press: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TourOneScreen()))
                          .then((value) async {
                        if (value == "yes") {
                          await Provider.of<VendorTourProvider>(context,
                                  listen: false)
                              .fetchalltourvendor();
                        }
                      });
                    },
                    text: 'Add Tour'.tr,
                  ),
                ],
              ),
            ),
    );
  }
}

// ignore: must_be_immutable
class HotelCard extends StatefulWidget {
  HotelCard({super.key, required this.tour});
  TourDatum? tour;

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _showDeleteConfirmation(
      BuildContext context, VendorTourProvider tourProvider) {
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
                    'Tour Delete Permanently'.tr,
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
                      onPressed: () => tourProvider
                          .deletetourvendor(
                              id: widget.tour?.id.toString() ?? "")
                          .then(
                        (value) {
                          if (value == true) {
                            tourProvider.fetchalltourvendor();
                            Navigator.pop(context);
                          }
                        },
                      ),
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
    final tourProvider = Provider.of<VendorTourProvider>(context, listen: true);

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.tour?.gallery?.length ??
                        0, // Count of gallery images
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.tour?.gallery?[index] ??
                            '', // Load image from URL
                        height: 300,
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
                      );
                    }),
              ),
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      List.generate(widget.tour?.gallery?.length ?? 0, (index) {
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
                        widget.tour?.id.toString() ?? "",
                        'tour',
                      );
                      tourProvider.fetchalltourvendor();

                      if (success == "Added to wishlist") {
                        setState(() {
                          widget.tour?.isInWishlist = true;
                        });
                      } else if (success == "Removed from wishlist") {
                        setState(() {
                          widget.tour?.isInWishlist = false;
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success)),
                      );
                    },
                    child: SvgPicture.asset(
                      widget.tour?.isInWishlist == true
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
                        _showDeleteConfirmation(context, tourProvider);
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
                        if (widget.tour?.status == 'publish') {
                          tourProvider
                              .hidetourvendor(
                                  id: widget.tour?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                tourProvider.fetchalltourvendor();
                              }
                            },
                          );
                        } else {
                          tourProvider
                              .publishtourvendor(
                                  id: widget.tour?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                tourProvider.fetchalltourvendor();
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
                              color: widget.tour?.status == 'publish'
                                  ? Colors.green
                                  : Colors.grey),
                          child: Icon(
                              widget.tour?.status == 'publish'
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),

              ////
              widget.tour?.discountPercent != null &&
                      widget.tour?.discountPercent != 0
                  ? Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${widget.tour?.discountPercent} ${'OFF'.tr}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(8.0),
            child: Text('${widget.tour?.title}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text('${'Location:'.tr} ${widget.tour?.location?.name}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Row(
              children: [
                Text('Price:'.tr,
                    style: TextStyle(
                      color: Colors.black,
                    )),
                SizedBox(width: 4),
                Text('\$${widget.tour?.price}',
                    style: TextStyle(
                        color: widget.tour?.discountPercent != null &&
                                widget.tour?.discountPercent != 0
                            ? Colors.red
                            : Colors.black,
                        decoration: widget.tour?.discountPercent != null &&
                                widget.tour?.discountPercent != 0
                            ? TextDecoration.lineThrough
                            : TextDecoration.none)),
                SizedBox(width: 8),
                widget.tour?.discountPercent != 0 &&
                        widget.tour?.discountPercent != null
                    ? Text('\$${widget.tour?.salePrice}',
                        style: TextStyle(color: Colors.black))
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text('Status:'.tr, style: TextStyle(color: Colors.black)),
                  SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        tourProvider
                            .publishtourvendor(
                                id: widget.tour?.id.toString() ?? "")
                            .then(
                          (value) {
                            if (value == true) {
                              tourProvider.fetchalltourvendor();
                            }
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide.none),
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 20.0),
                      ),
                      child: Text(' ${widget.tour?.status}',
                          style: TextStyle(color: Colors.white)))
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                '${'Last Updated:'.tr} ${formatTimestamp(widget.tour?.updatedAt)}'),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TourDetailWebView(
                        url: "${widget.tour?.detailsUrl}",
                      ),
                    ),
                  );
                },
                child: Text('View'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF17A2B8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  tourProvider
                      .clonetourvendor(id: widget.tour?.id.toString() ?? "")
                      .then(
                    (value) {
                      if (value == true) {
                        tourProvider.fetchalltourvendor();
                      }
                    },
                  );
                },
                child: Text('Clone'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF1A2B47),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate  homeProvider
                  tourProvider
                      .fetchalltourdetailvendor(widget.tour!.id.toString())
                      .then((value) {
                    print("value of titile = ${value}");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTourOneScreen(
                          id: widget.tour?.id.toString() ?? '',
                        ),
                      ),
                    );
                  }).catchError((error) {
                    print("Error fetching hotel details: $error");
                  });
                },
                child: Text('Edit'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFFC107),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
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
                  log('${widget.tour?.availablility}');
                  // ignore: deprecated_member_use
                  await launch(widget.tour?.availablility ?? "");
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
