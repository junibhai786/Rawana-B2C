// ignore: unused_import
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/event_vendor_model.dart';
import 'package:moonbnd/vendor/event/edit/edit_event_screen_one.dart';
import 'package:moonbnd/vendor/event/event_one_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllEventScreen extends StatefulWidget {
  const AllEventScreen({super.key});

  @override
  State<AllEventScreen> createState() => _ManageCarScreenState();
}

class _ManageCarScreenState extends State<AllEventScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Provider.of<EventProvider>(context, listen: false)
        .fetchEventVendorDetails()
        .then(
      (value) {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  String formatTimestamp(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp);
    String formattedDate = DateFormat('MM/dd/yyyy HH:mm').format(parsedDate);
    return formattedDate;
  }

  // CarVendorModel? carList;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: true);
    // log("${homeProvider.carListvendorPerCategory.length} lengthlength");
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage Event'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 20),
                  eventProvider.eventVendor?.data.length == 0
                      ? Expanded(
                          child: Center(child: Text("No Event Added Yet".tr)))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: eventProvider
                                .eventVendor?.data.length, // Example count
                            itemBuilder: (context, index) {
                              return HotelCard(
                                eventSingle:
                                    eventProvider.eventVendor?.data[index],
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
                                  builder: (context) => EventOneScreen()))
                          .then((vlue) {
                        if (vlue == "yes") {
                          setState(() {
                            isLoading = true;
                          });
                          Provider.of<EventProvider>(context, listen: false)
                              .fetchEventVendorDetails()
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
                    text: 'Add Event'.tr,
                  ),
                ],
              ),
            ),
    );
  }
}

// ignore: must_be_immutable
class HotelCard extends StatefulWidget {
  HotelCard({super.key, required this.eventSingle});
  EventForVendor? eventSingle;

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _showDeleteConfirmation(
      BuildContext context, EventProvider eventProvider) {
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
                    'Event Delete Permanently'.tr,
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
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        eventProvider
                            .deleteVendorEvent(
                                id: widget.eventSingle?.id.toString() ?? "")
                            .then(
                          (value) async {
                            if (value == true) {
                              await eventProvider.fetchEventVendorDetails();
                              Navigator.pop(context);
                            }
                          },
                        ).then((value) {
                          setState(() {
                            isLoading = false;
                          });
                        });
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
    final eventProvider = Provider.of<EventProvider>(context, listen: true);

    return Card(
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
                    itemCount: widget.eventSingle?.gallery.length ??
                        0, // Count of gallery images
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.eventSingle?.gallery[index] ??
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
                  children: List.generate(
                      widget.eventSingle?.gallery.length ?? 0, (index) {
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
                        widget.eventSingle?.id.toString() ?? "",
                        'event',
                      );
                      eventProvider.fetchEventVendorDetails();

                      if (success == "Added to wishlist") {
                        setState(() {
                          widget.eventSingle?.isInWishlist = true;
                        });
                      } else if (success == "Removed from wishlist") {
                        setState(() {
                          widget.eventSingle?.isInWishlist = false;
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success)),
                      );
                    },
                    child: SvgPicture.asset(
                      widget.eventSingle?.isInWishlist == true
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
                        _showDeleteConfirmation(context, eventProvider);
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
                        if (widget.eventSingle?.status == 'publish') {
                          eventProvider
                              .hideEventVendor(
                                  id: widget.eventSingle?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                eventProvider.fetchEventVendorDetails();
                              }
                            },
                          );
                        } else {
                          eventProvider
                              .publishEventVendor(
                                  id: widget.eventSingle?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                eventProvider.fetchEventVendorDetails();
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
                              color: widget.eventSingle?.status == 'publish'
                                  ? AppColors.secondary
                                  : Colors.grey),
                          child: Icon(
                              widget.eventSingle?.status == 'publish'
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
              widget.eventSingle?.discountPercent != '0'
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
                            '${widget.eventSingle?.discountPercent}',
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
            child: Text('${widget.eventSingle?.title}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child:
                Text('${'Location:'.tr} ${widget.eventSingle?.location.name}'),
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
                if (widget.eventSingle?.salePrice != 0)
                  Text('${widget.eventSingle?.salePrice}',
                      style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough)),
                SizedBox(width: 8),
                widget.eventSingle?.discountPercent != '0'
                    ? Text('\$${widget.eventSingle?.price}',
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
                        // eventProvider
                        //     .cloneEventVendor(
                        //         widget.eventSingle?.id.toString() ?? "")
                        //     .then(
                        //   (value) {
                        //     if (value == true) {
                        //       eventProvider.fetchEventVendorDetails();
                        //     }
                        //   },
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide.none),
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 20.0),
                      ),
                      child: Text(' ${widget.eventSingle?.status}',
                          style: TextStyle(color: Colors.white)))
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                '${'Last Updated:'.tr} ${formatTimestamp(DateTime.parse(widget.eventSingle?.updatedAt ?? ""))}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    if (widget.eventSingle?.detailsUrl != null) {
                      launchUrl(Uri.parse(widget.eventSingle!.detailsUrl));
                    }
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
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    eventProvider
                        .cloneEventVendor(
                            widget.eventSingle?.id.toString() ?? "")
                        .then(
                      (value) async {
                        if (value == true) {
                          await eventProvider.fetchEventVendorDetails();
                        }
                      },
                    ).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                    });
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
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventEditOneScreen(
                                    id: "${widget.eventSingle?.id}")))
                        .then((value) {
                      if (value == "yes") {
                        setState(() {
                          isLoading = true;
                        });
                        Provider.of<EventProvider>(context, listen: false)
                            .fetchEventVendorDetails()
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await launch(widget.eventSingle?.availablility ?? "");
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
