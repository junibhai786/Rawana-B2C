//search result data model

class SearchResultData {
  final String image, propertyName, distance, date;
  final double rating;
  final int price;
  String tag;

  SearchResultData({
    required this.propertyName,
    required this.image,
    required this.distance,
    required this.rating,
    required this.tag,
    required this.date,
    required this.price,
  });
}

List<SearchResultData> searchResultDatas = [
  SearchResultData(
    image: "assets/haven/resort_1.jpg",
    propertyName: "Nusapenida, Indonesia",
    distance: "987 kilometers away",
    date: "Jan 1 - 6",
    rating: 5.0,
    tag: "Guest favorite",
    price: 234,
  ),
  SearchResultData(
    image: "assets/haven/resort_2.jpg",
    propertyName: "Santorini, Greece",
    distance: "1,543 kilometers away",
    date: "Feb 14 - 20",
    rating: 4.8,
    tag: "Luxury getaway",
    price: 399,
  ),
  SearchResultData(
    image: "assets/haven/resort_3.jpg",
    propertyName: "Maui, Hawaii",
    distance: "7,831 kilometers away",
    date: "Mar 8 - 15",
    rating: 4.5,
    tag: "Beachfront paradise",
    price: 579,
  ),
  SearchResultData(
    image: "assets/haven/resort_4.jpg",
    propertyName: "Queenstown, New Zealand",
    distance: "8,205 kilometers away",
    date: "Apr 5 - 12",
    rating: 4.2,
    tag: "Adventure retreat",
    price: 499,
  ),
  SearchResultData(
    image: "assets/haven/resort_5.jpg",
    propertyName: "Bora Bora, French Polynesia",
    distance: "15,276 kilometers away",
    date: "May 22 - 28",
    rating: 4.9,
    tag: "Overwater bungalows",
    price: 899,
  ),
];
