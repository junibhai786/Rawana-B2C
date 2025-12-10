class HotelSearch {
  int? total;
  int? totalPages;
  List<Data>? data;
  int? status;

  HotelSearch({this.total, this.totalPages, this.data, this.status});

  HotelSearch.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    totalPages = json['total_pages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['total_pages'] = this.totalPages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class Data {
  int? id;
  String? objectModel;
  String? title;
  dynamic price;
  dynamic salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  Location? location;
  dynamic isFeatured;
  bool? isInWishlist;
  List<String>? gallery;
  String? mapLat;
  String? mapLng;
  ReviewScore? reviewScore;

  Data(
      {this.id,
      this.objectModel,
      this.title,
      this.price,
      this.salePrice,
      this.discountPercent,
      this.image,
      this.content,
      this.location,
      this.isFeatured,
      this.isInWishlist,
      this.gallery,
      this.mapLat,
      this.mapLng,
      this.reviewScore});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    objectModel = json['object_model'];
    title = json['title'];
    price = json['price'];
    salePrice = json['sale_price'];
    discountPercent = json['discount_percent'];
    image = json['image'];
    content = json['content'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    isFeatured = json['is_featured'];
    isInWishlist = json['is_in_wishlist'];
    gallery = json['gallery'].cast<String>();
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    reviewScore = json['review_score'] != null
        ? new ReviewScore.fromJson(json['review_score'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['object_model'] = this.objectModel;
    data['title'] = this.title;
    data['price'] = this.price;
    data['sale_price'] = this.salePrice;
    data['discount_percent'] = this.discountPercent;
    data['image'] = this.image;
    data['content'] = this.content;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['is_featured'] = this.isFeatured;
    data['is_in_wishlist'] = this.isInWishlist;
    data['gallery'] = this.gallery;
    data['map_lat'] = this.mapLat;
    data['map_lng'] = this.mapLng;
    if (this.reviewScore != null) {
      data['review_score'] = this.reviewScore!.toJson();
    }
    return data;
  }
}

class Location {
  int? id;
  String? name;

  Location({this.id, this.name});

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class ReviewScore {
  String? scoreTotal;
  int? totalReview;
  String? reviewText;

  ReviewScore({this.scoreTotal, this.totalReview, this.reviewText});

  ReviewScore.fromJson(Map<String, dynamic> json) {
    scoreTotal = json['score_total'];
    totalReview = json['total_review'];
    reviewText = json['review_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['score_total'] = this.scoreTotal;
    data['total_review'] = this.totalReview;
    data['review_text'] = this.reviewText;
    return data;
  }
}
