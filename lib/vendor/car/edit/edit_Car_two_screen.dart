import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_one_screen.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:moonbnd/vendor/car/edit/edit_car_three_screen.dart';

class EditLocationScreen extends StatefulWidget {
  final int? locationid;
  final String? address;
  final String? maplatitude;
  final String? maplonitude;
  final String? checkintime;
  final String? checkouttime;
  final int? minreservation;
  final int? minreq;
  final int? zoom;

  final int? defaultstate;
  final int? number;
  final int? saleprice;
  final String? url;
  final List<ExtraPriceCar>? extraPrice;
  String title = "";
  String content = "";
  int carid = 0;
  String youtubeVideoText = "";
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String minimumDayBeforeBooking = "";
  String minimumdaystaycontroller = "";

  String? passenger = "";
  String? gear = "";
  int? baggage = 0;
  int? door = 0;
  List<FAQ2>? faq;
  List<Term>? terms;

  final int? price;
  final int? id;
  EditLocationScreen(
      {Key? key,
      this.id,
      this.faq,
      this.terms,
      this.defaultstate,
      this.zoom,
      this.passenger,
      this.gear,
      this.baggage,
      this.door,
      this.number,
      this.saleprice,
      this.minreservation,
      this.url,
      this.extraPrice,
      this.minreq,
      this.locationid,
      this.address,
      this.maplatitude,
      this.maplonitude,
      this.checkintime,
      this.checkouttime,
      this.price,
      this.bannerimage,
      this.content = "",
      this.carid = 0,
      this.featuredimage,
      this.minimumDayBeforeBooking = "",
      this.minimumdaystaycontroller = "",
      this.pickedImagefile,
      this.title = "",
      this.youtubeVideoText = ""})
      : super(key: key);
  @override
  EditLocationScreenState createState() => EditLocationScreenState();
}

class EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? location;
  String? address;
  String? locationid;
  String? locationids;

  String? zoom;

  // Initial position (for example, London)
  GoogleMapController? mapController;
  LatLng _selectedLocation = LatLng(0, 0);
  TextEditingController addresscontroller = TextEditingController();
  String? latitude;
  String? longitude;

  Set<Marker> _markers = {}; // Set to hold markers

  // Method to update the map with a new marker
  void _updateMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear(); // Clear existing markers
      _markers.add(Marker(
        markerId: MarkerId('selected-location'),
        position: _selectedLocation,
      ));
      mapController?.animateCamera(CameraUpdate.newLatLng(
          _selectedLocation)); // Move camera to the new location
    });
  }

  bool loading = false;
  @override
  void initState() {
    super.initState();
    update();
    log("featuredimage${widget.featuredimage}");

    log("passenger${widget.passenger}");
    // Prefill the data if available
  }

  update() {
    if (widget.locationid != null) {
      locationid = widget.locationid.toString();
    }
    if (widget.address != null) {
      addresscontroller.text = widget.address ?? "";
    }
    if (widget.maplatitude != null) {
      latitude = widget.maplatitude ?? "";
    }
    if (widget.maplonitude != null) {
      longitude = widget.maplonitude ?? "";
    }
    if (widget.zoom != null) {
      zoom = widget.zoom.toString();
    }

    // Fetch initial data
    setState(() {
      loading = true;
    });
    Provider.of<HomeProvider>(context, listen: false)
        .fetachaddcarlocation()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
    if (widget.maplatitude != null && widget.maplatitude != null) {
      _updateMarker(LatLng(double.parse(widget.maplatitude.toString()),
          double.parse(widget.maplonitude.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider2 = Provider.of<HomeProvider>(context, listen: true);

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
                "Update Car".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/level2_ar.png'
                  : 'assets/haven/level2.png',
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
            loading
                ? Center(
                    child: CircularProgressIndicator(color: kSecondaryColor),
                  )
                : Padding(
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
                            value: locationid,
                            hint: Text('Select location'.tr),
                            onChanged: (String? newValue) {
                              log("$newValue location checing");
                              setState(() {
                                locationid = newValue;
                                locationids = newValue;
                              });
                            },
                            items: provider2.addcarlocation?.data!
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
            SizedBox(
              height: 20,
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GooglePlaceAutoCompleteTextField(
                      boxDecoration: const BoxDecoration(
                        border: Border(),
                      ),
                      inputDecoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Location'.tr),
                      textEditingController: addresscontroller,
                      googleAPIKey: googleAPIKey,

                      debounceTime: 800, // default 600 ms,
                      countries: null,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) async {
                        // this is all you need

                        setState(() {
                          latitude = prediction.lat.toString();
                          longitude = prediction.lng.toString();
                        });

                        // Get the selected location
                        _updateMarker(LatLng(
                          double.parse(prediction.lat.toString()),
                          double.parse(prediction.lng.toString()),
                        ));
                      },
                      itemClick: (Prediction prediction) {
                        addresscontroller.text = prediction.description ?? '';
                        addresscontroller.selection =
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
            SizedBox(
              height: 20,
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
                    print("zoom${position.zoom}");
                    setState(() {
                      zoom = position.zoom.toString();
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
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add Map Lattitude"; // Validation message
                }
                return null; // Return null if validation passes
              },
              onSaved: (value) {
                latitude = value;
              },
              controller: TextEditingController(text: latitude),
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
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add Map Longitude"; // Validation message
                }
                return null; // Return null if validation passes
              },
              onSaved: (value) {
                longitude = value;
              },
              controller: TextEditingController(text: longitude),
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
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  zoom = value; // Only set if value is not null or empty
                }
              },
              controller: TextEditingController(
                text: zoom ?? "10", // Use a default value if zoom is null
              ),
            ),
            SizedBox(height: 20),
            TertiaryButton(
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (locationid == null) {
                    showErrorToast("Please add location");
                  } else if (addresscontroller.text.isEmpty) {
                    showErrorToast("Please add address");
                  } else if (_formKey.currentState?.validate() ?? false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditCarPricingScreen(
                                terms: widget.terms,
                                url: widget.url,
                                baggage: widget.baggage ?? 0,
                                faq: widget.faq,
                                passenger: widget.passenger ?? "",
                                gear: widget.gear ?? "",
                                door: widget.door ?? 0,
                                carid: widget.carid,
                                title: widget.title,
                                content: widget.content,
                                youtubeVideoText: widget.youtubeVideoText,
                                bannerimage: widget.bannerimage != null
                                    ? File(widget.bannerimage!.path)
                                    : null,
                                featuredimage: widget.featuredimage != null
                                    ? File(widget.featuredimage!.path)
                                    : null,
                                pickedImagefile:
                                    (widget.pickedImagefile ?? []).isNotEmpty
                                        ? widget.pickedImagefile!
                                            .map((e) => File(e.path))
                                            .toList()
                                        : [],
                                locationId: locationid ?? "",

                                address: addresscontroller.text,
                                mapLat: latitude ?? "",
                                mapLong: longitude ?? "",
                                mapZoom: zoom ?? "",
                                minimumDayBeforeBooking: widget.minreq ?? 0,
                                minadvancereservation:
                                    widget.minreservation.toString(),

                                defaultstate: widget.defaultstate,
                                car: widget.number ?? 0,
                                price: widget.price,
                                saleprice: widget.saleprice,
                                extraPrice: widget.extraPrice,

                                // minadvancereservation,
                                // mindaystayrequirement,
                              )),
                    );
                  }
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
