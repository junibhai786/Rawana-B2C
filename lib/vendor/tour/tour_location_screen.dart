import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/tour/tour_pricing_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';

class TourLocationScreen extends StatefulWidget {
  final String? id;

  TourLocationScreen({this.id});

  @override
  _TourLocationScreenState createState() => _TourLocationScreenState();
}

class EDU {
  String? title;
  String? content;
  String? distance;
  String? type;

  EDU({this.title, this.content, this.distance, this.type});
}

class HEALTH {
  String? title;
  String? content;
  String? distance;
  String? type;

  HEALTH({this.title, this.content, this.distance, this.type});
}

class TRANSFORM {
  String? title;
  String? content;
  String? distance;
  String? type;

  TRANSFORM({this.title, this.content, this.distance, this.type});
}

class _TourLocationScreenState extends State<TourLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? location;
  String? address;
  String? latitude;
  String? longitude;
  String? zoom;
  GoogleMapController? mapController;

  LatLng _selectedLocation = LatLng(0, 0);

  final Set<Marker> _markers = {}; // Set to hold markers

  // Method to update the map with a new marker
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

    // provider.clearAllData();

    Provider.of<VendorTourProvider>(context, listen: false)
        .fetachaddtourlocation()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorTourProvider>(context, listen: true);

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
                "Add New Tour".tr,
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

            SizedBox(height: 10),

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
            SizedBox(height: 10),
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
                        // List<Placemark> newPlace =
                        //     await placemarkFromCoordinates(
                        //         double.parse(prediction.lat.toString()),
                        //         double.parse(prediction.lng.toString()));

                        // // this is all you need
                        // Placemark placeMark = newPlace[0];
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Map Latitude'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            // Latitude Input
            CustomTextField(
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Map Latitude'.tr;
                }
                return null;
              },
              hintText: "Map Latitude".tr,
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
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your map longitude'.tr;
                }
                return null;
              },
              hintText: "Map Longitude".tr,
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

            CustomTextField(
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hintText: "Map Zoom".tr,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Map Zoom'.tr;
                }
                return null;
              },
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
            // Zoom Level Input

            SizedBox(height: 20),
            Divider(thickness: 2),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 15),
              child: Text(
                "Surroundings".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Education'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),

            for (int index = 0; index < provider.edu.length; index++)
              Column(
                children: [
                  CustomTextField(
                    hintText: "Title".tr,
                    onChanged: (value) {
                      provider.edu[index].title = value;
                    },
                    controller:
                        TextEditingController(text: provider.edu[index].title),
                  ),
                  CustomTextField(
                    hintText: "Content".tr,
                    onChanged: (value) {
                      provider.edu[index].content = value;
                    },
                    controller: TextEditingController(
                        text: provider.edu[index].content),
                  ),
                  CustomTextField(
                    hintText: "Distance".tr,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      provider.edu[index].distance = value;
                    },
                    controller: TextEditingController(
                        text: provider.edu[index].distance),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider
                                .edu[index].type, // Current selected value
                            hint: Text("Select unit".tr), // Placeholder text
                            onChanged: (String? newValue) {
                              setState(() {
                                provider.edu[index].type =
                                    newValue; // Update the selected value
                              });
                            },
                            items: <String>['m', 'km'] // Dropdown items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white, // White icon color
                            ),
                            onPressed: () {
                              provider.removeedu(index);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 100,
                child: TextIconButtom(
                  size: 10,
                  icon: Icon(Icons.upload),
                  text: 'Add Item'.tr,
                  press: () {
                    setState(() {
                      provider.addedu();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Health'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            for (int index = 0; index < provider.health.length; index++)
              Column(
                children: [
                  CustomTextField(
                    hintText: "Title".tr,
                    onChanged: (value) {
                      provider.health[index].title = value;
                    },
                    controller: TextEditingController(
                        text: provider.health[index].title),
                  ),
                  CustomTextField(
                    hintText: "Content".tr,
                    onChanged: (value) {
                      provider.health[index].content = value;
                      print("health${provider.health[index].content}");
                    },
                    controller: TextEditingController(
                        text: provider.health[index].content),
                  ),
                  CustomTextField(
                    hintText: "distance".tr,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      provider.health[index].distance = value;
                      print("health${provider.health[index].distance}");
                    },
                    controller: TextEditingController(
                        text: provider.health[index].distance),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider
                                .health[index].type, // Current selected value
                            hint: Text("Select unit".tr), // Placeholder text
                            onChanged: (String? newValue) {
                              setState(() {
                                provider.health[index].type =
                                    newValue; // Update the selected value
                              });
                            },
                            items: <String>['m', 'km'] // Dropdown items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white, // White icon color
                            ),
                            onPressed: () {
                              provider.removehealth(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 100,
                child: TextIconButtom(
                  size: 10,
                  icon: Icon(Icons.upload),
                  text: 'Add Item'.tr,
                  press: () {
                    setState(() {
                      provider.addhealth();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Transportation'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            for (int index = 0; index < provider.transform.length; index++)
              Column(
                children: [
                  CustomTextField(
                    hintText: "Title".tr,
                    onChanged: (value) {
                      provider.transform[index].title = value;
                    },
                    controller: TextEditingController(
                        text: provider.transform[index].title),
                  ),
                  CustomTextField(
                    hintText: "Content".tr,
                    onChanged: (value) {
                      provider.transform[index].content = value;
                      print("transform${provider.transform[index].content}");
                    },
                    controller: TextEditingController(
                        text: provider.transform[index].content),
                  ),
                  CustomTextField(
                    hintText: "distance".tr,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      provider.transform[index].distance = value;
                      print("transform${provider.transform[index].distance}");
                    },
                    controller: TextEditingController(
                        text: provider.transform[index].distance),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.transform[index]
                                .type, // Current selected value
                            hint: Text("Select unit".tr), // Placeholder text
                            onChanged: (String? newValue) {
                              setState(() {
                                provider.transform[index].type =
                                    newValue; // Update the selected value
                              });
                            },
                            items: <String>['m', 'km'] // Dropdown items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white, // White icon color
                            ),
                            onPressed: () {
                              provider.removetransform(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 100,
                child: TextIconButtom(
                  size: 10,
                  icon: Icon(Icons.upload),
                  text: 'Add Item'.tr,
                  press: () {
                    setState(() {
                      provider.addtransform();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TertiaryButton(
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (provider.locationid == null) {
                    Get.snackbar("Error".tr, "Please select Location".tr);
                    return;
                  }
                  if (provider.addresscontroller.value.text.isEmpty) {
                    Get.snackbar("Error".tr, "Please write real address".tr);
                    return;
                  }
                  // if (provider.edu.isEmpty) {
                  //   Get.snackbar(
                  //       "Error".tr, "Please write atleast one education".tr);
                  //   return;
                  // }
                  // if (provider.health.isEmpty) {
                  //   Get.snackbar(
                  //       "Error".tr, "Please write atleast one health".tr);
                  //   return;
                  // }
                  // if (provider.transform.isEmpty) {
                  //   Get.snackbar(
                  //       "Error", "Please write atleast one transportation".tr);
                  //   return;
                  // }

                  // Check for hotel related IDs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TourPricingScreen()),
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
