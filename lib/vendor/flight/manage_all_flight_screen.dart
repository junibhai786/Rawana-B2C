import 'dart:developer';

import 'package:moonbnd/Provider/flight_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/all_flight_vendor_model.dart';
import 'package:moonbnd/vendor/flight/edit/edit_flight_one_screen.dart';
import 'package:moonbnd/vendor/flight/flight_screen_one.dart';
import 'package:moonbnd/vendor/flight/flight_webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageAllFlightScreen extends StatefulWidget {
  const ManageAllFlightScreen({super.key});

  @override
  State<ManageAllFlightScreen> createState() => _ManageAllFlightScreenState();
}

class _ManageAllFlightScreenState extends State<ManageAllFlightScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Provider.of<VendorFlightProvider>(context, listen: false)
        .fetchallflightvendor()
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
        Provider.of<VendorFlightProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Flights'.tr,
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
              itemCount: homeProvider.flights?.data?.length, // Example count
              itemBuilder: (context, index) {
                return HotelCard(
                  hotel: homeProvider.flights?.data?[index],
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
                    MaterialPageRoute(builder: (context) => FlightScreenOne()),
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
                    ), // Rounded corners
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
                      'Add Flight'.tr,
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

class HotelCard extends StatefulWidget {
  HotelCard({super.key, required this.hotel});
  FDatum? hotel;

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isLoading = true;

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

  void _showDeleteConfirmation(
      BuildContext context, VendorFlightProvider homeProvider) {
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
                    'Flight Delete Permanently'.tr,
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
                          .deleteflightvendor(
                              id: widget.hotel?.id.toString() ?? "")
                          .then(
                        (value) {
                          if (value == true) {
                            homeProvider.fetchallflightvendor();

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
  Widget build(BuildContext context) {
    final homeProvider =
        Provider.of<VendorFlightProvider>(context, listen: true);

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
                child: Image.network(
                  widget.hotel?.image ?? '', // Load image from URL
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey.shade200, // Fallback background color
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
                              .hideflightvendor(
                                  id: widget.hotel?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                homeProvider.fetchallflightvendor();
                              }
                            },
                          );
                        } else {
                          homeProvider
                              .publishflightvendor(
                                  id: widget.hotel?.id.toString() ?? "")
                              .then(
                            (value) {
                              if (value == true) {
                                homeProvider.fetchallflightvendor();
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
            child: Text('${'From:'.tr} ${widget.hotel?.airportForm?.name}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text('${'To:'.tr} ${widget.hotel?.airportTo?.name}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Text('${'Duration:'.tr} ${widget.hotel?.duration}'),
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
                        /*homeProvider
                        .publishflightvendor(
                        id: widget.hotel?.id.toString()??"")
                        .then(
                          (value) {
                        if (value == true) {
                          homeProvider
                              .fetchallflightvendor();
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
                      child: Text(' ${widget.hotel?.status}',
                          style: TextStyle(color: Colors.white)))
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                '${'Last Updated:'.tr} ${formatTimestamp(widget.hotel?.updatedAt)}'),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlightWebViewScreen(
                        url: "${widget.hotel?.detailsUrl}",
                        appbartitle: "Flight Detail",
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF17A2B8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('View'.tr),
              ),
              TextButton(
                onPressed: () {
                  homeProvider
                      .cloneflightvendor(id: widget.hotel?.id.toString() ?? "")
                      .then(
                    (value) {
                      if (value == true) {
                        homeProvider.fetchallflightvendor();
                      }
                    },
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF1A2B47),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Clone'.tr),
              ),
              TextButton(
                onPressed: () {
                  // Make the API call to fetch hotel details before navigating
                  Provider.of<VendorFlightProvider>(context, listen: false)
                      .fetchallflightdetailvendor(widget.hotel?.id.toString())
                      .then((value) {
                    print("value of titile = ${value}");
                    // Navigate to the AddNewHotelScreen after fetching data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFlightScreenOne(
                            data: value,
                            title: value[0].title,
                            content: value[0].code,
                            terms: value[0].terms,
                            id: widget.hotel?.id.toString() ?? ''

                            // Assuming value has title

                            // Assuming value has youtubeVideo
                            ),
                      ),
                    );
                  }).catchError((error) {
                    // Handle any errors that occur during the API call
                    print("Error fetching hotel details: $error");
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Edit'.tr),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  log('${widget.hotel?.flightseaturl}');
                  // ignore: deprecated_member_use
                  await launch(widget.hotel?.flightseaturl ?? "");
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
                    Text('Add Flight ticket'.tr),
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
