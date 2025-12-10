// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../hotel/room_detail_screen.dart';
import '../../constants.dart';
import '../../data_models/whislist_details_screen_data.dart';

class WishlistDetailsScreen extends StatelessWidget {
  const WishlistDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.share,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.more_vert,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Honey Moon".tr,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text("Nov 17 - 30".tr),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text("2 guests".tr),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),

                // property list

                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: savedPropertyDatas.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PropertyItem(
                      dataSrc: savedPropertyDatas[index],
                      press: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailScreen(
                            hotelId: 3,
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Property item widget builder

class PropertyItem extends StatelessWidget {
  const PropertyItem({
    super.key,
    required this.dataSrc,
    required this.press,
  });

  final SavedPropertyData dataSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    dataSrc.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              //badge
              Visibility(
                visible: dataSrc.tag.isNotEmpty,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 12,
                    left: 12,
                  ),
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 12,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    dataSrc.tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              //fav button
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.1),
                  radius: 16,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pinkAccent,
                    size: 18,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 6,
                    right: 8,
                    top: 2,
                    bottom: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${dataSrc.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            dataSrc.propertyName,
            style: TextStyle(
              fontFamily: 'Inter'.tr,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            dataSrc.bed,
            style: TextStyle(fontFamily: 'Inter'.tr, color: kColor1),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "Saved for ${dataSrc.date}".tr,
            style: TextStyle(fontFamily: 'Inter'.tr, color: kColor1),
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Text(
                "\$ ${dataSrc.price}".tr,
                style: TextStyle(
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                " /night".tr,
                style: TextStyle(fontFamily: 'Inter'.tr, color: kColor1),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "Add a note".tr,
            style: TextStyle(
              color: kColor1,
              fontFamily: 'Inter'.tr,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(
            height: 36,
          ),
        ],
      ),
    );
  }
}
