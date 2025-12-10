import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CarFiveScreen extends StatefulWidget {
  final String? url;
  CarFiveScreen({this.url});
  @override
  CarFiveScreenState createState() => CarFiveScreenState();
}

class CarFiveScreenState extends State<CarFiveScreen> {
  bool loading = false;
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VendorAuthProvider>(context, listen: false);

    if (widget.url != null) {
      provider.importUrlController.text = widget.url ?? "";
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: loading
          ? Center(
              child: CircularProgressIndicator(color: kSecondaryColor),
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Stepper progress indicator

                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text('Add New Car'.tr,
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
                      padding: EdgeInsets.only(left: 10, bottom: 10),
                      child: Text('Import url'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                          )),
                    ),

                    // Import URL Field
                    CustomTextField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please add importurl"
                              .tr; // Validation message
                        }
                        return null; // Return null if validation passes
                      },
                      controller: provider.importUrlController,
                      hintText: "Import url".tr,
                    ),

                    SizedBox(height: 32.0),

                    // Save & Next button
                    Center(
                      child: TertiaryButton(
                        press: () {
                          setState(() {
                            loading = true;
                          });
                          provider.addnewcarvendor().then((value) {
                            setState(() {
                              loading = false;
                            });
                            if (value == true) {
                              setState(() {
                                provider.titlecontroller.clear();
                                provider.contentcontroller.clear();
                                provider.youtubecontroller.clear();
                                provider.bannerimage = null;
                                provider.featuredimage = null;
                                provider.pickedImagefile.isEmpty;
                                provider.pickedImagefile.clear();

                                provider.gearcontroller.clear();
                                provider.selectbaggage = null;
                                provider.selectbaggage = null;

                                provider.selectdoor = null;
                                provider.locationids = null;
                                provider.addresscontroller.clear();
                                provider.latitude = null;
                                provider.longitude = null;
                                provider.defaultstate = 0;
                                provider.carcontroller.clear();
                                provider.pricecontroller.clear();
                                provider.salepricecontroller.clear();
                                provider.minimumdaystaycontroller.clear();
                                provider.minimumcontroller.clear();
                                provider.extraprice.clear();
                                provider.selectedCartypeIds.isEmpty;
                                provider.selectedCarFeatureIds.isEmpty;
                                provider.importUrlController.clear();
                              });
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => BottomNav()),
                                  (route) => false);
                            }
                          });
                        },
                        text: 'Save'.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
