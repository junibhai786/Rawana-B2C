// To parse this JSON data, do
//
//     final allTourVendor = allTourVendorFromJson(jsonString);

import 'dart:convert';

AllTourVendorModel allTourVendorFromJson(String str) =>
    AllTourVendorModel.fromJson(json.decode(str));

String allTourVendorToJson(AllTourVendorModel data) =>
    json.encode(data.toJson());

class AllTourVendorModel {
  List<TourDatum>? data;

  AllTourVendorModel({
    this.data,
  });

  factory AllTourVendorModel.fromJson(Map<String, dynamic> json) =>
      AllTourVendorModel(
        data: json["data"] == null
            ? []
            : List<TourDatum>.from(
                json["data"]!.map((x) => TourDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TourDatum {
  int? id;
  String? objectModel;
  String? title;
  String? price;
  dynamic salePrice;
  String? discountPercent;
  String? image;
  String? content;
  String? availablility;
  Location? location;
  dynamic isFeatured;
  dynamic duration;
  bool? isInWishlist;
  List<dynamic>? gallery;
  String? mapLat;
  String? mapLng;
  DateTime? updatedAt;
  String? status;
  ReviewScore? reviewScore;
  String? detailsUrl;

  TourDatum({
    this.id,
    this.objectModel,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.image,
    this.content,
    this.availablility,
    this.location,
    this.isFeatured,
    this.duration,
    this.isInWishlist,
    this.gallery,
    this.mapLat,
    this.mapLng,
    this.updatedAt,
    this.status,
    this.reviewScore,
    this.detailsUrl,
  });

  factory TourDatum.fromJson(Map<String, dynamic> json) => TourDatum(
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
        duration: json["duration"],
        isInWishlist: json["is_in_wishlist"],
        gallery: json["gallery"] == null
            ? []
            : List<dynamic>.from(json["gallery"]!.map((x) => x)),
        mapLat: json["map_lat"],
        mapLng: json["map_lng"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        status: json["status"],
        reviewScore: json["review_score"] == null
            ? null
            : ReviewScore.fromJson(json["review_score"]),
        detailsUrl: json["details_url"],
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
        "duration": duration,
        "is_in_wishlist": isInWishlist,
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "map_lat": mapLat,
        "map_lng": mapLng,
        "updated_at": updatedAt?.toIso8601String(),
        "status": status,
        "review_score": reviewScore?.toJson(),
        "details_url": detailsUrl,
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
  int? scoreTotal;
  int? totalReview;

  ReviewScore({
    this.scoreTotal,
    this.totalReview,
  });

  factory ReviewScore.fromJson(Map<String, dynamic> json) => ReviewScore(
        scoreTotal: json["score_total"],
        totalReview: json["total_review"],
      );

  Map<String, dynamic> toJson() => {
        "score_total": scoreTotal,
        "total_review": totalReview,
      };
}
