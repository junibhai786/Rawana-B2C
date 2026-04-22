import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/all_space_vendor_modal.dart';
import 'package:moonbnd/vendor/space/edit/edit_space_screen_one.dart';
import 'package:moonbnd/vendor/space/sapce_detail_webview.dart';
import 'package:moonbnd/vendor/space/space_one_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
// ignore: unused_import
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllSpaceScreen extends StatefulWidget {
  @override
  State<AllSpaceScreen> createState() => _ManageCarScreenState();
}

class _ManageCarScreenState extends State<AllSpaceScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Provider.of<SpaceProvider>(context, listen: false)
        .fetchSpaceVendorDetails()
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
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);
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
                  Text('Manage Space'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 20),
                  spaceProvider.spaceVendor?.data.length == 0
                      ? Expanded(
                          child: Center(child: Text("No Space Added Yet".tr)))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: spaceProvider
                                .spaceVendor?.data.length, // Example count
                            itemBuilder: (context, index) {
                              return HotelCard(
                                tour: spaceProvider.spaceVendor?.data[index],
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
                    press: () async {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SpaceOneScreen()))
                          .then((value) async {
                        if (value == "yes") {
                          setState(() {
                            isLoading = true;
                          });
                          await Provider.of<SpaceProvider>(context,
                                  listen: false)
                              .fetchSpaceVendorDetails()
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
                    text: 'Add Space',
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
  SpaceVendor? tour;

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;
  void _showDeleteConfirmation(
      BuildContext context, SpaceProvider spaceProvider) {
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
                    'Space Delete Permanently'.tr,
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
                        spaceProvider
                            .deleteVendorSpace(
                                id: widget.tour?.id.toString() ?? "")
                            .then(
                          (value) async {
                            if (value == true) {
                              await spaceProvider.fetchSpaceVendorDetails();
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
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);

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
                    itemCount: widget.tour?.gallery.length ??
                        0, // Count of gallery images
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.tour?.gallery[index] ??
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
                      List.generate(widget.tour?.gallery.length ?? 0, (index) {
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
                        'space',
                      );
                      spaceProvider.fetchSpaceVendorDetails();

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
                        _showDeleteConfirmation(context, spaceProvider);
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
                          spaceProvider
                              .hideSpaceVendor(
                                  id: widget.tour?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                spaceProvider.fetchSpaceVendorDetails();
                              }
                            },
                          );
                        } else {
                          spaceProvider
                              .publishSpaceVendor(
                                  id: widget.tour?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                spaceProvider.fetchSpaceVendorDetails();
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
                                  ? AppColors.secondary
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
                            '${widget.tour?.discountPercent}  ${'OFF'.tr}',
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
            child: Text('${'Location:'.tr} ${widget.tour?.location.name}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Row(
              children: [
                Text('Price:'.tr,
                    style: TextStyle(
                      color: Colors.black,
                    )),
                if (widget.tour?.salePrice != "0") SizedBox(width: 4),
                if (widget.tour?.salePrice != "0")
                  Text('${widget.tour?.salePrice}',
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
                Text('\$${widget.tour?.price}',
                    style: TextStyle(color: Colors.black))
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
                        // tourProvider
                        //     .publishtourvendor(
                        //         id: widget.tour?.id.toString() ?? "")
                        //     .then(
                        //   (value) {
                        //     if (value == true) {
                        //       tourProvider.fetchalltourvendor();
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
                      child: Text(' ${widget.tour?.status}',
                          style: TextStyle(color: Colors.white)))
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                '${'Last Updated:'.tr} ${formatTimestamp(DateTime.parse(widget.tour?.updatedat ?? ""))}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    // if (widget.tour?.detailsUrl != null) {
                    //   launchUrl(Uri.parse(widget.tour!.detailsUrl!));

                    // }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpaceDetailWebView(
                          url: "${widget.tour?.detailsUrl}",
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
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    spaceProvider
                        .cloneSpaceVendor(widget.tour?.id.toString() ?? "")
                        .then(
                      (value) async {
                        if (value == true) {
                          await spaceProvider.fetchSpaceVendorDetails();
                        }
                      },
                    ).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                    });

                    // tourProvider
                    //     .clonetourvendor(id: widget.tour?.id.toString() ?? "")
                    //     .then(
                    //   (value) {
                    //     if (value == true) {
                    //       tourProvider.fetchalltourvendor();
                    //     }
                    //   },
                    // );
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
                            builder: (context) => EditSpaceOneScreen(
                                id: "${widget.tour?.id}"))).then((value) {
                      if (value == "yes") {
                        setState(() {
                          isLoading = true;
                        });
                        Provider.of<SpaceProvider>(context, listen: false)
                            .fetchSpaceVendorDetails()
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
                  await launch(widget.tour?.availability_url ?? "");
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
