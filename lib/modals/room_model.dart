
class RoomResponse {
  final List<Room> rooms;
  final int status;

  RoomResponse({required this.rooms, required this.status});

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    return RoomResponse(
      rooms:
          (json['rooms'] as List).map((room) => Room.fromJson(room)).toList(),
      status: json['status'],
    );
  }
}

class Room {
  final int id;
  final String title;
  final double price;
  final String sizeHtml;
  final String bedsHtml;
  final String adultsHtml;
  final String childrenHtml;
  final int numberSelected;
  final int number;
  final int minDayStays;
  final String image;
  final List<Gallery> gallery;
  final String priceHtml;
  final String priceText;
  final List<TermFeature> termFeatures;
  final int? maxAdults;
  final int? maxChildren;
  final String? viewType;

  Room({
    required this.id,
    required this.title,
    required this.price,
    required this.sizeHtml,
    required this.bedsHtml,
    required this.adultsHtml,
    required this.childrenHtml,
    required this.numberSelected,
    required this.number,
    required this.minDayStays,
    required this.image,
    required this.gallery,
    required this.priceHtml,
    required this.priceText,
    required this.termFeatures,
    this.maxAdults,
    this.maxChildren,
    this.viewType,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      sizeHtml: json['size_html'],
      bedsHtml: json['beds_html'],
      adultsHtml: json['adults_html'],
      childrenHtml: json['children_html'],
      numberSelected: json['number_selected'],
      number: json['number'],
      minDayStays: json['min_day_stays'],
      image: json['image'],
      gallery: (json['gallery'] as List)
          .map((item) => Gallery.fromJson(item))
          .toList(),
      priceHtml: json['price_html'],
      priceText: json['price_text'],
      termFeatures: (json['term_features'] as List)
          .map((item) => TermFeature.fromJson(item))
          .toList(),
      maxAdults: json['max_adults'],
      maxChildren: json['max_children'],
      viewType: json['view_type'],
    );
  }
}

class Gallery {
  final String large;
  final String thumb;

  Gallery({required this.large, required this.thumb});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      large: json['large'],
      thumb: json['thumb'],
    );
  }
}

class TermFeature {
  final String icon;
  final String title;

  TermFeature({required this.icon, required this.title});

  factory TermFeature.fromJson(Map<String, dynamic> json) {
    return TermFeature(
      icon: json['icon'],
      title: json['title'],
    );
  }
}
