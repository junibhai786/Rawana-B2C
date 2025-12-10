import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/space/space_three_Screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SpaceLocationScreenTwo extends StatefulWidget {
  String title = "";
  String content = "";
  String youtubeVideoText = "";
  List<FaqClass>? faqList;
  File? bannerimage;
  File? featuredimage;
  List<File>? pickedImagefile;
  String minimumDayBeforeBooking = "";
  String minimumdaystaycontroller = "";
  String bed = "";
  String bathroom = "";
  SpaceLocationScreenTwo(
      {super.key,
      this.bannerimage,
      this.bathroom = "",
      this.bed = "",
      this.content = "",
      this.faqList,
      this.featuredimage,
      this.minimumDayBeforeBooking = "",
      this.minimumdaystaycontroller = "",
      this.pickedImagefile,
      this.title = "",
      this.youtubeVideoText = ""});

  @override
  // ignore: library_private_types_in_public_api
  _SpaceLocationScreenState createState() => _SpaceLocationScreenState();
}

class _SpaceLocationScreenState extends State<SpaceLocationScreenTwo> {
  final _formKey = GlobalKey<FormState>();

  LatLng _selectedLocation = LatLng(0, 0);
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  // Initial position (for example, London)

  void _updateMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;

      markers.clear(); // Clear existing markers
      markers.add(Marker(
        markerId: MarkerId('selected-location'),
        position: _selectedLocation,
      ));
      mapController.animateCamera(CameraUpdate.newLatLng(
          _selectedLocation)); // Move camera to the new location
    });
  }

  void addEducation() {
    Provider.of<SpaceProvider>(context, listen: false).educationList.add(
        EducationClass(
            id: DateTime.now(),
            distance: TextEditingController(),
            value: TextEditingController(text: 'm'),
            content: TextEditingController(),
            name: TextEditingController()));

    setState(() {});
  }

  void addHealth() {
    Provider.of<SpaceProvider>(context, listen: false).healthList.add(
        EducationClass(
            id: DateTime.now(),
            distance: TextEditingController(),
            value: TextEditingController(text: 'm'),
            content: TextEditingController(),
            name: TextEditingController()));

    setState(() {});
  }

  void addTransportation() {
    Provider.of<SpaceProvider>(context, listen: false).transportationList.add(
        EducationClass(
            id: DateTime.now(),
            distance: TextEditingController(),
            value: TextEditingController(text: 'm'),
            content: TextEditingController(),
            name: TextEditingController()));

    setState(() {});
  }

  void deleteEducation(DateTime? id) {
    Provider.of<SpaceProvider>(context, listen: false)
        .educationList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void deleteHealth(DateTime? id) {
    Provider.of<SpaceProvider>(context, listen: false)
        .healthList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void deleteTransportation(DateTime? id) {
    Provider.of<SpaceProvider>(context, listen: false)
        .transportationList
        .removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  bool loading = false;
  @override
  void initState() {
    super.initState();

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
    final provider2 = Provider.of<SpaceProvider>(context, listen: true);
    final provider1 = Provider.of<HomeProvider>(context, listen: true);
    // final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);
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
                "Add New Space".tr,
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
                      value: provider2.locationid,
                      hint: Text('Select location'.tr),
                      onChanged: (String? newValue) {
                        setState(() {
                          provider2.locationid = newValue ?? "";
                        });
                      },
                      items: provider1.addcarlocation?.data!
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
            SizedBox(height: 10),

            // Real Address Input

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
                      textEditingController: provider2.addresscontroller,
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
                          provider2.latitude = prediction.lat.toString();
                          provider2.longitude = prediction.lng.toString();
                        });

                        // Get the selected location
                        _updateMarker(LatLng(
                          double.parse(prediction.lat.toString()),
                          double.parse(prediction.lng.toString()),
                        ));
                      },
                      itemClick: (Prediction prediction) {
                        provider2.addresscontroller.text =
                            prediction.description ?? '';
                        provider2.addresscontroller.selection =
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
                    print("zoom${position.zoom}");
                    setState(() {
                      provider2.zoom = position.zoom.toString();
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 10.0,
                  ),
                  markers: markers,
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
              hintText: "Map Latitude".tr,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Map Latitude'.tr;
                }
                return null;
              },
              onSaved: (value) {
                provider2.latitude = value;
              },
              controller: TextEditingController(text: provider2.latitude),
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
              hintText: "Map Longitude".tr,
              txKeyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Map Longitude'.tr;
                }
                return null;
              },
              onSaved: (value) {
                provider2.longitude = value;
              },
              controller: TextEditingController(text: provider2.longitude),
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
                  return 'Please enter Map Zoom'.tr;
                }
                return null;
              },
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  provider2.zoom =
                      value; // Only set if value is not null or empty
                }
              },
              controller: TextEditingController(
                text: provider2.zoom ??
                    "10", // Use a default value if zoom is null
              ),
            ),
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

            ...(provider2.educationList).map((element) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: element.name,
                    hintText: "Title".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  CustomTextField(
                    controller: element.content,
                    hintText: "Content".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  CustomTextField(
                    controller: element.distance,
                    hintText: "Distance".tr,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  SizedBox(
                    height: 55,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: DropdownButtonFormField<String>(
                        value: element.value?.value.text,
                        decoration: InputDecoration(
                          border:
                              OutlineInputBorder(), // Adds a border around the dropdown
                          enabledBorder: OutlineInputBorder(
                            // Border when dropdown is not focused
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // Border when dropdown is focused
                            borderSide:
                                BorderSide(color: kSecondaryColor, width: 2.0),
                          ),
                        ),
                        items: ['m', 'km'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          element.value = TextEditingController(text: value);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    decoration: BoxDecoration(
                      color: Colors.red, // Red background color
                      borderRadius:
                          BorderRadius.circular(12), // Slightly rounded corners
                    ),
                    child: IconButton(
                      onPressed: () {
                        deleteEducation(element.id);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),

            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 130,
                  child: TextIconButtom(
                    press: () {
                      addEducation();
                    },
                    icon: Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    text: "Add Item".tr,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Health'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),

            ...(provider2.healthList).map((element) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: element.name,
                    hintText: "Title".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  CustomTextField(
                    controller: element.content,
                    hintText: "Content".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  CustomTextField(
                    controller: element.distance,
                    hintText: "Distance".tr,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  SizedBox(
                    height: 55,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: DropdownButtonFormField<String>(
                        value: element.value?.value.text,
                        decoration: InputDecoration(
                          border:
                              OutlineInputBorder(), // Adds a border around the dropdown
                          enabledBorder: OutlineInputBorder(
                            // Border when dropdown is not focused
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // Border when dropdown is focused
                            borderSide:
                                BorderSide(color: kSecondaryColor, width: 2.0),
                          ),
                        ),
                        items: ['m', 'km'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          element.value = TextEditingController(text: value);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    decoration: BoxDecoration(
                      color: Colors.red, // Red background color
                      borderRadius:
                          BorderRadius.circular(12), // Slightly rounded corners
                    ),
                    child: IconButton(
                      onPressed: () {
                        deleteHealth(element.id);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),

            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 130,
                  child: TextIconButtom(
                    press: () {
                      addHealth();
                    },
                    icon: Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    text: "Add Item".tr,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Transportation'.tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),

            ...(provider2.transportationList).map((element) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: element.name,
                    hintText: "Title".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  CustomTextField(
                    controller: element.content,
                    hintText: "Content".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  CustomTextField(
                    controller: element.distance,
                    txKeyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    hintText: "Distance".tr,
                    onSaved: (value) {
                      provider2.zoom = value;
                    },
                  ),
                  SizedBox(
                    height: 55,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: DropdownButtonFormField<String>(
                        value: element.value?.value.text,
                        decoration: InputDecoration(
                          border:
                              OutlineInputBorder(), // Adds a border around the dropdown
                          enabledBorder: OutlineInputBorder(
                            // Border when dropdown is not focused
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // Border when dropdown is focused
                            borderSide:
                                BorderSide(color: kSecondaryColor, width: 2.0),
                          ),
                        ),
                        items: ['m', 'km'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          element.value = TextEditingController(text: value);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    decoration: BoxDecoration(
                      color: Colors.red, // Red background color
                      borderRadius:
                          BorderRadius.circular(12), // Slightly rounded corners
                    ),
                    child: IconButton(
                      onPressed: () {
                        deleteTransportation(element.id);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),

            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 130,
                  child: TextIconButtom(
                    press: () {
                      addTransportation();
                    },
                    icon: Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    text: "Add Item".tr,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 10,
            ),
            TertiaryButton(
              press: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (provider2.locationid == null) {
                    showErrorToast("Please select Location".tr);
                    return;
                  }
                  if (provider2.addresscontroller.value.text.isEmpty) {
                    showErrorToast("Please write real address".tr);
                    return;
                  }
                  // if (provider2.educationList.isEmpty) {
                  //   showErrorToast("Please write atleast one education");
                  //   return;
                  // }
                  // if (provider2.healthList.isEmpty) {
                  //   showErrorToast("Please write atleast one health");
                  //   return;
                  // }
                  // if (provider2.transportationList.isEmpty) {
                  //   showErrorToast("Please write atleast one transportation");
                  //   return;
                  // }

                  // Check for hotel related IDs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddSpacePricingScreenThree(
                              title: widget.title,
                              content: widget.content,
                              youtubeVideoText: widget.youtubeVideoText,
                              faqList: widget.faqList ?? [],
                              bannerimage: widget.bannerimage != null
                                  ? File(widget.bannerimage!.path)
                                  : null,
                              featuredimage: widget.featuredimage != null
                                  ? File(widget.featuredimage!.path)
                                  : null,
                              pickedImagefile: widget.pickedImagefile != null
                                  ? widget.pickedImagefile!
                                      .map((e) => File(e.path))
                                      .toList()
                                  : [],
                              minimumDayBeforeBooking:
                                  widget.minimumDayBeforeBooking,
                              minimumdaystaycontroller:
                                  widget.minimumdaystaycontroller,
                              bed: widget.bed,
                              bathroom: widget.bathroom,
                              locationId: provider2.locationid ?? "",
                              address: provider2.addresscontroller.value.text,
                              mapLat: provider2.latitude ?? "",
                              mapLong: provider2.longitude ?? "",
                              mapZoom: provider2.zoom ?? "",
                              txeducationList: provider2.educationList,
                              txhealthList: provider2.healthList,
                              txtransportationList:
                                  provider2.transportationList,
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
