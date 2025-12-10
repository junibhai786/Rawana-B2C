import 'dart:developer';
import 'dart:io';

import 'package:moonbnd/Provider/api_interface.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/car_detail_model.dart';
import 'package:moonbnd/vendor/car/edit/edit_Car_two_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_plus/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ExtraPrices2 {
  TextEditingController? price;
  String? type;
  TextEditingController? name;
  DateTime? id;
  TextEditingController? namejapanese;
  TextEditingController? nameegyptian;

  ExtraPrices2(
      {this.price,
      this.type,
      this.name,
      this.id,
      this.nameegyptian,
      this.namejapanese});
}

class FAQ2 {
  TextEditingController? title;
  TextEditingController? content;
  DateTime? id;

  FAQ2({this.title, this.content, this.id});
}

class EditCarScreen extends StatefulWidget {
  final String? title;
  final String? url;

  final int? defaultstate;

  final int? baggage;
  final int? selectdoor;
  final List<ExtraPriceCar>? extraPrice;

  final String? content;
  final String? featuredimage;
  final int? number;

  final String? youtubeVideo;
  final String? bannerimage;
  final int? starrate;
  final String? featuredImage;
  final int? HotelrelatedId;
  final int? locationid;
  final String? address;
  final String? maplatitude;
  final String? maplongitude;
  final String? gearshift;
  final int? passenger;
  final String? checkintime;
  final String? checkouttime;
  final int? minreservation;
  final int? minreq;
  final int? price;
  final String? mindaystayrequirement;
  final int? carid;
  final int? zoom;
  List<Term>? terms;

  final int? saleprice;
  List<String>? gallery;

  final int? id;
  final List<Faq>? faqs;
  EditCarScreen(
      {Key? key,
      this.id,
      this.carid,
      this.terms,
      this.zoom,
      this.gallery,
      this.baggage,
      this.url,
      this.defaultstate,
      this.number,
      this.saleprice,
      this.extraPrice,
      this.mindaystayrequirement,
      this.featuredimage,
      this.selectdoor,
      this.address,
      this.gearshift,
      this.passenger,
      this.checkintime,
      this.checkouttime,
      this.minreservation,
      this.minreq,
      this.price,
      this.title,
      this.faqs,
      this.locationid,
      this.maplatitude,
      this.maplongitude,
      this.HotelrelatedId,
      this.content,
      this.featuredImage,
      this.youtubeVideo,
      this.bannerimage,
      this.starrate})
      : super(key: key);
  @override
  EditCarScreenState createState() => EditCarScreenState();
}

class EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> galleryImageInput = [];

  // Variables to store form data
  String? title;
  String? content;
  String? youtubeVideo;

  XFile? bannerImage;

  List<File> galleryImages = [];

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

  // List to hold title and content pairs

  @override
  void initState() {
    super.initState();
    if ((widget.gallery ?? []).isNotEmpty) {
      widget.gallery?.forEach((element) {
        return galleryImageInput.add(element);
      });
    }
    log("minreservation${widget.url}");
    if (widget.title != null) {
      titlecontroller = TextEditingController(text: widget.title);
    }
    Future.delayed(Duration(seconds: 3)).then((value) {
      contentcontroller.setText(widget.content ?? "");
      log("message${widget.content}");
    });

    if (widget.youtubeVideo != null) {
      youtubecontroller.text = widget.youtubeVideo ?? '';
    }
    if (widget.gearshift != null) {
      gearcontroller.text = widget.gearshift ?? "";
    }

    if (widget.passenger != null) {
      selectpassanger = widget.passenger.toString();
    }
    if (widget.baggage != null) {
      selectbaggage = widget.baggage ?? 1;
    }
    if (widget.selectdoor != null) {
      selectdoor = widget.selectdoor ?? 1;
    }
    if (widget.faqs != null && widget.faqs!.isNotEmpty) {
      widget.faqs!.forEach((elemet) {
        return faq.add(FAQ2(
          id: DateTime.now().add(Duration(seconds: 1)),
          content: TextEditingController(text: elemet.content),
          title: TextEditingController(text: elemet.title),
        ));
      });
    }
    setState(() {});
    /*print("Value of door controller = ${widget.galaryimage}");*/
  }

  Future<void> pickImagefeatured() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        featuredimage = File(pickedImage.path); // Store the image file
      });
    }
  }

  TextEditingController titlecontroller = TextEditingController();
  // TextEditingController contentcontroller = TextEditingController();
  HtmlEditorController contentcontroller = HtmlEditorController();
  TextEditingController youtubecontroller = TextEditingController();
  TextEditingController gearcontroller = TextEditingController();
  int? selectdoor;
  String? selectpassanger;

  int? selectbaggage;
  final ImagePicker _picker = ImagePicker();

  List<FAQ2> faq = [];
  File? bannerimage;
  File? featuredimage;

  Future<void> pickImagebanner() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        bannerimage = File(pickedImage.path); // Store the image file
      });
    }
  }

  void deleteFaq(DateTime? id) {
    faq.removeWhere((test) {
      return test.id == id;
    });

    setState(() {});
  }

  void addfaq() {
    faq.add(FAQ2());
  }

  void addFaq() {
    faq.add(FAQ2(
        id: DateTime.now(),
        content: TextEditingController(),
        title: TextEditingController()));

    setState(() {});
  }

  List<File> pickedImagefile = [];
  Future<void> pickimage() async {
    final ImagePicker pickedimage = ImagePicker();
    final XFile? image =
        await pickedimage.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        pickedImagefile.add(File(image.path));
      });
    }
  }

  Future<void> pickGalleryImages() async {
    final picker = ImagePicker();
    final XFile? images = await picker.pickImage(source: ImageSource.gallery);

    if (images != null) {
      setState(() {
        galleryImages.add(File(images.path));
      });
    }
  }

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
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        controller: titlecontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please add title"; // Validation message
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
                      // CustomTextField(
                      //   maxCheck: 5,
                      //   hintText: "Special Requirment".tr,
                      //   controller: contentcontroller,
                      // ),
                      HtmlEditor(
                        controller: contentcontroller, //required

                        htmlEditorOptions: HtmlEditorOptions(
                          inputType: HtmlInputType.text,

                          adjustHeightForKeyboard: true,

                          //initalText: "text content initial, if any",
                        ),
                        otherOptions: OtherOptions(
                          height: 400,
                        ),
                      ),
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
                        controller: youtubecontroller,
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
                          ...(faq).map((elementss) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  controller: elementss.title,
                                  hintText: 'Title'.tr,
                                  // onSaved: (value) {
                                  //   faqContent = value;
                                  // },
                                ),
                                CustomTextField(
                                  controller: elementss.content,
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
                                      deleteFaq(elementss.id);
                                      setState(() {});
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

                          Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: TextIconButtom(
                                  press: () {
                                    addFaq();
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

                          bannerimage != null
                              ? Container(
                                  width: double.infinity,
                                  child: Image.file(
                                    File(bannerimage!.path),
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  child: Image.network(
                                    widget.bannerimage ?? "",
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
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
                                      pickImagebanner();
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
                            padding: const EdgeInsets.only(bottom: 2, left: 10),
                            child: Text(
                              "Gallery".tr,
                              style:
                                  TextStyle(fontFamily: "inter", fontSize: 14),
                            ),
                          ),

                          if (galleryImages.isNotEmpty)
                            ...(galleryImages).map((element) {
                              return InkWell(
                                onTap: () {
                                  galleryImages.removeWhere((test) {
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
                                        child: Icon(Icons.cancel,
                                            color: Colors.red),
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
                                      element, widget.id.toString());

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
                                        child: Icon(Icons.cancel,
                                            color: Colors.red),
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
                            press: () => pickGalleryImages(),
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
                                        return "Please add passenger"; // Validation message
                                      }
                                      return null; // Return null if validation passes
                                    },
                                    hint: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text("Ex : 3".tr),
                                    ),
                                    value: selectpassanger,
                                    items: passangeroption.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectpassanger = newValue;
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please add gearshift"; // Validation message
                              }
                              return null; // Return null if validation passes
                            },
                            controller: gearcontroller,
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
                              value: selectbaggage,
                              validator: (value) {
                                if (value == null) {
                                  return "Please add baggage"; // Validation message
                                }
                                return null; // Return null if validation passes
                              },
                              decoration: InputDecoration(
                                labelText: 'Ex: 3'.tr,
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
                                    selectbaggage = value;
                                  });
                                }
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
                              value: selectdoor,
                              validator: (value) {
                                if (value == null) {
                                  return "Please add door"; // Validation message
                                }
                                return null; // Return null if validation passes
                              },
                              decoration: InputDecoration(
                                labelText: 'Ex: 4',

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
                                    selectdoor = value;
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
                          featuredimage != null
                              ? Container(
                                  width: double.infinity,
                                  child: Image.file(
                                    File(featuredimage!.path),
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  child: Image.network(
                                    widget.featuredimage ?? "",
                                    height: 150,
                                    width: 200,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            child: Stack(
                              children: [
                                Container(
                                  child: TextIconButtom(
                                    icon: Icon(
                                      Icons.upload,
                                      color: Colors.white,
                                    ),
                                    press: () {
                                      pickImagefeatured();
                                    },
                                    text: "Upload Image".tr,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: TertiaryButton(
                              press: () async {
                                String contentSend =
                                    await contentcontroller.getText();

                                log('$contentSend sennndd');

                                if (contentSend.isEmpty) {
                                  return showErrorToast(
                                      "content can't be empty");
                                }

                                log("${galleryImages.length} lenghtcheck");
                                log("${galleryImageInput.length} lenghtcheck 2");

                                if ((bannerImage == null &&
                                        widget.bannerimage == null) ||
                                    (featuredimage == null &&
                                        widget.featuredImage == null) ||
                                    (galleryImages.isEmpty &&
                                        galleryImageInput.length == 0)) {
                                  // Check for hotel related IDs
                                  return showErrorToast(
                                      "Please fill all Types of images");
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditLocationScreen(
                                            terms: widget.terms,
                                            carid: widget.carid ?? 0,
                                            zoom: widget.zoom,
                                            faq: faq,
                                            title: titlecontroller.text,
                                            content: contentSend,
                                            bannerimage: bannerimage,
                                            youtubeVideoText:
                                                youtubecontroller.text,
                                            passenger: selectpassanger ?? "",
                                            gear: gearcontroller.text,
                                            baggage: selectbaggage,
                                            door: selectdoor,
                                            pickedImagefile: galleryImages,
                                            featuredimage: featuredimage,
                                            url: widget.url,
                                            extraPrice: widget.extraPrice,
                                            saleprice: widget.saleprice,
                                            number: widget.number,
                                            defaultstate: widget.defaultstate,
                                            maplatitude: widget.maplatitude,
                                            checkintime: widget.checkintime,
                                            checkouttime: widget.checkouttime,
                                            id: widget.id,
                                            minreservation:
                                                widget.minreservation ?? 0,
                                            minreq: widget.minreq,
                                            price: widget.price,
                                            maplonitude: widget.maplongitude,
                                            locationid: widget.locationid,
                                            address: widget.address,
                                          )),
                                );
                              },
                              text: 'Save & Next'.tr,
                            ),
                          ),
                          // Add Item Button

                          // Display the title and content fields
                        ],
                      ),
                    ]),
              ),
            )));
  }
}
