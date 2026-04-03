// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:developer';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/hotel_list_model.dart';
import 'package:moonbnd/screens/hotel/filter_screen.dart';
import 'package:moonbnd/screens/hotel/room_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  void _addMarkers() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    log("${[
      homeProvider.hotelListPerCategory[1]
    ].length} lentghhhh on add marker");
    markers.clear();
    int markerCount = 0;
    if ([homeProvider.hotelListPerCategory[1]].first?.data?.length != 0) {
      for (var location in [homeProvider.hotelListPerCategory[1]]) {
        for (var hotel in location?.data ?? []) {
          if (hotel.mapLat != null && hotel.mapLng != null) {
            try {
              final lat = double.parse(hotel.mapLat ?? "0");
              final lng = double.parse(hotel.mapLng ?? "0");
              markers.add(
                Marker(
                  markerId: MarkerId(hotel.id.toString()),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(
                    title: hotel.title ?? '',
                    snippet: hotel.price != null ? '\$${hotel.price}' : '',
                  ),
                ),
              );
              markerCount++;
            } catch (e) {
              debugPrint('Error adding marker for hotel ${hotel.id}: $e');
            }
          }
        }
      }
      print('Total markers added to map: $markerCount');
    }
  }

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);

    log([homeProvider.hotelListPerCategory[1]].isEmpty ? "empty" : "no empty");
    log("${[homeProvider.hotelListPerCategory[1]].length} lentghhhh");
    log("${[
      homeProvider.hotelListPerCategory[1]
    ].first?.data?.length} lentghhhh");

    return Scaffold(
      body: [homeProvider.hotelListPerCategory[1]].first?.data?.length == 0
          ? Center(
              child: Text("No Hotel Available".tr),
            )
          : Stack(
              children: [
                // Main Content
                Column(
                  children: [
                    // Search Bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                            decoration: InputDecoration(
                              hintText: 'Search location'.tr,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
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
                                      builder: (context) => FilterScreen(),
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
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
                            double.parse([homeProvider.hotelListPerCategory[1]]
                                    .first
                                    ?.data
                                    ?.first
                                    .mapLat ??
                                "0"),
                            double.parse([homeProvider.hotelListPerCategory[1]]
                                    .first
                                    ?.data
                                    ?.first
                                    .mapLng ??
                                "0"),
                          ),
                          zoom: double.parse(([
                                homeProvider.hotelListPerCategory[1]
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
                            margin: const EdgeInsets.only(top: 8, bottom: 4),
                            width: 40,
                            height: 4,
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
                                    homeProvider.hotelListPerCategory[1]
                                  ].first?.data?.length} ${'hotels found'.tr}',
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
                                    homeProvider.hotelListPerCategory[1]
                                  ].first?.data?.length} ${'of'.tr} ${[
                                    homeProvider.hotelListPerCategory[1]
                                  ].first?.data?.length} ${'Hotels'.tr}',
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
                              itemCount: [homeProvider.hotelListPerCategory[1]]
                                      .first
                                      ?.data
                                      ?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final hotel = [
                                  homeProvider.hotelListPerCategory[1]
                                ].first?.data?[index];
                                if (hotel == null)
                                  return const SizedBox.shrink();
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RoomDetailScreen(
                                                  hotelId:
                                                      hotel.id!.toString()),
                                        ),
                                      );
                                    },
                                    child: HotelCard(
                                        hotel: HotelList(data: [hotel])));
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
class HotelCard extends StatelessWidget {
  final HotelList hotel;

  const HotelCard({super.key, required this.hotel});

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
                    image: NetworkImage(hotel.data?.first.gallery?.first ?? ''),
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
                            hotel.data?.first.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter'.tr,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (hotel.data?.first.location?.name ?? '').toString(),
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
                          if (hotel.data?.first.reviewScore != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: flutterpads,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${hotel.data?.first.reviewScore}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Inter'.tr,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          Text(
                            '${hotel.data?.first.reviewScore ?? '0 '} reviews',
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
                  'from \$${hotel.data?.first.price}/night'.tr,
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
