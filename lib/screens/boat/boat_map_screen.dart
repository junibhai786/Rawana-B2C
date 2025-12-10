// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:developer';

import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/boat_list_model.dart';
import 'package:moonbnd/screens/boat/boat_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreenBoat extends StatefulWidget {
  const MapScreenBoat({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenBoat> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  void _addMarkers() {
    final homeProvider = Provider.of<BoatProvider>(context, listen: false);

    log("${[
      homeProvider.boatListPerCategory[7]
    ].length} lentghhhh on add marker");
    markers.clear();
    int markerCount = 0;
    if ([homeProvider.boatListPerCategory[7]].first?.data?.length != 0) {
      for (var location in [homeProvider.boatListPerCategory[7]]) {
        log("check 1");
        for (var boat in location?.data ?? []) {
          log("check 2");
          if (boat.mapLat != null && boat.mapLng != null) {
            log("check 3");

            log("${boat.mapLat}");
            log("${boat.mapLng}");

            try {
              final lat = double.parse(boat.mapLat ?? "0");
              final lng = double.parse(boat.mapLng ?? "0");

              log('$lat');
              log('$lng');
              markers.add(
                Marker(
                  markerId: MarkerId(boat.id.toString()),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(
                    title: boat.title ?? '',
                    snippet: boat.pricePerHour != null
                        ? '\$${boat.pricePerHour}'
                        : '',
                  ),
                ),
              );
              log("${markers.length} total length");
              setState(() {});
              markerCount++;
            } catch (e) {
              debugPrint('Error adding marker for hotel ${boat.id}: $e');
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<BoatProvider>(context, listen: true);

    log("${markers.length} length");

    return Scaffold(
      body: [homeProvider.boatListPerCategory[7]].first?.data?.length == 0
          ? Center(
              child: Text("No boat Available".tr),
            )
          : Stack(
              children: [
                // Main Content
                Column(
                  children: [
                    // Search Bar
                    SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: TextField(
                          readOnly: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilterBoatScreen(),
                              ),
                            ).then((value) {
                              _addMarkers();
                            });
                          },
                          onChanged: (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilterBoatScreen(),
                              ),
                            ).then((value) {
                              _addMarkers();
                            });
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: 'Search location'.tr,
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: SvgPicture.asset(
                                'assets/icons/search.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FilterBoatScreen(),
                                  ),
                                ).then((value) {
                                  _addMarkers();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  'assets/icons/filter.svg',
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 24),
                          ),
                        ),
                      ),
                    ),

                    // Map
                    Expanded(
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            double.parse([homeProvider.boatListPerCategory[7]]
                                    .first
                                    ?.data
                                    ?.first
                                    .mapLat ??
                                "0"),
                            double.parse([homeProvider.boatListPerCategory[7]]
                                    .first
                                    ?.data
                                    ?.first
                                    .mapLng ??
                                "0"),
                          ),
                          zoom: double.parse(([
                                homeProvider.boatListPerCategory[7]
                              ].first?.data?.first.mapZoom.toString()) ??
                              "9"),
                        ),
                        markers: markers,
                      ),
                    ),
                  ],
                ),

                // Bottom Sheet
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.2,
                  maxChildSize: 0.8,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          // Bottom sheet handle
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 7),
                            width: 40,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Bottom sheet header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${[
                                    homeProvider.boatListPerCategory[7]
                                  ].first?.data?.length} ${'boats found'.tr}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter'.tr,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimaryColor),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${'Showing'.tr} 1-${[
                                    homeProvider.boatListPerCategory[7]
                                  ].first?.data?.length} ${'of'.tr} ${[
                                    homeProvider.boatListPerCategory[7]
                                  ].first?.data?.length} ${'Boats'.tr}'
                                      .tr,
                                  style: TextStyle(
                                      color: grey,
                                      fontFamily: 'Inter'.tr,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),

                          // Hotel list
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: [homeProvider.boatListPerCategory[7]]
                                      .first
                                      ?.data
                                      ?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final boat = [
                                  homeProvider.boatListPerCategory[7]
                                ].first?.data?[index];
                                if (boat == null)
                                  return const SizedBox.shrink();
                                return BoatCard(boat: BoatList(data: [boat]));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

// Hotel Card Widget
class BoatCard extends StatelessWidget {
  final BoatList boat;

  const BoatCard({super.key, required this.boat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(boat.data?.first.gallery?.first ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boat.data?.first.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter'.tr,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            (boat.data?.first.location?.name ?? '').toString(),
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (boat.data?.first.reviewScore != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: flutterpads,
                                  size: 16,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  "${boat.data?.first.reviewScore}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Inter'.tr,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 7),
                          Text(
                            '${boat.data?.first.reviewScore ?? '0 '} reviews'
                                .tr,
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'from \$${boat.data?.first.pricePerHour}/hour',
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: kPrimaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
