// class EventModalForVendor {
//   String message;
//   List<EventForVendor> data;

//   EventModalForVendor({required this.message, required this.data});

//   // Method to convert JSON to SpaceDetails
//   EventModalForVendor.fromJson(Map<String, dynamic> json)
//       : message = json['message']??"",
//         data = List<EventForVendor>.from(
//             json['data'].map((item) => EventForVendor.fromJson(item)));
// }

class EventModalForVendor {
  final List<EventForVendor> data;

  EventModalForVendor({required this.data});

  factory EventModalForVendor.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<EventForVendor> spaceVendors =
        list.map((i) => EventForVendor.fromJson(i)).toList();

    return EventModalForVendor(data: spaceVendors);
  }
}

class EventForVendor {
  final int id;
  final String objectModel;
  final String title;
  final dynamic price;
  final dynamic salePrice;
  final String discountPercent;
  final String image;
  final String content;
  final Location location;
  final int? isFeatured;
  final String duration;
  final String startTime;
  final availablility;
  final List<String> gallery; // New field
  final String detailsUrl;
  final String updatedAt; // New field
  final String status; // New field
  final ReviewScore reviewScore;
  bool isInWishlist;

  EventForVendor({
    required this.id,
    required this.availablility,
    required this.objectModel,
    required this.title,
    required this.price,
    required this.salePrice,
    required this.discountPercent,
    required this.image,
    required this.content,
    required this.location,
    this.isFeatured,
    required this.duration,
    required this.startTime,
    required this.gallery, // New field
    required this.detailsUrl,
    required this.updatedAt, // New field
    required this.status, // New field
    required this.reviewScore,
    required this.isInWishlist,
  });

  // Method to create an Event instance from a JSON map
  static EventForVendor fromJson(Map<String, dynamic> json) {
    return EventForVendor(
      id: json['id'],
      objectModel: json['object_model'],
      title: json['title'],
      price: json['price'],
      availablility: json['availability_url'],
      salePrice: json['sale_price'],
      discountPercent: json['discount_percent'] ?? "",
      image: json['image'],
      content: json['content'],
      location: Location.fromJson(json['location']),
      isFeatured: json['is_featured'],
      duration: json['duration'] ?? "",
      startTime: json['start_time'] ?? "",
      gallery: List<String>.from(json['gallery']), // New field
      detailsUrl: json['details_url'],
      updatedAt: json['updated_at'],
      status: json['status'], // New field
      reviewScore: ReviewScore.fromJson(json['review_score']),
      isInWishlist: json['is_in_wishlist'] ?? false,
    );
  }
}

class Location {
  final int id;
  final String name;

  Location({
    required this.id,
    required this.name,
  });

  static Location fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ReviewScore {
  final int scoreTotal;
  final int totalReview;
  final String reviewText;

  ReviewScore({
    required this.scoreTotal,
    required this.totalReview,
    required this.reviewText,
  });

  static ReviewScore fromJson(Map<String, dynamic> json) {
    return ReviewScore(
      scoreTotal: json['score_total'],
      totalReview: json['total_review'],
      reviewText: json['review_text'],
    );
  }
}
