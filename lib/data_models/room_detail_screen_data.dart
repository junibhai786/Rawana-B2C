import 'package:flutter/material.dart';

//appbar slider data

class AppbarSliderData {
  final String image;

  AppbarSliderData({
    required this.image,
  });
}

List<AppbarSliderData> appbarSliderDatas = [
  AppbarSliderData(
    image: "assets/haven/resort_1.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_2.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_3.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_4.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_5.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_6.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_7.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_8.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_9.jpg",
  ),
  AppbarSliderData(
    image: "assets/haven/resort_10.jpg",
  ),
];

//room specs

class RoomSpecsData {
  final String title, subtitle;
  final IconData kIcon;

  RoomSpecsData({
    required this.title,
    required this.subtitle,
    required this.kIcon,
  });
}

List<RoomSpecsData> roomSpecsDatas = [
  RoomSpecsData(
    kIcon: Icons.bed_outlined,
    title: "Room in a cave",
    subtitle:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
  ),
  RoomSpecsData(
    kIcon: Icons.workspaces_outline,
    title: "Dedicated workspace",
    subtitle:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
  ),
  RoomSpecsData(
    kIcon: Icons.social_distance_outlined,
    title: "Shared common spaces",
    subtitle:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
  ),
  RoomSpecsData(
    kIcon: Icons.hot_tub_outlined,
    title: "Private attached bathroom",
    subtitle:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
  ),
];

//room Offers

class OfferData {
  final String title;
  final IconData kIcon;

  OfferData({
    required this.title,
    required this.kIcon,
  });
}

List<OfferData> offerDatas = [
  OfferData(
    kIcon: Icons.watch,
    title: "Lock on bedroom door",
  ),
  OfferData(
    kIcon: Icons.yard_outlined,
    title: "Valley view",
  ),
  OfferData(
    kIcon: Icons.spa_outlined,
    title: "Garden view",
  ),
  OfferData(
    kIcon: Icons.wifi_outlined,
    title: "Wifi 100 Mbps",
  ),
  OfferData(
    kIcon: Icons.workspaces_outline,
    title: "Dedicated workspace",
  ),
  OfferData(
    kIcon: Icons.alarm,
    title: "Smoke alarm",
  ),
];

//Review Data

class ReviewData {
  final String avatar, name, date, content, location;
  final double rating;

  ReviewData({
    required this.avatar,
    required this.date,
    required this.rating,
    required this.content,
    required this.name,
    required this.location,
  });
}

List<ReviewData> reviewDatas = [
  ReviewData(
    rating: 4.8,
    avatar: "assets/haven/avatar_3.jpg",
    name: "David C.",
    date: "2 weeks ago",
    content:
        "Jawir is an exceptional host, very kind. The place is exactly as she advertised and close to the city center. Highly recommended! ",
    location: "Los Altos, United States",
  ),
  ReviewData(
    rating: 4.5,
    avatar: "assets/haven/avatar_4.jpg",
    name: "Sarah W.",
    date: "3 weeks ago",
    content:
        "I had a wonderful stay at Jawir's place. The location is perfect, and the host is friendly and helpful. I would definitely come back!",
    location: "San Francisco, United States",
  ),
  ReviewData(
    rating: 5.0,
    avatar: "assets/haven/avatar_5.jpg",
    name: "Alex M.",
    date: "1 month ago",
    content:
        "Outstanding hospitality and a beautiful place. Jawir goes above and beyond to make guests feel comfortable. I enjoyed every moment of my stay!",
    location: "Palo Alto, United States",
  ),
  ReviewData(
    rating: 4.2,
    avatar: "assets/haven/avatar_10.jpg",
    name: "Maria G.",
    date: "2 months ago",
    content:
        "Great experience! The room was clean and cozy, and Jawir was very accommodating. The neighborhood is quiet, and the city center is easily accessible.",
    location: "Mountain View, United States",
  ),
  ReviewData(
    rating: 4.7,
    avatar: "assets/haven/avatar_8.jpg",
    name: "John K.",
    date: "3 months ago",
    content:
        "I highly recommend Jawir's place. The atmosphere is welcoming, and the location is convenient. I had a pleasant stay and would return in the future.",
    location: "Sunnyvale, United States",
  ),
];
