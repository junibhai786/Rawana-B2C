import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/modals/boat_vendor_details_model.dart';
import 'package:moonbnd/vendor/boat/editboat/edit_boat_two_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditBoatOneScreen extends StatefulWidget {
  final List<BoatDetailDatum>? data;
  final String? id;
  const EditBoatOneScreen({super.key, this.data, this.id});
  @override
  State<EditBoatOneScreen> createState() => _EditBoatOneScreenState();
}

class _EditBoatOneScreenState extends State<EditBoatOneScreen> {
  late VendorBoatProvider provider;
  String bannerImageInput = "";
  List<String> galleryImageInput = [];
  String featureImageInput = "";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    log("id boat: ${widget.id}");
    provider = Provider.of<VendorBoatProvider>(context, listen: false);

    if (widget.data != null) {
      provider.titleController.text = widget.data?.first.title ?? "";
      print("Value of title controller = ${widget.data?.first.title}");

      Future.delayed(Duration(seconds: 3)).then((calue) {
        provider.contentController.setText(widget.data?.first.content ?? "");
      });

      provider.youtubeVideoController.text = widget.data?.first.video ?? "";
      provider.guestController.text =
          widget.data?.first.maxGuest.toString() ?? "";
      provider.cabinController.text = widget.data?.first.cabin.toString() ?? "";
      provider.lengthController.text =
          widget.data?.first.length.toString() ?? "";
      provider.speedController.text = widget.data?.first.speed.toString() ?? "";
      provider.cancelPolicyController.text =
          widget.data?.first.cancelPolicy ?? "";
      provider.additionalTermsController.text =
          widget.data?.first.termsInformation ?? "";
    }

    if (widget.data?.first.faqs != null &&
        widget.data!.first.faqs!.isNotEmpty) {
      final faqs = widget.data!.first.faqs!;
      for (int index = 0; index < faqs.length; index++) {
        if (provider.faqList.length <= index) {
          provider.faqList.add(FaqClass()); // Using FAQ class
        }
        provider.faqList[index].title = TextEditingController(
            text: widget.data?.first.faqs![index].title ?? '');
        provider.faqList[index].content = TextEditingController(
            text: widget.data?.first.faqs![index].content ?? '');
        provider.faqList[index].id = DateTime.now().add(Duration(seconds: 5));
      }
    }

    if (widget.data?.first.specs != null &&
        widget.data!.first.specs!.isNotEmpty) {
      final specs = widget.data!.first.specs!;
      for (int index = 0; index < specs.length; index++) {
        if (provider.specsList.length <= index) {
          provider.specsList.add(SpecClass()); // Using FAQ class
        }
        provider.specsList[index].title = TextEditingController(
            text: widget.data?.first.specs![index].title ?? '');
        provider.specsList[index].content = TextEditingController(
            text: widget.data?.first.specs![index].content ?? '');
        provider.specsList[index].id = DateTime.now().add(Duration(seconds: 5));
      }
    }

    if (widget.data?.first.include != null &&
        widget.data!.first.include!.isNotEmpty) {
      final include = widget.data!.first.include!;
      for (int index = 0; index < include.length; index++) {
        if (provider.includeList.length <= index) {
          provider.includeList.add(TitleClass()); // Using FAQ class
        }
        provider.includeList[index].title = TextEditingController(
            text: widget.data?.first.include![index].title ?? '');

        provider.includeList[index].id =
            DateTime.now().add(Duration(seconds: 5));
      }
    }

    if (widget.data?.first.exclude != null &&
        widget.data!.first.exclude!.isNotEmpty) {
      final exclude = widget.data!.first.exclude!;
      for (int index = 0; index < exclude.length; index++) {
        if (provider.excludeList.length <= index) {
          provider.excludeList.add(TitleClass()); // Using FAQ class
        }
        provider.excludeList[index].title = TextEditingController(
            text: widget.data?.first.exclude![index].title ?? '');
        provider.excludeList[index].id =
            DateTime.now().add(Duration(seconds: 5));
      }
    }

