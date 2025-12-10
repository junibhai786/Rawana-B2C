import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/vendor/car/car_three_screen.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddLocationScreen extends StatefulWidget {
  final String? locationid;
  final String? address;
  final String? maplatitude;
  final String? maplonitude;
  final String? checkintime;
  final String? checkouttime;
  final String? minreservation;
  final String? minreq;
  final int? defaultstate;
  final String? number;
  final int? saleprice;
  final String? url;
  final List<ExtraPriceCar>? extraPrice;

  final String? price;
  final int? id;
  AddLocationScreen({
    Key? key,
    this.id,
    this.defaultstate,
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
  }) : super(key: key);
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Initial position (for example, London)
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(0, 0);

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
      mapController.animateCamera(CameraUpdate.newLatLng(
          _selectedLocation)); // Move camera to the new location
    });
  }

  bool loading = false;
  @override
  void initState() {
    super.initState();
    // Prefill the data if available

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
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);
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
                "Add New Car".tr,
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
                            value: provider.locationid,
                            hint: Text('Select location'.tr),
                            onChanged: (String? newValue) {
                              setState(() {
                                provider.locationid = newValue;
                                provider.locationids = newValue;
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
                      textEditingController: provider.addresscontroller,
                      googleAPIKey: googleAPIKey,
                      debounceTime: 800, // default 600 ms,
                      countries: null,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) async {
                        setState(() {
                          provider.latitude = prediction.lat.toString();
                          provider.longitude = prediction.lng.toString();
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
                      provider.zoom = position.zoom.toString();
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
                provider.latitude = value;
              },
              controller: TextEditingController(text: provider.latitude),
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add Map Lattitude".tr; // Validation message
                }
                return null; // Return null if validation passes
              },
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
              onSaved: (value) {
                provider.longitude = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add Map Longitude".tr; // Validation message
                }
                return null; // Return null if validation passes
              },
              controller: TextEditingController(text: provider.longitude),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add zoom"; // Validation message
                }
                return null; // Return null if validation passes
              },
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  provider.zoom =
                      value; // Only set if value is not null or empty
                }
              },
              controller: TextEditingController(
                text: provider.zoom ??
                    "10", // Use a default value if zoom is null
              ),
            ),
            SizedBox(height: 20),
            TertiaryButton(
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (provider.locationid == null) {
                    showErrorToast("Please add location".tr);
                  } else if (provider.addresscontroller.text.isEmpty) {
                    showErrorToast("Please add address".tr);
                  } else if (_formKey.currentState?.validate() ?? false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCarPricingScreen(
                                extraPrice: widget.extraPrice,
                                url: widget.url,
                                minadvancereservation: widget.minreservation,
                                mindaystayrequirement: widget.minreq,
                                defaultstate: widget.defaultstate,
                                number: widget.number,
                                price: widget.price,
                                saleprice: widget.saleprice,
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
