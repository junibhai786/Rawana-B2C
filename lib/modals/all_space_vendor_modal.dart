// lib/models/space_model.dart

class SpaceVendorList {
  final List<SpaceVendor> data;

  SpaceVendorList({required this.data});

  factory SpaceVendorList.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<SpaceVendor> spaceVendors =
        list.map((i) => SpaceVendor.fromJson(i)).toList();

    return SpaceVendorList(data: spaceVendors);
  }
}

class SpaceVendor {
  final int id;
  final String objectModel;
  final String title;
  final String price;
  final String salePrice;
  final List<String> gallery;
  final String discountPercent;
  final String image;
  final String content;
  final String updatedat;
  final String availability_url;
  final String status;
  final LocationSpaceVendor location;
  final bool? isFeatured;
  final int? maxGuests;
  final int? bed;
  final int? bathroom;
  final int? square;
  final ReviewScoreSpaceVendor? reviewScore;
  final String? detailsUrl;
  bool? isInWishlist;

  SpaceVendor(
      {required this.id,
      required this.objectModel,
      required this.updatedat,
      required this.title,
      required this.status,
      required this.availability_url,
      required this.gallery,
      required this.price,
      required this.salePrice,
      required this.discountPercent,
      required this.image,
      required this.content,
      required this.location,
      this.isFeatured,
      this.maxGuests,
      this.bed,
      this.bathroom,
      this.square,
      this.reviewScore,
      this.detailsUrl,
      required this.isInWishlist});

  factory SpaceVendor.fromJson(Map<String, dynamic> json) {
    return SpaceVendor(
      id: json['id'],
      objectModel: json['object_model'],
      title: json['title'] ?? "",
      updatedat: json['updated_at'],
      availability_url: json['availability_url'],
      status: json['status'],
      price: json['price'] ?? "",
      salePrice: json['sale_price'] ?? "",
      discountPercent: json['discount_percent'] ?? "",
      image: json['image'] ?? "",
      gallery: List<String>.from(json['gallery'] ?? []),
      content: json['content'],
      location: LocationSpaceVendor.fromJson(json['location']),
      isFeatured: json['is_featured'],
      maxGuests: json['max_guests'] ?? 0,
      bed: json['bed'],
      bathroom: json['bathroom'],
      square: json['square'] ?? 0,
      reviewScore: ReviewScoreSpaceVendor.fromJson(json['review_score']),
      detailsUrl: json['details_url'],
      isInWishlist: json['is_in_wishlist'],
    );
  }
}

class LocationSpaceVendor {
  final int id;
  final String name;

  LocationSpaceVendor({
    required this.id,
    required this.name,
  });

  factory LocationSpaceVendor.fromJson(Map<String, dynamic> json) {
    return LocationSpaceVendor(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ReviewScoreSpaceVendor {
  final int scoreTotal;
  final int totalReview;
  final String reviewText;

  ReviewScoreSpaceVendor({
    required this.scoreTotal,
    required this.totalReview,
    required this.reviewText,
  });

  factory ReviewScoreSpaceVendor.fromJson(Map<String, dynamic> json) {
    return ReviewScoreSpaceVendor(
      scoreTotal: json['score_total'],
      totalReview: json['total_review'],
      reviewText: json['review_text'],
    );
  }
}
