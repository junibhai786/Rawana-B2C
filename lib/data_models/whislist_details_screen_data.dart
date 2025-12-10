//property data model

class SavedPropertyData {
  final String image, propertyName, bed, date;
  final double rating;
  final int price;
  String tag;

  SavedPropertyData({
    required this.propertyName,
    required this.image,
    required this.bed,
    required this.rating,
    required this.tag,
    required this.date,
    required this.price,
  });
}

List<SavedPropertyData> savedPropertyDatas = [
  SavedPropertyData(
    image: "assets/haven/resort_5.jpg",
    propertyName: "Bora Bora, French Polynesia",
    bed: "1 double bed",
    date: "May 22 - 28",
    rating: 4.9,
    tag: "Overwater bungalows",
    price: 899,
  ),
  SavedPropertyData(
    image: "assets/haven/resort_2.jpg",
    propertyName: "Santorini, Greece",
    bed: "2 double bed",
    date: "Feb 14 - 20",
    rating: 4.8,
    tag: "Luxury getaway",
    price: 399,
  ),
  SavedPropertyData(
    image: "assets/haven/resort_1.jpg",
    propertyName: "Nusapenida, Indonesia",
    bed: "1 double bed",
    date: "Jan 1 - 6",
    rating: 5.0,
    tag: "Guest favorite",
    price: 234,
  ),
  SavedPropertyData(
    image: "assets/haven/resort_3.jpg",
    propertyName: "Maui, Hawaii",
    bed: "2 single beds",
    date: "Mar 8 - 15",
    rating: 4.5,
    tag: "Beachfront paradise",
    price: 579,
  ),
  SavedPropertyData(
    image: "assets/haven/resort_4.jpg",
    propertyName: "Queenstown, New Zealand",
    bed: "1 double bed",
    date: "Apr 5 - 12",
    rating: 4.2,
    tag: "Adventure retreat",
    price: 499,
  ),
];
