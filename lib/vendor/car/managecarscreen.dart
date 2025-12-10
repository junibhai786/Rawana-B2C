import 'dart:developer';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/car_data_Item.dart';
import 'package:moonbnd/data_models/home_screen_data.dart';
import 'package:moonbnd/vendor/car/car_one_screen.dart';
import 'package:moonbnd/vendor/hotel/hotel_detail_webview.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
// ignore: unused_import
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ManageCarScreen extends StatefulWidget {
  const ManageCarScreen({super.key});

  @override
  State<ManageCarScreen> createState() => _ManageCarScreenState();
}

class _ManageCarScreenState extends State<ManageCarScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    Provider.of<HomeProvider>(context, listen: false)
        .fetchCarvendorDetails()
        .then(
      (value) {
        if (value == true) {
          setState(() {
            isLoading = false;
          });
          log("$isLoading");
        }
      },
    );
  }

  // CarVendorModel? carList;

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
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
                  Text('Manage Car'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: homeProvider.carlists?.data?.length,
                      itemBuilder: (context, index) {
                        // Handle null case
                        var carData = CarData.fromCar(
                            homeProvider.carlists!.data![index]);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Column(
                            children: [
                              CarDataItem(
                                  managecar: true,
                                  dataSrc: carData,
                                  press: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => WebViewScreen(
                                    //       appbartitle: "Car Details",
                                    //       url: "${carData.detailsurl}",
                                    //     ),
                                    //   ),
                                    // );
                                  }),
                            ],
                          ),
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
                              builder: (context) => AddNewCarScreen()));
                    },
                    text: 'Add Car'.tr,
                  ),
                ],
              ),
            ),
    );
  }
}
