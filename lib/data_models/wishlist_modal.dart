
class WishlistResponse {
  final List<WishlistItem> data;
  final int total;
  final int totalPages;

  WishlistResponse({
    required this.data,
    required this.total,
    required this.totalPages,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      data: (json['data'] as List)
          .map((item) => WishlistItem.fromJson(item))
          .toList(),
      total: json['total'],
      totalPages: json['total_pages'],
    );
  }
}

class WishlistItem {
  final int id;
  final int objectId;
  final String objectModel;
  final int userId;
  final int createUser;
  final int? updateUser;
  final String createdAt;
  final String updatedAt;
  final Service service;

  WishlistItem({
    required this.id,
    required this.objectId,
    required this.objectModel,
    required this.userId,
    required this.createUser,
    this.updateUser,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      objectId: json['object_id'],
      objectModel: json['object_model'],
      userId: json['user_id'],
      createUser: json['create_user'],
      updateUser: json['update_user'] ?? 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      service: Service.fromJson(json['service']),
    );
  }
}

class Service {
  final int id;
  final String title;
  final String price;
  final String? salePrice;
  final String? discountPercent;
  final String image;
  final String content;

  final int? isFeatured;
  final String serviceIcon;
  final ReviewScore reviewScore;
  final String serviceType;

  Service({
    required this.id,
    required this.title,
    required this.price,
    this.salePrice,
    this.discountPercent,
    required this.image,
    required this.content,
    this.isFeatured,
    required this.serviceIcon,
    required this.reviewScore,
    required this.serviceType,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      salePrice: json['sale_price'],
      discountPercent: json['discount_percent'],
      image: json['image'],
      content: json['content'],
      isFeatured: json['is_featured'] ?? 0,
      serviceIcon: json['service_icon'],
      reviewScore: ReviewScore.fromJson(json['review_score']),
      serviceType: json['service_type'],
    );
  }
}

class ReviewScore {
  final dynamic scoreTotal;
  final int totalReview;
  final String reviewText;

  ReviewScore({
    required this.scoreTotal,
    required this.totalReview,
    required this.reviewText,
  });

  factory ReviewScore.fromJson(Map<String, dynamic> json) {
    return ReviewScore(
      scoreTotal: json['score_total'],
      totalReview: json['total_review'] ?? 0,
      reviewText: json['review_text'] ?? "",
    );
  }
}
