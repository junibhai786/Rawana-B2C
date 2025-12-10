//Wishlish Item Data

import 'package:get/get.dart';

class WishlistItemData {
  final String image, title;
  final int wishlistAmount;

  WishlistItemData({
    required this.image,
    required this.title,
    required this.wishlistAmount,
  });
}

List<WishlistItemData> wishlistItemDatas = [
  WishlistItemData(
    image: "assets/haven/resort_1.jpg",
    title: "Tropical".tr,
    wishlistAmount: 5,
  ),
  WishlistItemData(
    image: "assets/haven/resort_2.jpg",
    title: "Honey Moon".tr,
    wishlistAmount: 4,
  ),
  WishlistItemData(
    image: "assets/haven/resort_3.jpg",
    title: "Bali 2023".tr,
    wishlistAmount: 7,
  ),
  WishlistItemData(
    image: "assets/haven/resort_4.jpg",
    title: "Turkiye".tr,
    wishlistAmount: 6,
  ),
  WishlistItemData(
    image: "assets/haven/resort_5.jpg",
    title: "Japan 2024".tr,
    wishlistAmount: 6,
  ),
  WishlistItemData(
    image: "assets/haven/resort_6.jpg",
    title: "Europe".tr,
    wishlistAmount: 4,
  ),
  WishlistItemData(
    image: "assets/haven/resort_7.jpg",
    title: "Umroh".tr,
    wishlistAmount: 8,
  ),
  WishlistItemData(
    image: "assets/haven/resort_8.jpg",
    title: "Beach".tr,
    wishlistAmount: 5,
  ),
];