    if (widget.data?.first.bannerImage?.isNotEmpty ?? false) {
      bannerImageInput = widget.data!.first.bannerImage!;
      if (!widget.data!.first.bannerImage!.startsWith('http')) {
        provider.bannerImage = XFile(widget.data!.first.bannerImage!);
      }
    }
    if (widget.data?.first.image?.isNotEmpty ?? false) {
      featureImageInput = widget.data!.first.image!;
      if (!widget.data!.first.image!.startsWith('http')) {
        provider.featuredImage = XFile(widget.data!.first.image!);
      }
    }
    if (widget.data?.first.gallery?.isNotEmpty ?? false) {
      for (var image in widget.data!.first.gallery!) {
        if (image.startsWith('http')) {
          galleryImageInput.add(image);
        } else {
          provider.galleryImages.add(XFile(image));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorBoatProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(),
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
                    child: Text('Edit Boat'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
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
                    child: Text('Boat Content'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Title'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    controller: provider.titleController,
                    hintText: "Title".tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Content'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  HtmlEditor(
                    controller: provider.contentController, //required
                    htmlEditorOptions: HtmlEditorOptions(
                      hint: "Your text here...".tr,
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    controller: provider.youtubeVideoController,
                    hintText: "Youtube Video".tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('FAQs'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  ...(provider.faqList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: element.title,
                          hintText: 'Title'.tr,
                          // onSaved: (value) {
                          //   faqContent = value;
                          // },
                        ),
                        CustomTextField(
                          controller: element.content,
                          hintText: 'Content'.tr,
                          // onSaved: (value) {
                          //   faqContent = value;
                          // },
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteFaq(element.id);
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
                  }),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextIconButtom(
                          press: () {
                            provider.addFaq();
                          },
                          icon: Icon(
                            Icons.upload,
                            color: Colors.white,
                          ),
                          text: "Add Item".tr,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Banner Image'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  provider.bannerImage != null
                      ? Container(
                          width: double.infinity,
                          child: Image.file(
                            File(provider.bannerImage!.path),
                            height: 150,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : bannerImageInput.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              child: Image.network(
                                bannerImageInput,
                                height: 150,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print("Error loading banner image: $error");
                                  return Container(
                                    height: 150,
                                    width: 200,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 150,
                              width: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.add_photo_alternate),
                            ),

                  SizedBox(height: 20),
                  // Banner Image Upload
                  SizedBox(
                    width: 200,
                    child: TextIconButtom(
                      icon: Icon(
                        Icons.upload,
                        color: Colors.white,
                      ),
                      press: () {
                        provider.pickImage();
                      },
                      text: "Uplaod Image".tr,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Gallery'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  if (provider.galleryImages.isNotEmpty)
                    ...(provider.galleryImages).map((element) {
                      return InkWell(
                        onTap: () {
                          provider.galleryImages.removeWhere((test) {
                            return test == element;
                          });
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              width: double.infinity,
                              child: Image.file(
                                File(element.path),
                                height: 150,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                color: Colors.white,
                                child: Icon(Icons.cancel, color: Colors.red),
                              ),
                            )
                          ],
                        ),
                      );
                    }),

                  if (galleryImageInput.isNotEmpty)
                    ...(galleryImageInput).map((element) {
                      return InkWell(
                        onTap: () async {
                          bool check = await provider.deleteImage(
                              element, widget.id ?? '');

                          if (check) {
                            galleryImageInput.removeWhere((test) {
                              return test == element;
                            });
                            setState(() {});
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              width: double.infinity,
                              child: Image.network(
                                element,
                                height: 150,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                color: Colors.white,
                                child: Icon(Icons.cancel, color: Colors.red),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  SizedBox(height: 20),
                  TextIconButtom(
                    icon: Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    text: 'Upload Images'.tr,
                    press: () => provider.pickGalleryImages(),
                  ),

                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Extra Info'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Guest'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    controller: provider.guestController,
                    hintText: 'Ex: 3'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Cabin'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    margin: false,
                    controller: provider.cabinController,
                    hintText: 'Ex: 5'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Length'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    margin: false,
                    controller: provider.lengthController,
                    hintText: 'Ex: 30m'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Speed'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  CustomTextField(
                    margin: false,
                    controller: provider.speedController,
                    hintText: 'Ex: 25 km/hr'.tr,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Text('Specs'.tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ...(provider.specsList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Text('Title'.tr,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        CustomTextField(
                          margin: false,
                          controller: element.title,
                          hintText: 'Title'.tr,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: Text('Content'.tr,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        CustomTextField(
                          margin: false,
                          controller: element.content,
                          hintText: 'Content'.tr,
                        ),
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red, // Red background color
                            borderRadius: BorderRadius.circular(
                                12), // Slightly rounded corners
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteSpec(element.id);
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
                  }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            press: () {
                              provider.addSpec();
                            },
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            text: "Add Item".tr,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Cancellation Policy'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    controller: provider.cancelPolicyController,
                    hintText: 'Full refund upto 4 days prior'.tr,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Additional Terms & Information'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    margin: false,
                    controller: provider.additionalTermsController,
                    hintText: 'Type here...'.tr,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Include Services'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  ...(provider.includeList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          margin: false,
                          controller: element.title,
                          hintText: 'Title'.tr,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteInclude(element.id);
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
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            press: () {
                              provider.addInclude();
                            },
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            text: "Add Item".tr,
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Exclude Services'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  ...(provider.excludeList).map((element) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          margin: false,
                          controller: element.title,
                          hintText: 'Title'.tr,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              provider.deleteExclude(element.id);
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
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextIconButtom(
                            press: () {
                              provider.addExclude();
                            },
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            text: "Add Item".tr,
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 5, top: 10),
                    child: Text('Featured Image'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                  ),
                  provider.featuredImage != null
                      ? Container(
                          width: double.infinity,
                          child: Image.file(
                            File(provider.featuredImage!.path),
                            height: 150,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : featureImageInput.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              child: Image.network(
                                featureImageInput,
                                height: 150,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    width: 200,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 150,
                              width: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.add_photo_alternate),
                            ),
                  SizedBox(height: 20),

                  SizedBox(
                    height: 10,
                  ),
                  TextIconButtom(
                    icon: Icon(Icons.upload),
                    text: 'Upload Image'.tr,
                    press: () => provider.pickImage(featureCheck: true),
                  ),
                  SizedBox(height: 20),
                  TertiaryButton(
                    press: () async {
                      final provider = Provider.of<VendorBoatProvider>(context,
                          listen: false);
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        String contentSend =
                            await provider.contentController.getText();

                        log("${provider.contentController.toString()} stringstring");

                        if (contentSend.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please enter boat content'.tr)),
                          );
                          return;
                        }
                        if (provider.bannerImage == null &&
                            bannerImageInput.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please upload a banner image'.tr)),
                          );
                          return;
                        }

                        if (provider.galleryImages.isEmpty &&
                            galleryImageInput.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please upload a gallery image'.tr)),
                          );
                          return;
                        }

                        // Validate Specs (if any are added)
                        if (provider.specsList.isEmpty) {
                          Get.snackbar(
                              "Error", "Please add at least one Specs.".tr);
                          return;
                        }

                        // Validate Include List (if any are added)
                        if (provider.includeList.isEmpty) {
                          Get.snackbar(
                              "Error", "Please add at least one Include.".tr);
                          return;
                        }
                        if (provider.excludeList.isEmpty) {
                          Get.snackbar(
                              "Error", "Please add at least one Exclude.".tr);
                          return;
                        }

                        // Validate Featured Image
                        if (provider.featuredImage == null &&
                            featureImageInput.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please upload a featured image'.tr)),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditBoatLocationScreen(
                              data: widget.data,
                              id: widget.id,
                            ),
                          ),
                        );
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
    });
  }
}

// Widget _buildDropdown(String label, List<String> items) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 16.0, left: 10, right: 10),
//     child: DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       items: items.map((String item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: (value) {},
//     ),
//   );
// }
