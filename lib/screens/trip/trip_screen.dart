import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../data_models/trip_screen_data.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),

              //appbar
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Trips",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Inter'.tr,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.filter_list,
                      size: 22,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 32,
              ),

              ListView.builder(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                shrinkWrap: true,
                itemCount: tripDatas.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return PropertyItem(
                    dataSrc: tripDatas[index],
                    press: () {},
                  );
                },
              )
            ],
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

  final TripData dataSrc;
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
                    style:  TextStyle(
                      fontFamily: 'Inter'.tr,
                      fontSize: 12,
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
                  backgroundColor: Colors.black.withOpacity(0.4),
                  radius: 16,
                  child: const Icon(
                    Icons.favorite_outline,
                    color: Colors.white,
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
                        style:  TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter'.tr,
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
            style:  TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Inter'.tr,
            ),
            maxLines: 1,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            dataSrc.bed,
            style:  TextStyle(fontFamily: 'Inter'.tr, color: kColor1),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            dataSrc.date,
            style:  TextStyle(fontFamily: 'Inter'.tr, color: kColor1),
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              const Text(
                "Total ",
                style: TextStyle(color: kColor1),
              ),
              Text(
                "\$ ${dataSrc.price}",
                style:  TextStyle(
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 36,
          ),
        ],
      ),
    );
  }
}
