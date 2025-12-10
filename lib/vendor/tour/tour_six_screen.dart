import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';

class TourSixScreen extends StatefulWidget {
  const TourSixScreen({super.key});

  @override
  TourSixScreenState createState() => TourSixScreenState();
}

class TourSixScreenState extends State<TourSixScreen> {
  final TextEditingController _icalimporturlController =
      TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<VendorTourProvider>(context, listen: false);
    // provider.clearAllData();

    _icalimporturlController.text =
        Provider.of<VendorTourProvider>(context, listen: false)
            .icalimporturlcontroller
            .text;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<VendorTourProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Stepper progress indicator

            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text('Add New Tour'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  )),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/level5_ar.png'
                  : 'assets/haven/level5.png',
            ),
            SizedBox(
              height: 20,
            ),
            // ICAL Section
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text('ICAL'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                  )),
            ),

            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text('Import url'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  )),
            ),

            // Import URL Field
            CustomTextField(
              controller: _icalimporturlController,
              hintText: "Import url".tr,
              onChanged: (value) {
                provider.icalimporturlcontroller.text = value;
              },
            ),

            SizedBox(height: 32.0),

            // Save & Next button
            Center(
              child: TertiaryButton(
                press: () {
                  // Add validation check

                  setState(() {
                    loading = true;
                  });

                  // Update the import URL in the provider
                  provider.icalimporturlcontroller.text =
                      _icalimporturlController.text;

                  provider.addNewTour().then((value) {
                    setState(() {
                      loading = false;
                    });

                    if (value == true) {
                      setState(() {
                        // Clear all the controllers and data
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .titlecontroller
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .contentcontroller
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .youtubecontroller
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .bannerimage = null;
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .featuredimage = null;
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .pickedImagefile
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .itineraryImagefile
                            .clear();

                        // Clear location data
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .locationId = null;
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .mapLat = null;
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .mapLng = null;
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .mapZoom = null;
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .addresscontroller
                            .clear();

                        // Clear pricing data
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .pricecontroller
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .salePricecontroller
                            .clear();

                        // Clear lists
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .faq
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .includes
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .excludes
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .itinerary
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .edu
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .health
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .transform
                            .clear();

                        // Clear selected IDs
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .selectedtraveltypeIds
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .selectedfacilitytypeIds
                            .clear();

                        // Reset other controllers
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .minimumcontroller
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .minimumdaystaycontroller
                            .clear();
                        Provider.of<VendorTourProvider>(context, listen: false)
                            .icalimporturlcontroller
                            .clear();
                      });

                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();

                      Navigator.of(context).pop();

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop("yes");
                    }
                  });
                },
                text: 'Save'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
