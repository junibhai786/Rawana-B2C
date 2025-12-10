import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/car/car_two_screen.dart';
import 'package:moonbnd/widgets/addimagecomponent.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FAQ {
  String? title;
  String? content;
  DateTime? id;

  FAQ({this.title, this.content, this.id});
}

class AddNewCarScreen extends StatefulWidget {
  AddNewCarScreen({
    Key? key,
  }) : super(key: key);
  @override
  _AddNewCarScreenState createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<VendorAuthProvider>(context, listen: false).clear();
  }

  // Variables to store form data
  String? title;
  String? content;
  String? youtubeVideo;
  String? faqTitle;
  String? faqContent;
  XFile? bannerImage;

  List<XFile> galleryImages = [];

  List<String> passangeroption = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            ? 'assets/haven/level1_ar.png'
                            : 'assets/haven/level.png',
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          "Car Content".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Title Input
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Title".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        hintText: "Title".tr,
                        controller: provider.titlecontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please add title".tr; // Validation message
                          }
                          return null; // Return null if validation passes
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Content".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      // Content Input
                      HtmlEditor(
                        controller: provider.contentcontroller, //required

                        htmlEditorOptions: HtmlEditorOptions(
                          inputType: HtmlInputType.text,

                          adjustHeightForKeyboard: true,

                          //initalText: "text content initial, if any",
                        ),
                        otherOptions: OtherOptions(
                          height: 400,
                        ),
                      ),
                      // CustomTextField(
                      //   maxCheck: 5,
                      //   hintText: "Special Requirment".tr,
                      //   controller: provider.contentcontroller,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return "Please add content"; // Validation message
                      //     }
                      //     return null; // Return null if validation passes
                      //   },
                      // ),
                      // Youtube Video Input
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "Youtube Video".tr,
                          style: TextStyle(fontFamily: "inter", fontSize: 14),
                        ),
                      ),
                      CustomTextField(
                        hintText: "Youtube Video".tr,
                        controller: provider.youtubecontroller,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return "Please add youtube video"; // Validation message
                        //   }
                        //   return null; // Return null if validation passes
                        // },
                      ),
                      // FAQ section
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          "FAQs".tr,
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int index = 0;
                              index < provider.faq.length;
                              index++)
                            Column(
                              children: [
                                CustomTextField(
                                  controller: TextEditingController(
                                      text: provider.faq[index].title),
                                  hintText: "Title".tr,
                                  onChanged: (value) {
                                    provider.faq[index].title = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Title'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                CustomTextField(
                                  controller: TextEditingController(
                                      text: provider.faq[index].content),
                                  hintText: "Content".tr,
                                  onChanged: (value) {
                                    provider.faq[index].content = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please add faq content"
                                          .tr; // Validation message
                                    }
                                    return null; // Return null if validation passes
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
                                          color: Colors
                                              .red, // Red background color
                                          borderRadius: BorderRadius.circular(
                                              12), // Slightly rounded corners
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors
                                                .white, // White icon color
                                          ),
                                          onPressed: () {
                                            provider.removefaq(index);
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

                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              "Banner Image".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          // Banner Image Upload

                          provider.bannerimage != null
                              ? Column(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            provider.bannerimage = null;
                                          });
                                        },
                                        child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Center(
                                                child: Icon(Icons.close))),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Image.file(provider.bannerimage!,
                                          // Set a height for the image
                                          width: double
                                              .infinity, // Set width to fill the container
                                          fit: BoxFit.cover),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
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
                                          text: "Uplaod Image".tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 2, left: 10),
                            child: Text(
                              "Gallery".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: AddImageComponent(
                              imageArr: provider.pickedImagefile,
                              onTapAdd: () {
                                provider.pickImages();
                              },
                              onTapRemove: (int index) {
                                setState(() {
                                  provider.pickedImagefile.removeAt(index);
                                });
                              },
                            ),
                          ),

                          Divider(
                            thickness: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10, top: 10, left: 10),
                            child: Text(
                              "Extra Info".tr,
                              style: TextStyle(
                                  fontFamily: "inter",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          // Extra Info
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 4),
                            child: Text(
                              "Passenger".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
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
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please add passenger"
                                            .tr; // Validation message
                                      }
                                      return null; // Return null if validation passes
                                    },
                                    hint: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text("Ex:3".tr),
                                    ),
                                    value: provider.selectpassanger,
                                    items: passangeroption.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          provider.selectpassanger = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, bottom: 4, top: 16),
                            child: Text(
                              "Gearshift".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),
                          CustomTextField(
                            hintText: 'Example: Auto'.tr,
                            controller: provider.gearcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please add gearshift"
                                    .tr; // Validation message
                              }
                              return null; // Return null if validation passes
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, bottom: 4, top: 16),
                            child: Text(
                              "Baggage".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Ex:3'.tr,
                                border:
                                    OutlineInputBorder(), // Adds a border around the dropdown
                                enabledBorder: OutlineInputBorder(
                                  // Border when dropdown is not focused
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Border when dropdown is focused
                                  borderSide: BorderSide(
                                      color: kSecondaryColor, width: 2.0),
                                ),
                              ),
                              items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                                  .map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    provider.selectbaggage = value;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Please add baggage"
                                      .tr; // Validation message
                                }
                                return null; // Return null if validation passes
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, bottom: 4, top: 16),
                            child: Text(
                              "Door".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: DropdownButtonFormField<int>(
                              validator: (value) {
                                if (value == null) {
                                  return "Please add door"
                                      .tr; // Validation message
                                }
                                return null; // Return null if validation passes
                              },
                              decoration: InputDecoration(
                                labelText: 'Ex: 4'.tr,
                                border:
                                    OutlineInputBorder(), // Adds a border around the dropdown
                                enabledBorder: OutlineInputBorder(
                                  // Border when dropdown is not focused
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Border when dropdown is focused
                                  borderSide: BorderSide(
                                      color: kSecondaryColor, width: 2.0),
                                ),
                              ),
                              items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                                  .map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    provider.selectdoor = value;
                                  });
                                }
                              },
                            ),
                          ),
                          // Featured Image Upload
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, bottom: 4, top: 16),
                            child: Text(
                              "Featured Image".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          provider.featuredimage != null
                              ? Stack(children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              provider.featuredimage = null;
                                            });
                                          },
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Center(
                                                  child: Icon(Icons.close))),
                                        ),
                                      ),
                                      Image.file(provider.featuredimage!,
                                          // Set a height for the image
                                          width: double
                                              .infinity, // Set width to fill the container
                                          fit: BoxFit.fill)
                                    ],
                                  )
                                ])
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextIconButtom(
                                      icon: Icon(Icons.upload),
                                      text: 'Upload Image'.tr,
                                      press: () {
                                        provider.pickImagefeatured();
                                      }),
                                ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: TertiaryButton(
                              press: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  String contentSend = await provider
                                      .contentcontroller
                                      .getText();

                                  if (contentSend.isEmpty) {
                                    return showErrorToast(
                                        "content can't be empty".tr);
                                  }

                                  if (provider.featuredimage == null ||
                                      provider.bannerimage == null ||
                                      provider.pickedImagefile.isEmpty) {
                                    return showErrorToast(
                                        "Please fill all types of images".tr);
                                  }

                                  // if (provider.faq.isEmpty) {
                                  //   return showErrorToast(
                                  //       "please select atleast one faq");
                                  // }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddLocationScreen()),
                                  );
                                }
                              },
                              text: 'Save & Next'.tr,
                            ),
                          ),
                          // Add Item Button

                          // Display the title and content fields
                        ],
                      ),
                    ]),
              )),
        ));
  }
}
