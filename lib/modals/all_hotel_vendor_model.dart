// To parse this JSON data, do
//
//     final allHotelVendorModel = allHotelVendorModelFromJson(jsonString);

import 'dart:convert';

AllHotelVendorModel allHotelVendorModelFromJson(String str) =>
    AllHotelVendorModel.fromJson(json.decode(str));

String allHotelVendorModelToJson(AllHotelVendorModel data) =>
    json.encode(data.toJson());

class AllHotelVendorModel {
  List<HDatum>? data;

  AllHotelVendorModel({
    this.data,
  });

  factory AllHotelVendorModel.fromJson(Map<String, dynamic> json) =>
      AllHotelVendorModel(
        data: json["data"] == null
            ? []
            : List<HDatum>.from(json["data"]!.map((x) => HDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HDatum {
  int? id;
  String? objectModel;
  String? title;
  String? price;
  dynamic salePrice;
  String? discountPercent;
  String? image;
  String? availablility;
  String? content;
  Location? location;
  dynamic isFeatured;
  bool? isInWishlist;
  List<String?>? gallery;
  dynamic mapLat;
  dynamic mapLng;
  DateTime? updatedAt;
  String? status;
  String? detailsUrl;
  ReviewScore? reviewScore;

  HDatum({
    this.id,
    this.objectModel,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.availablility,
    this.image,
    this.content,
    this.location,
    this.isFeatured,
    this.isInWishlist,
    this.gallery,
    this.mapLat,
    this.mapLng,
    this.updatedAt,
    this.status,
    this.detailsUrl,
    this.reviewScore,
  });

  factory HDatum.fromJson(Map<String, dynamic> json) => HDatum(
        id: json["id"],
        objectModel: json["object_model"],
        title: json["title"],
        price: json["price"],
        salePrice: json["sale_price"],
        availablility: json["availability_url"],
        discountPercent: json["discount_percent"],
        image: json["image"],
        content: json["content"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        isFeatured: json["is_featured"],
        isInWishlist: json["is_in_wishlist"],
        gallery: json["gallery"] == null
            ? []
            : List<String?>.from(json["gallery"]!.map((x) => x)),
        mapLat: json["map_lat"],
        mapLng: json["map_lng"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        status: json["status"],
        detailsUrl: json["details_url"],
        reviewScore: json["review_score"] == null
            ? null
            : ReviewScore.fromJson(json["review_score"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object_model": objectModel,
        "title": title,
        "price": price,
        "sale_price": salePrice,
        "discount_percent": discountPercent,
        "image": image,
        "content": content,
        "location": location?.toJson(),
        "is_featured": isFeatured,
        "is_in_wishlist": isInWishlist,
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "map_lat": mapLat,
        "map_lng": mapLng,
        "updated_at": updatedAt?.toIso8601String(),
        "status": status,
        "details_url": detailsUrl,
        "review_score": reviewScore?.toJson(),
      };
}

class Location {
  int? id;
  String? name;

  Location({
    this.id,
    this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class ReviewScore {
  dynamic scoreTotal;
  int? totalReview;
  String? reviewText;

  ReviewScore({
    this.scoreTotal,
    this.totalReview,
    this.reviewText,
  });

  factory ReviewScore.fromJson(Map<String, dynamic> json) => ReviewScore(
        scoreTotal: json["score_total"],
        totalReview: json["total_review"],
        reviewText: json["review_text"],
      );

  Map<String, dynamic> toJson() => {
        "score_total": scoreTotal,
        "total_review": totalReview,
        "review_text": reviewText,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
