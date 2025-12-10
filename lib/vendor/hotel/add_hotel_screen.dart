import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/hotel_provider.dart';

import 'package:moonbnd/vendor/hotel/hotel_location_add_screen.dart';
import 'package:moonbnd/widgets/addimagecomponent.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:provider/provider.dart';

class EDU {
  String? title;
  String? content;
  String? distance;
  String? type;

  EDU({this.title, this.content, this.distance, this.type});
}

class AddNewHotelScreen extends StatefulWidget {
  AddNewHotelScreen({
    super.key,
  });

  @override
  _AddNewHotelScreenState createState() => _AddNewHotelScreenState();
}

class _AddNewHotelScreenState extends State<AddNewHotelScreen> {
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    final provider = Provider.of<VendorHotelProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              // Clear all the controllers and data
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .titlecontroller
                  .clear();

              Provider.of<VendorHotelProvider>(context, listen: false)
                  .youtubecontroller
                  .clear();
              provider.selectpassanger = "";
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .bannerimage = null;
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .featuredimage = null;
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .pickedImagefile
                  .clear();
              provider.selectpassanger = null;
              provider.isShowPassword = false;
              provider.timechecincontroller.clear();
              provider.timechecoutcontroller.clear();
              provider.selectreservations = null;
              provider.selectrequirements = null;

              provider.edu = [];
              provider.health = [];

              provider.latitude = null;
              provider.longitude = null;
              provider.transform = [];
              provider.addresscontroller.text = '';
              provider.addresscontroller = TextEditingController();
              provider.price = [];
              provider.selectedpropertytypeIds = [];
              provider.selectedfacilitytypeIds = [];
              provider.selectedservicetypeIds = [];
              // Clear location data
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .locationid = null;
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .addresscontroller
                  .clear();

              // Clear pricing data
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .pricecontroller
                  .clear();

              // Clear lists
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .faq
                  .clear();

              provider.hotelreleatedid.clear();

              provider.faq = [];

              Provider.of<VendorHotelProvider>(context, listen: false)
                  .edu
                  .clear();
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .health
                  .clear();
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .transform
                  .clear();

              // Clear selected IDs
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .selectedfacilitytypeIds
                  .clear();

              // Reset other controllers
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .minimumcontroller
                  .clear();
              Provider.of<VendorHotelProvider>(context, listen: false)
                  .minimumdaystaycontroller
                  .clear();
            });
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text('Add New Hotel'.tr,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  height: 20,
                ),
                Image.asset(
                  Get.locale?.languageCode == 'ar'
                      ? 'assets/haven/eventlevel1_ar.png'
                      : 'assets/haven/eventlevel1.png',
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Text('Hotel Content'.tr,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Title'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                CustomTextField(
                  hintText: "Title".tr,
                  controller: provider.titlecontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Title'.tr;
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Content'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                // CustomTextField(
                //   maxCheck: 5,
                //   hintText: "special requirement".tr,
                //   controller:
                //       Provider.of<VendorHotelProvider>(context).contentcontroller,
                // ),
                HtmlEditor(
                  controller: provider.contentController, //required

                  htmlEditorOptions: HtmlEditorOptions(
                    inputType: HtmlInputType.text,

                    adjustHeightForKeyboard: true,

                    //initalText: "text content initial, if any",
                  ),
                  otherOptions: OtherOptions(
                    height: 400,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Youtube Video'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                CustomTextField(
                  hintText: "Youtube Video".tr,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter Youtube'.tr;
                  //   }
                  //   return null;
                  // },
                  controller: Provider.of<VendorHotelProvider>(context)
                      .youtubecontroller,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Banner Image'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                SizedBox(
                  height: 8,
                ),
                provider.bannerimage != null
                    ? Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Image.file(
                              provider.bannerimage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    provider.bannerimage = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(child: Icon(Icons.close)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          children: [
                            Container(
                              child: TextIconButtom(
                                icon: Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                ),
                                press: () {
                                  provider.pickImagebanner();
                                },
                                text: "Upload Image".tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Gallery'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AddImageComponent(
                    imageArr: provider.pickedImagefile,
                    onTapAdd: () {
                      provider.pickimage();
                    },
                    onTapRemove: (int index) {
                      setState(() {
                        provider.pickedImagefile.removeAt(index);
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                  child: Text('Hotel Policy'.tr,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Hotel Rating Standard'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
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
                              .selectpassanger, // Current selected value
                          hint: Text("Ex :1".tr), // Placeholder text
                          onChanged: (String? newValue) {
                            setState(() {
                              provider.selectpassanger =
                                  newValue; // Update the selected value
                            });
                          },
                          items: <String>[
                            '1',
                            '2',
                            '3',
                            '4',
                            '5'
                          ] // Dropdown items
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
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: Text('Policy'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                for (int index = 0; index < provider.faq.length; index++)
                  Column(
                    children: [
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.faq[index].title),
                        hintText: "Title".tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Title'.tr;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          provider.faq[index].title = value;
                        },
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                            text: provider.faq[index].content),
                        hintText: "Content".tr,
                        onChanged: (value) {
                          provider.faq[index].content = value;
                        },
                      ),
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
                                  provider.removefaq(provider.faq[index].id!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
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
                          provider.addfaq();
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 10),
                  child: Text('Featured Image'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                SizedBox(
                  height: 10,
                ),
                provider.featuredimage != null
                    ? Stack(
                        children: [
                          Image.file(
                            provider.featuredimage!,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    provider.featuredimage = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(child: Icon(Icons.close)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : TextIconButtom(
                        icon: Icon(Icons.upload),
                        text: "Upload Image".tr,
                        press: () {
                          provider.pickImagefeatured();
                        }),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                  child: Text('Hotel Related IDs'.tr,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                CustomTextField(
                  hintText: "Hotel Related IDs".tr,
                  txKeyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter Hotel Related Id'.tr;
                  //   }
                  //   return null;
                  // },
                  controller: provider.hotelreleatedid,
                ),
                TertiaryButton(
                  press: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      String contentSend =
                          await provider.contentController.getText();

                      if (contentSend.isEmpty) {
                        return showErrorToast("Please write content");
                      }
                      if (provider.selectpassanger == null) {
                        return showErrorToast("Please select hotel rating");
                      }

                      if (provider.featuredimage == null ||
                          provider.bannerimage == null ||
                          provider.pickedImagefile.isEmpty) {
                        // Check for hotel related IDs
                        return showErrorToast(
                            "Please fill all Types of images");
                      }

                      if (provider.faq.isEmpty) {
                        return showErrorToast(
                            "Please select atleast one policy");
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HotelLocationScreen()));
                    }
                  },
                  text: 'Save & Next'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
