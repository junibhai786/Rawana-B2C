//search result data model

class TripData {
  final String image, propertyName, bed, date;
  final double rating;
  final int price;
  String tag;

  TripData({
    required this.propertyName,
    required this.image,
    required this.bed,
    required this.rating,
    required this.tag,
    required this.date,
    required this.price,
  });
}

List<TripData> tripDatas = [
  TripData(
    image: "assets/haven/resort_2.jpg",
    propertyName: "Santorini, Greece",
    bed: "Single Bed",
    date: "Scheduled for Feb 14 - 20",
    rating: 4.8,
    tag: "Booked",
    price: 399,
  ),
  TripData(
    image: "assets/haven/resort_3.jpg",
    propertyName: "Maui, Hawaii",
    bed: "Double Bed",
    date: "Scheduled for Mar 8 - 15",
    rating: 4.5,
    tag: "Booked",
    price: 579,
  ),
  TripData(
    image: "assets/haven/resort_4.jpg",
    propertyName: "Queenstown, New Zealand",
    bed: "Single Bed",
    date: "Apr 5 - 12",
    rating: 4.2,
    tag: "Completed",
    price: 499,
  ),
  TripData(
    image: "assets/haven/resort_5.jpg",
    propertyName: "Bora Bora, French Polynesia",
    bed: "Double Bed",
    date: "May 22 - 28",
    rating: 4.9,
    tag: "Completed",
    price: 899,
  ),
  TripData(
    image: "assets/haven/resort_1.jpg",
    propertyName: "Nusapenida, Indonesia",
    bed: "Double Bed",
    date: "Jan 1 - 6",
    rating: 5.0,
    tag: "Completed",
    price: 234,
  ),
];
