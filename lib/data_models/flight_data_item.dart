import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moonbnd/constants.dart';

import 'package:moonbnd/data_models/home_screen_data.dart';

class FlightItem extends StatelessWidget {
  const FlightItem({
    super.key,
    required this.dataSrc,
    required this.press,
  });

  final FlightData dataSrc;
  final VoidCallback press;
  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
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
                Image.network(
                  dataSrc.images,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/banner.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    );
                  },
                ),
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
                        dataSrc.propertyName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter'.tr,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Take off',
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: darkgrey,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            DateFormat('EEE MMM dd h:mm a')
                                .format(DateTime.parse(dataSrc.departure)),
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: darkgrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Landing',
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: darkgrey,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            DateFormat('EEE MMM dd h:mm a')
                                .format(DateTime.parse(dataSrc.arrival)),
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              color: darkgrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "from ".tr,
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.5,
                              decorationColor: Colors.black,
                            ),
                          ),
                          Text(
                            "\$${dataSrc.price}",
                            style: TextStyle(
                              fontFamily: 'Inter'.tr,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.5,
                              decorationColor: Colors.black,
                            ),
                          ),
                          Text(
                            "/night".tr,
                            style: TextStyle(
                              color: darkgrey,
                              fontFamily: 'Inter'.tr,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.5,
                              decorationColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
