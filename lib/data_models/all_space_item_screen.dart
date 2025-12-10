import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/modals/all_space_vendor_modal.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/Imagecarouselwithdots.dart';
import 'package:moonbnd/modals/car_list_model.dart';

// ignore: must_be_immutable
class AllSpaceScreenItem extends StatefulWidget {
  AllSpaceScreenItem({
    super.key,
    required this.dataSrc,
    required this.press,
    this.managecar,
    CarList? carList,
  });
  final bool? managecar;
  SpaceVendor dataSrc;
  final VoidCallback press;

  @override
  State<AllSpaceScreenItem> createState() => _CarDataItemState();
}

class _CarDataItemState extends State<AllSpaceScreenItem> {
  bool loading = false;
  String formatTimestamp(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp);
    String formattedDate = DateFormat('MM/dd/yyyy HH:mm').format(parsedDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final spaceProvider = Provider.of<SpaceProvider>(context, listen: true);

    return GestureDetector(
      onTap: widget.press,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: kColor1,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ImageCarouselWithDots(images: widget.dataSrc.gallery),

                // Positioned(
                //   bottom: 8,
                //   left: 8,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     child: Row(
                //       children: List.generate(
                //         5,
                //         (index) => Icon(
                //           index < dataSrc.rating
                //               ? Icons.star
                //               : Icons.star_border,
                //           color: flutterpads,
                //           size: 20,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dataSrc.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter'.tr,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Price : ".tr,
                                style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  fontWeight: FontWeight.w500,
                                  decorationThickness: 1.5,
                                  decorationColor: Colors.black,
                                ),
                              ),
                              Text(
                                "\$${widget.dataSrc.price}",
                                style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w200,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                              // Text(
                              //   "/day".tr,
                              //   style: TextStyle(
                              //     color: darkgrey,
                              //     fontFamily: 'Inter'.tr,
                              //     decoration: TextDecoration.underline,
                              //     decorationThickness: 1.5,
                              //     decorationColor: Colors.black,
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Status : ".tr,
                                style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  fontWeight: FontWeight.w500,
                                  decorationThickness: 1.5,
                                  decorationColor: Colors.black,
                                ),
                              ),
                              Container(
                                height: 25,
                                decoration: BoxDecoration(
                                    color: kSecondaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 3),
                                  child: Text(
                                    "${widget.dataSrc.status} ",
                                    style: TextStyle(
                                      fontFamily: 'Inter'.tr,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w200,
                                      decorationColor: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              // Text(
                              //   "/day".tr,
                              //   style: TextStyle(
                              //     color: darkgrey,
                              //     fontFamily: 'Inter'.tr,
                              //     decoration: TextDecoration.underline,
                              //     decorationThickness: 1.5,
                              //     decorationColor: Colors.black,
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Last Updated : ".tr,
                                style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  fontWeight: FontWeight.w500,
                                  decorationThickness: 1.5,
                                  decorationColor: Colors.black,
                                ),
                              ),

                              Text(
                                formatTimestamp(widget.dataSrc.updatedat),
                                style: TextStyle(
                                  fontFamily: 'Inter'.tr,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w200,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                              // Text(
                              //   "/day".tr,
                              //   style: TextStyle(
                              //     color: darkgrey,
                              //     fontFamily: 'Inter'.tr,
                              //     decoration: TextDecoration.underline,
                              //     decorationThickness: 1.5,
                              //     decorationColor: Colors.black,
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         CarRentalDetailsScreen(
                                    //             carId: widget.dataSrc.id),
                                    //   ),
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff17A2B8)),
                                  child: Text("View"),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // homeProvider
                                    //     .deletevendorcar(
                                    //         id: widget.dataSrc.id.toString())
                                    //     .then(
                                    //   (value) {
                                    //     if (value == true) {
                                    //       homeProvider
                                    //           .fetchCarvendorDetails();
                                    //     }
                                    //   },
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xffFFC107)),
                                  child: Text("Edit"),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         CarRentalDetailsScreen(
                                    //             carId: widget.dataSrc.id),
                                    //   ),
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff1A2B47)),
                                  child: Text("Clone"),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    spaceProvider
                                        .deleteVendorSpace(
                                            id: widget.dataSrc.id.toString())
                                        .then(
                                      (value) async {
                                        if (value == true) {
                                          await spaceProvider
                                              .fetchSpaceVendorDetails();
                                        }
                                      },
                                    ).then((value) {
                                      setState(() {
                                        loading = false;
                                      });
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text("Delete"),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          )
                          //     // Text(
                          //     //   "/day".tr,
                          //     //   style: TextStyle(
                          //     //     color: darkgrey,
                          //     //     fontFamily: 'Inter'.tr,
                          //     //     decoration: TextDecoration.underline,
                          //     //     decorationThickness: 1.5,
                          //     //     decorationColor: Colors.black,
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         const Icon(
                  //           Icons.star,
                  //           color: Colors.black,
                  //           size: 14,
                  //         ),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           '${dataSrc.door}',
                  //           style: const TextStyle(
                  //             color: kPrimaryColor,
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     const SizedBox(height: 2),
                  //     Text(
                  //       '${dataSrc.gear} reviews'.tr,
                  //       style: TextStyle(
                  //         fontSize: 10,
                  //         fontFamily: 'Inter'.tr,
                  //         color: darkgrey,
                  //       ),
                  //     ),
                  //     SizedBox(height: 2),
                  //     Text(
                  //       '5 hours'.tr,
                  //       style: TextStyle(
                  //         fontSize: 10,
                  //         fontFamily: 'Inter'.tr,
                  //         color: darkgrey,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 36,
            ),
          ],
        ),
      ),
    );
  }
}
