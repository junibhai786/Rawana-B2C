import 'dart:developer';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/boat_vendor_details_model.dart';
import 'package:moonbnd/vendor/boat/editboat/edit_boat_three_screen.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';

class EditBoatLocationScreen extends StatefulWidget {
  final List<BoatDetailDatum>? data;
  final String? id;
  @override
  const EditBoatLocationScreen({super.key, this.data, this.id});
  @override
  EditBoatLocationScreenState createState() => EditBoatLocationScreenState();
}

class EditBoatLocationScreenState extends State<EditBoatLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? location;
  String? address;
  String? latitude;
  String? longitude;
  String? zoom;
  GoogleMapController? mapController;

  // Initial position (for example, London)
  LatLng _selectedLocation = LatLng(0, 0);
  Set<Marker> _markers = {};

  void _updateMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear(); // Clear existing markers
      _markers.add(Marker(
        markerId: MarkerId('selected-location'),
        position: _selectedLocation,
      ));
      if (mapController != null) {
        // Check if mapController is initialized
        mapController!.animateCamera(CameraUpdate.newLatLng(
            _selectedLocation)); // Move camera to the new location
      }
    });
  }

  bool loading = false;
  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });

    _updateMarker(LatLng(double.parse(widget.data?.first.mapLat ?? ""),
        double.parse(widget.data?.first.mapLng ?? "")));

    log("id boat: ${widget.id}");

    final provider = Provider.of<VendorBoatProvider>(context, listen: false);
    // provider.clearAllData();
    log(" id boat: ${widget.id}");
    Provider.of<VendorBoatProvider>(context, listen: false)
        .fetachaddtourlocation()
        .then((value) {
      setState(() {
        loading = false;
      });
    });

    if (widget.data != null) {
      provider.locationid = widget.data!.first.location?.id.toString();
    }

    if (widget.data?.first.location != null) {
      provider.addresscontroller.text = widget.data!.first.address ?? '';
    }
    if (widget.data?.first.mapLat != null) {
      provider.mapLat = widget.data!.first.mapLat.toString();
    }
    if (widget.data?.first.mapLng != null) {
      provider.mapLng = widget.data!.first.mapLng.toString();
    }

    if (widget.data?.first.mapZoom != null) {
      provider.mapZoom = widget.data!.first.mapZoom.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorBoatProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Add New Boat".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/eventlevel2_ar.png'
                  : 'assets/haven/eventlevel2.png',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 15),
              child: Text(
                "Locations".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(
              height: 10,
            ),

            // Location Dropdown
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                "Location".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: provider.locationid,
                      hint: Text('Select location'.tr),
                      onChanged: (String? newValue) {
                        setState(() {
                          provider.locationid = newValue;
                          provider.locationids = newValue;
                        });
                      },
                      items: provider.addtourlocation?.data!
                          .map<DropdownMenuItem<String>>((location) {
                        return DropdownMenuItem<String>(
                          value: location.id.toString(),
                          child: Text(location.name ?? ''),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            // Real Address Input\
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                "Real Address".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.0),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GooglePlaceAutoCompleteTextField(
                      boxDecoration: const BoxDecoration(border: Border()),
                      inputDecoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Location'.tr),
                      textEditingController: provider.addresscontroller,
                      googleAPIKey: googleAPIKey,
                      debounceTime: 800, // default 600 ms,
                      countries: null,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) async {
                        // this is all you need

                        setState(() {
                          // state = placeMark.administrativeArea;
                          // postalCode = placeMark.postalCode;
                          // city = placeMark.locality;
                          // country = placeMark.country;
                          provider.mapLat = prediction.lat.toString();
                          provider.mapLng = prediction.lng.toString();
                        });

                        // Get the selected location
                        _updateMarker(LatLng(
                          double.parse(prediction.lat.toString()),
                          double.parse(prediction.lng.toString()),
                        ));
                      },
                      itemClick: (Prediction prediction) {
                        provider.addresscontroller.text =
                            prediction.description ?? '';
                        provider.addresscontroller.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: prediction.description!.length));
                      },

                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                  child: Text(prediction.description ?? ""))
                            ],
                          ),
                        );
                      },

                      seperatedBuilder: const Divider(),

                      isCrossBtnShown: true,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "The Geographic coordinate".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            // Google Map Display
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                height: 200.0,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  onCameraMove: (position) {
                    setState(() {
                      provider.mapZoom = position.zoom.round().toString();
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 10.0,
                  ),
                  markers: _markers,
                  zoomControlsEnabled: true,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Map Latitude'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            // Latitude Input
            CustomTextField(
              hintText: "Real Address".tr,
              onSaved: (value) {
                provider.mapLat = value;
              },
              controller: TextEditingController(text: provider.mapLat),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Map Longitude'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            // Longitude Input
            CustomTextField(
              hintText: "Real Address".tr,
              onSaved: (value) {
                provider.mapLng = value;
              },
              controller: TextEditingController(text: provider.mapLng),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Map Zoom'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            // Zoom Level Input
            CustomTextField(
              hintText: "Map Zoom".tr,
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  provider.mapZoom =
                      value; // Only set if value is not null or empty
                }
              },
              controller: TextEditingController(
                text: provider.mapZoom ??
                    "10", // Use a default value if zoom is null
              ),
            ),
            SizedBox(height: 20),
            TertiaryButton(
              press: () {
                if (provider.mapZoom == null ||
                    provider.mapLng == null ||
                    provider.mapLat == null ||
                    provider.addresscontroller.text.isEmpty ||
                    provider.locationid == null) {
                  showErrorToast("Please input all details".tr);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditBoatPricingScreen(
                              data: widget.data,
                              id: widget.id,
                            )),
                  );
                }
              },
              text: 'Save & Next'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
