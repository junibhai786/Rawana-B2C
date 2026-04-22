import 'dart:developer';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/all_boat_vendor_model.dart';
import 'package:moonbnd/vendor/boat/boat_detail_webview.dart';
import 'package:moonbnd/vendor/boat/boat_one_screen.dart';
import 'package:moonbnd/vendor/boat/editboat/edit_boat_one_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageBoatScreen extends StatefulWidget {
  const ManageBoatScreen({super.key});

  @override
  State<ManageBoatScreen> createState() => _ManageBoatScreenState();
}

class _ManageBoatScreenState extends State<ManageBoatScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Provider.of<VendorBoatProvider>(context, listen: false)
        .fetchallboatvendor()
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
    final boatProvider = Provider.of<VendorBoatProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Boats'.tr,
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
                        "${'Showing'.tr} ${boatProvider.boatlists?.data?.length ?? 0} ${'Boats'.tr}"),
                  ),
                  boatProvider.boatlists?.data?.length == 0
                      ? Expanded(
                          child: Center(child: Text("No Boat Added Yet".tr)))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: boatProvider
                                .boatlists?.data?.length, // Example count
                            itemBuilder: (context, index) {
                              return HotelCard(
                                boat: boatProvider.boatlists?.data?[index],
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
                                  builder: (context) => AddNewBoatScreen()))
                          .then((value) {
                        if (value == "yes") {
                          setState(() {
                            isLoading = true;
                          });
                          Provider.of<VendorBoatProvider>(context,
                                  listen: false)
                              .fetchallboatvendor()
                              .then(
                            (value) {
                              setState(() {
                                isLoading = false;
                              });
                            },
                          );
                        }
                      });
                    },
                    text: 'Add Boat'.tr,
                  ),
                ],
              ),
            ),
    );
  }
}

// ignore: must_be_immutable
class HotelCard extends StatefulWidget {
  HotelCard({super.key, required this.boat});
  ABDatum? boat;

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _showDeleteConfirmation(
      BuildContext context, VendorBoatProvider boatProvider) {
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
                    'Boat Delete Permanently'.tr,
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
                      onPressed: () {
                        boatProvider
                            .deleteboatvendor(
                                id: widget.boat?.id.toString() ?? "")
                            .then(
                          (value) {
                            if (value == true) {
                              boatProvider.fetchallboatvendor();
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
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
    final boatProvider = Provider.of<VendorBoatProvider>(context, listen: true);

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
                    itemCount: widget.boat?.image?.split(',').length ?? 0,
                    itemBuilder: (context, index) {
                      final images = widget.boat?.image?.split(',') ?? [];
                      return Image.network(
                        images[index].trim(),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            width: double.infinity,
                            color: Colors.grey.shade200,
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
                  children: List.generate(
                      widget.boat?.image?.split(',').length ?? 0, (index) {
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
                        widget.boat?.id.toString() ?? "",
                        'boat',
                      );
                      boatProvider.fetchallboatvendor();

                      if (success == "Added to wishlist") {
                        setState(() {
                          widget.boat?.isInWishlist = true;
                        });
                      } else if (success == "Removed from wishlist") {
                        setState(() {
                          widget.boat?.isInWishlist = false;
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success)),
                      );
                    },
                    child: SvgPicture.asset(
                      widget.boat?.isInWishlist == true
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
                        _showDeleteConfirmation(context, boatProvider);
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
                        if (widget.boat?.status == 'publish') {
                          boatProvider
                              .hideboatvendor(
                                  id: widget.boat?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                boatProvider.fetchallboatvendor();
                              }
                            },
                          );
                        } else {
                          boatProvider
                              .publishboatvendor(
                                  id: widget.boat?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                boatProvider.fetchallboatvendor();
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
                              color: widget.boat?.status == 'publish'
                                  ? AppColors.secondary
                                  : Colors.grey),
                          child: Icon(
                              widget.boat?.status == 'publish'
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
              // ignore: unrelated_type_equality_checks
              // widget.boat?.discountPercent != 0
              //     ? Positioned(
              //         bottom: 12,
              //         right: 12,
              //         child: Container(
              //             padding:
              //                 EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //             decoration: BoxDecoration(
              //               color: Colors.red,
              //               borderRadius: BorderRadius.circular(5),
              //             ),
              //             child: Text(
              //               '${widget.boat?.discountPercent}  OFF'.tr,
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 12,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             )),
              //       )
              //     : SizedBox.shrink(),
            ],
          ),
          Container(
            width: 300,
            // decoration: BoxDecoration(border: Border.all()),
            padding: const EdgeInsets.all(8.0),
            child: Text('${widget.boat?.title}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text('${'Location:'.tr} ${widget.boat?.location?.name}'),
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
                Text('${widget.boat?.price}',
                    style: TextStyle(
                      color: Colors.black,
                    )),
                SizedBox(width: 8),
                // ignore: unrelated_type_equality_checks
                // widget.boat?.discountPercent != 0
                //     ? Text('\$${widget.boat?.salePrice}',
                //         style: TextStyle(color: Colors.black))
                //     : SizedBox.shrink(),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide.none),
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 20.0),
                      ),
                      child: Text(' ${widget.boat?.status}',
                          style: TextStyle(color: Colors.white)))
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                '${'Last Updated:'.tr} ${formatTimestamp(widget.boat?.updatedAt)}'),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoatDetailWebView(
                        url: "${widget.boat?.detailsUrl}",
                      ),
                    ),
                  );
                },
                child: Text('View'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  boatProvider
                      .cloneboatvendor(id: widget.boat?.id.toString() ?? "")
                      .then(
                    (value) {
                      if (value == true) {
                        boatProvider.fetchallboatvendor();
                      }
                    },
                  );
                },
                child: Text('Clone'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              TextButton(
                // onPressed: () {
                //   // Navigate  homeProvider
                //   boatProvider
                //       .fetchallboatdetailvendor(widget.boat!.id.toString())
                //       .then((value) {
                //     if (value == "yes") {
                //       setState(() {
                //         isLoading = true;
                //       });
                //       Provider.of<VendorBoatProvider>(context, listen: false)
                //           .fetchallboatvendor()
                //           .then(
                //         (value) {
                //           setState(() {
                //             isLoading = false;
                //           });
                //         },
                //       );
                //     }
                //   });
                // },
                onPressed: () {
                  // Navigate  homeProvider
                  boatProvider
                      .fetchallboatdetailvendor(widget.boat!.id.toString())
                      .then((value) {
                    print("value of titile = ${value}");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBoatOneScreen(
                          id: widget.boat?.id.toString() ?? '',
                          data: value,
                        ),
                      ),
                    );
                  }).catchError((error) {
                    print("Error fetching hotel details: $error");
                  });
                },
                child: Text('Edit'.tr),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
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
                  log('${widget.boat?.availability_url}');
                  // ignore: deprecated_member_use
                  await launch(widget.boat?.availability_url ?? "");
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
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
