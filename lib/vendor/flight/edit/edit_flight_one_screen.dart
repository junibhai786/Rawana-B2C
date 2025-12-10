import 'package:moonbnd/Provider/flight_vendor_provider.dart';
import 'package:moonbnd/modals/flight_detail_vendor_model.dart';
import 'package:moonbnd/vendor/flight/edit/edit_flight_two_screen.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditFlightScreenOne extends StatefulWidget {
  List<FDDatum>? data;
  final String? title;
  final String? content;
  final String? id;
  List<Term>? terms;

  EditFlightScreenOne(
      {super.key, this.data, this.title, this.content, this.terms, this.id});

  @override
  FlightScreenOneState createState() => FlightScreenOneState();
}

class FlightScreenOneState extends State<EditFlightScreenOne> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool loading2 = false;

  // Variables to store form data
  String? title;
  String? content;
  String? youtubeVideo;
  String? faqTitle;
  String? faqContent;
  XFile? bannerImage;
  XFile? featuredImage;
  List<XFile> galleryImages = [];

  // Image picker function
  Future<void> _selectDepartureDateTime(BuildContext context) async {
    final provider = Provider.of<VendorFlightProvider>(context, listen: false);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        provider.setSelectedDepartureDateTime(combinedDateTime);
      }
    }
  }

  Future<void> _selectArrivalDateTime(BuildContext context) async {
    final provider = Provider.of<VendorFlightProvider>(context, listen: false);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (provider.selectedDepartureDateTime != null &&
            combinedDateTime.isBefore(provider.selectedDepartureDateTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Arrival time cannot be before departure time'.tr)),
          );
        } else {
          provider.setSelectedArrivalDateTime(combinedDateTime);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    Provider.of<VendorFlightProvider>(context, listen: false)
        .flightairlinevendor()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
    print("value of title = ${widget.title}");

    Provider.of<VendorFlightProvider>(context, listen: false)
        .flightairportvendor()
        .then((value) {
      setState(() {
        loading2 = false;
      });
    });
    final provider = Provider.of<VendorFlightProvider>(context, listen: false);
    if (widget.title != null) {
      provider.titlecontroller.text = widget.title ?? "";
      print("Value of title controller = ${widget.title}");
    }
    if (widget.content != null) {
      provider.contentcontroller.text = widget.content ?? "";
    }
    if (widget.data?[0].airportForm?.id != null) {
      provider.flightairportfromid = widget.data?[0].airportForm?.id.toString();
      provider.flightairportfromids =
          widget.data?[0].airportForm?.id.toString();
      print("Value of location id = ${widget.data?[0].airportForm?.id}");
    }
    if (widget.data?[0].airportTo?.id != null) {
      provider.flightairporttoid = widget.data?[0].airportTo?.id.toString();
      provider.flightairporttoids = widget.data?[0].airportTo?.id.toString();
      print(
          "Value of flightairporttoid id = ${widget.data?[0].airportTo?.name}");
    }
    if (widget.data?[0].airline?.id != null) {
      provider.flightairlineid = widget.data?[0].airline?.id.toString();
      provider.flightairlineids = widget.data?[0].airline?.id.toString();
      print("Value of flightairporttoid id = ${widget.data?[0].airline?.name}");
    }
    if (widget.data?[0].departureTime != null) {
      provider.setSelectedDepartureDateTime(
          DateTime.parse(widget.data?[0].departureTime.toString() ?? ""));
    }

    if (widget.data?[0].arrivalTime != null) {
      provider.setSelectedArrivalDateTime(
          DateTime.parse(widget.data?[0].arrivalTime.toString() ?? ''));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorFlightProvider>(context, listen: true);
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
                "Add New Flight".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Image.asset(
              Get.locale?.languageCode == 'ar'
                  ? 'assets/haven/flightlevel1_ar.png'
                  : 'assets/haven/flightlevel1.png',
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                "Content".tr,
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
                "Name".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            CustomTextField(
              hintText: "Title".tr,
              controller: provider.titlecontroller,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                "Code".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            // Content Input
            CustomTextField(
              maxCheck: 5,
              hintText: "Code".tr,
              txKeyboardType: TextInputType.number,
              controller:
                  Provider.of<VendorFlightProvider>(context).contentcontroller,
              /*onSaved: (value) {
                content = value;
              },*/
            ),
            // Youtube Video Input

            Divider(
              thickness: 2,
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10),
              child: Text(
                "Airport".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            // Extra Info
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                bottom: 4,
              ),
              child: Text(
                "From".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
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
                      value: provider.flightairportfromid,
                      hint: Text('Select Airport From'),
                      onChanged: (String? newValue) {
                        setState(() {
                          provider.flightairportfromid = newValue;
                          provider.flightairportfromids = newValue;
                        });
                      },
                      items: provider.flightairportlists?.data!
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
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                "To".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
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
                      value: provider.flightairporttoid,
                      hint: Text('Select Airport To'.tr),
                      onChanged: (String? newValue) {
                        setState(() {
                          provider.flightairporttoid = newValue;
                          provider.flightairporttoids = newValue;
                        });
                      },
                      items: provider.flightairportlists?.data!
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
              height: 10,
            ),
            Divider(
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 10, right: 10),
              child: Text(
                "Airline and Time".tr,
                style: TextStyle(
                    fontFamily: "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 10, right: 10),
              child: Text(
                "Airline".tr,
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
                      value: provider.flightairlineid,
                      hint: Text('Select Airline'.tr),
                      onChanged: (String? newValue) {
                        setState(() {
                          provider.flightairlineid = newValue;
                          provider.flightairlineids = newValue;
                        });
                      },
                      items: provider.flightairlinelists?.data!
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
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 10, right: 10),
              child: Text(
                "Departure Time".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            InkWell(
              onTap: () => _selectDepartureDateTime(context),
              child: Container(
                width: 330,
                height: 54,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Get.isDarkMode ? Colors.white : Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Consumer<VendorFlightProvider>(
                  builder: (context, provider, child) {
                    return provider.selectedDepartureDateTime != null
                        ? Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('yyyy-MM-dd hh:mm a').format(
                                    provider.selectedDepartureDateTime!),
                                style:
                                    const TextStyle(color: Color(0xff1c1c1c)),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(15),
                                child: Text(
                                  "dd-mm-yyyy--:--".tr,
                                  style: TextStyle(
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontFamily: "Mulish",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 10, right: 10),
              child: Text(
                "Arrival Time".tr,
                style: TextStyle(fontFamily: "inter", fontSize: 14),
              ),
            ),
            InkWell(
              onTap: () => _selectArrivalDateTime(context),
              child: Container(
                width: 330,
                height: 54,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Get.isDarkMode ? Colors.white : Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Consumer<VendorFlightProvider>(
                  builder: (context, provider, child) {
                    return provider.selectedArrivalDateTime != null
                        ? Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('yyyy-MM-dd hh:mm a')
                                    .format(provider.selectedArrivalDateTime!),
                                style:
                                    const TextStyle(color: Color(0xff1c1c1c)),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(15),
                                child: Text(
                                  "dd-mm-yyyy--:--".tr,
                                  style: TextStyle(
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontFamily: "Mulish",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          );
                  },
                ),
              ),
            ),

            // Featured Image Upload

            SizedBox(height: 20),
            TertiaryButton(
              press: () {
                final provider =
                    Provider.of<VendorFlightProvider>(context, listen: false);

                if (provider.flightairportfromid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please select departure airport'.tr)),
                  );
                  return;
                }

                if (provider.flightairporttoid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select arrival airport'.tr)),
                  );
                  return;
                }

                if (provider.flightairlineid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select airline'.tr)),
                  );
                  return;
                }

                if (provider.selectedDepartureDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select departure time'.tr)),
                  );
                  return;
                }

                if (provider.selectedArrivalDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select arrival time'.tr)),
                  );
                  return;
                }
                if (provider.titlecontroller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please  filled title '.tr)),
                  );
                  return;
                }
                if (provider.contentcontroller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please filled content'.tr)),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditFlightScreenTwo(
                            terms: widget.terms,
                            id: widget.id,
                          )),
                );
              },
              text: 'Save & Next'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
