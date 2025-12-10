// To parse this JSON data, do
//
//     final allBoatVendorModel = allBoatVendorModelFromJson(jsonString);

import 'dart:convert';

AllBoatVendorModel allBoatVendorModelFromJson(String str) =>
    AllBoatVendorModel.fromJson(json.decode(str));

String allBoatVendorModelToJson(AllBoatVendorModel data) =>
    json.encode(data.toJson());

class AllBoatVendorModel {
  String? message;
  List<ABDatum>? data;

  AllBoatVendorModel({
    this.message,
    this.data,
  });

  factory AllBoatVendorModel.fromJson(Map<String, dynamic> json) =>
      AllBoatVendorModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ABDatum>.from(json["data"]!.map((x) => ABDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ABDatum {
  int? id;
  String? objectModel;
  String? title;
  String? price;
  int? salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  Location? location;
  dynamic isFeatured;
  dynamic maxGuest;
  int? cabin;
  String? length;
  String? speed;
  DateTime? updatedAt;
  ReviewScore? reviewScore;

  String? status;
  String? availability_url;
  String? detailsUrl;
  bool? isInWishlist;

  ABDatum({
    this.id,
    this.objectModel,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.image,
    this.content,
    this.availability_url,
    this.location,
    this.isFeatured,
    this.maxGuest,
    this.cabin,
    this.length,
    this.speed,
    this.updatedAt,
    this.reviewScore,
    this.status,
    this.detailsUrl,
    this.isInWishlist,
  });

  factory ABDatum.fromJson(Map<String, dynamic> json) => ABDatum(
        id: json["id"],
        objectModel: json["object_model"],
        title: json["title"],
        price: json["price"],
        salePrice: json["sale_price"],
        discountPercent: json["discount_percent"],
        availability_url: json['availability_url'],
        image: json["image"],
        content: json["content"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        isFeatured: json["is_featured"],
        maxGuest: json["max_guest"],
        cabin: json["cabin"],
        length: json["length"],
        speed: json["speed"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        reviewScore: json["review_score"] == null
            ? null
            : ReviewScore.fromJson(json["review_score"]),
        status: json["status"],
        detailsUrl: json["details_url"],
        isInWishlist: json["is_in_wishlist"],
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
        "max_guest": maxGuest,
        "cabin": cabin,
        "length": length,
        "speed": speed,
        "updated_at": updatedAt?.toIso8601String(),
        "review_score": reviewScore?.toJson(),
        "status": status,
        "details_url": detailsUrl,
        "is_in_wishlist": isInWishlist,
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
