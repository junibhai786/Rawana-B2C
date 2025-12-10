// To parse this JSON data, do
//
//     final allHotelDetailsVendorModel = allHotelDetailsVendorModelFromJson(jsonString);

import 'dart:convert';

AllHotelDetailsVendorModel allHotelDetailsVendorModelFromJson(String str) =>
    AllHotelDetailsVendorModel.fromJson(json.decode(str));

String allHotelDetailsVendorModelToJson(AllHotelDetailsVendorModel data) =>
    json.encode(data.toJson());

class AllHotelDetailsVendorModel {
  String? message;
  List<HDDatum>? data;

  AllHotelDetailsVendorModel({
    this.message,
    this.data,
  });

  factory AllHotelDetailsVendorModel.fromJson(Map<String, dynamic> json) =>
      AllHotelDetailsVendorModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<HDDatum>.from(
                json["data"].map((x) => HDDatum.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class HDDatum {
  int? id;
  String? objectModel;
  String? title;
  String? price;
  String? salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  Location? location;
  dynamic isFeatured;
  String? address;
  String? relatedIds;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? bannerImage;
  List<String>? gallery;
  String? video;
  String? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  bool? isInWishlist;
  DateTime? updatedAt;
  String? status;
  String? detailsUrl;
  DatumReviewScore? reviewScore;
  List<String>? reviewStats;
  ReviewLists? reviewLists;
  List<Policy>? policy;
  int? starRate;
  String? checkInTime;
  String? checkOutTime;
  dynamic allowFullDay;
  int? minDayBeforeBooking;
  int? minDayStays;
  List<BookingFee>? bookingFee;
  Vendor? vendor;
  String? shareUrl;
  Map<String, List<Surrounding>>? surrounding;
  List<Related>? related;
  List<Term>? terms;

  HDDatum({
    this.id,
    this.objectModel,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.image,
    this.content,
    this.location,
    this.isFeatured,
    this.relatedIds,
    this.address,
    this.mapLat,
    this.mapLng,
    this.mapZoom,
    this.bannerImage,
    this.gallery,
    this.video,
    this.enableExtraPrice,
    this.extraPrice,
    this.isInWishlist,
    this.updatedAt,
    this.status,
    this.detailsUrl,
    this.reviewScore,
    this.reviewStats,
    this.reviewLists,
    this.policy,
    this.starRate,
    this.checkInTime,
    this.checkOutTime,
    this.allowFullDay,
    this.minDayBeforeBooking,
    this.minDayStays,
    this.bookingFee,
    this.vendor,
    this.shareUrl,
    this.surrounding,
    this.related,
    this.terms,
  });

  factory HDDatum.fromJson(Map<String, dynamic> json) => HDDatum(
        id: json["id"],
        objectModel: json["object_model"],
        title: json["title"],
        price: json["price"],
        salePrice: json["sale_price"],
        relatedIds: json["related_ids"],
        discountPercent: json["discount_percent"],
        image: json["image"],
        content: json["content"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        isFeatured: json["is_featured"],
        address: json["address"],
        mapLat: json["map_lat"],
        mapLng: json["map_lng"],
        mapZoom: json["map_zoom"],
        bannerImage: json["banner_image"],
        gallery: json["gallery"] == null
            ? []
            : List<String>.from(json["gallery"].map((x) => x) ?? []),
        video: json["video"],
        enableExtraPrice: json["enable_extra_price"],
        extraPrice: json["extra_price"] == null
            ? []
            : List<ExtraPrice>.from(
                json["extra_price"]?.map((x) => ExtraPrice.fromJson(x)) ?? []),
        isInWishlist: json["is_in_wishlist"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        status: json["status"],
        detailsUrl: json["details_url"],
        reviewScore: json["review_score"] == null
            ? null
            : DatumReviewScore.fromJson(json["review_score"]),
        reviewStats: json["review_stats"] == null
            ? []
            : List<String>.from(json["review_stats"]?.map((x) => x) ?? []),
        reviewLists: json["review_lists"] == null
            ? null
            : ReviewLists.fromJson(json["review_lists"]),
        policy: json["policy"] == null
            ? []
            : List<Policy>.from(
                json["policy"]?.map((x) => Policy.fromJson(x)) ?? []),
        starRate: json["star_rate"],
        checkInTime: json["check_in_time"],
        checkOutTime: json["check_out_time"],
        allowFullDay: json["allow_full_day"],
        minDayBeforeBooking: json["min_day_before_booking"],
        minDayStays: json["min_day_stays"],
        bookingFee: json["booking_fee"] == null
            ? []
            : List<BookingFee>.from(
                json["booking_fee"]?.map((x) => BookingFee.fromJson(x)) ?? []),
        vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
        shareUrl: json["share_url"],
        surrounding: Map.from(json["surrounding"]).map((k, v) =>
            MapEntry<String, List<Surrounding>>(k,
                List<Surrounding>.from(v.map((x) => Surrounding.fromJson(x))))),
        related: json["related"] == null
            ? []
            : List<Related>.from(
                json["related"].map((x) => Related.fromJson(x)) ?? []),
        terms: json["terms"] == null
            ? []
            : List<Term>.from(
                json["terms"]?.map((x) => Term.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object_model": objectModel,
        "title": title,
        "price": price,
        "sale_price": salePrice,
        "discount_percent": discountPercent,
        "related_ids": relatedIds,
        "image": image,
        "content": content,
        "location": location?.toJson(),
        "is_featured": isFeatured,
        "address": address,
        "map_lat": mapLat,
        "map_lng": mapLng,
        "map_zoom": mapZoom,
        "banner_image": bannerImage,
        "gallery": gallery == null
            ? []
            : List<dynamic>.from(gallery?.map((x) => x) ?? []),
        "video": video,
        "enable_extra_price": enableExtraPrice,
        "extra_price": extraPrice == null
            ? []
            : List<dynamic>.from(extraPrice?.map((x) => x.toJson()) ?? []),
        "is_in_wishlist": isInWishlist,
        "updated_at": updatedAt?.toIso8601String(),
        "status": status,
        "details_url": detailsUrl,
        "review_score": reviewScore?.toJson(),
        "review_stats": reviewStats == null
            ? []
            : List<dynamic>.from(reviewStats?.map((x) => x) ?? []),
        "review_lists": reviewLists?.toJson(),
        "policy": policy == null
            ? []
            : List<dynamic>.from(policy?.map((x) => x.toJson()) ?? []),
        "star_rate": starRate,
        "check_in_time": checkInTime,
        "check_out_time": checkOutTime,
        "allow_full_day": allowFullDay,
        "min_day_before_booking": minDayBeforeBooking,
        "min_day_stays": minDayStays,
        "booking_fee": bookingFee == null
            ? []
            : List<dynamic>.from(bookingFee?.map((x) => x.toJson()) ?? []),
        "vendor": vendor?.toJson(),
        "share_url": shareUrl,
        "surrounding": Map.from(surrounding!).map((k, v) =>
            MapEntry<String, dynamic>(
                k, List<dynamic>.from(v.map((x) => x.toJson())))),
        "related": related == null
            ? []
            : List<dynamic>.from(related?.map((x) => x.toJson()) ?? []),
        "terms": terms == null
            ? []
            : List<dynamic>.from(terms?.map((x) => x.toJson()) ?? []),
      };
}

class BookingFee {
  String? name;
  String? desc;
  String? nameJa;
  String? descJa;
  String? price;
  String? type;

  BookingFee({
    this.name,
    this.desc,
    this.nameJa,
    this.descJa,
    this.price,
    this.type,
  });

  factory BookingFee.fromJson(Map<String, dynamic> json) => BookingFee(
        name: json["name"],
        desc: json["desc"],
        nameJa: json["name_ja"],
        descJa: json["desc_ja"],
        price: json["price"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "desc": desc,
        "name_ja": nameJa,
        "desc_ja": descJa,
        "price": price,
        "type": type,
      };
}

class ExtraPrice {
  String? name;
  dynamic nameJa;
  dynamic nameEgy;
  String? price;
  String? type;
  String? perPerson;

  ExtraPrice({
    this.name,
    this.nameJa,
    this.nameEgy,
    this.price,
    this.type,
    this.perPerson,
  });

  factory ExtraPrice.fromJson(Map<String, dynamic> json) => ExtraPrice(
        name: json["name"],
        nameJa: json["name_ja"],
        nameEgy: json["name_egy"],
        price: json["price"],
        type: json["type"],
        perPerson: json["per_person"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "name_ja": nameJa,
        "name_egy": nameEgy,
        "price": price,
        "type": type,
        "per_person": perPerson,
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

class Policy {
  dynamic title;
  String? content;

  Policy({
    this.title,
    this.content,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
        title: json["title"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
      };
}

class Related {
  int? id;
  String? objectModel;
  String? title;
  String? price;
  String? salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  Location? location;
  dynamic isFeatured;
  bool? isInWishlist;
  List<String>? gallery;
  String? mapLat;
  String? mapLng;
  DateTime? updatedAt;
  String? status;
  String? detailsUrl;
  RelatedReviewScore? reviewScore;

  Related({
    this.id,
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
    this.updatedAt,
    this.status,
    this.detailsUrl,
    this.reviewScore,
  });

  factory Related.fromJson(Map<String, dynamic> json) => Related(
        id: json["id"],
        objectModel: json["object_model"],
        title: json["title"],
        price: json["price"],
        salePrice: json["sale_price"],
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
            : List<String>.from(json["gallery"]?.map((x) => x) ?? []),
        mapLat: json["map_lat"],
        mapLng: json["map_lng"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        status: json["status"],
        detailsUrl: json["details_url"],
        reviewScore: json["review_score"] == null
            ? null
            : RelatedReviewScore.fromJson(json["review_score"]),
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
        "gallery": gallery == null
            ? []
            : List<dynamic>.from(gallery?.map((x) => x) ?? []),
        "map_lat": mapLat,
        "map_lng": mapLng,
        "updated_at": updatedAt?.toIso8601String(),
        "status": status,
        "details_url": detailsUrl,
        "review_score": reviewScore?.toJson(),
      };
}

class RelatedReviewScore {
  dynamic scoreTotal;
  int? totalReview;
  String? reviewText;

  RelatedReviewScore({
    this.scoreTotal,
    this.totalReview,
    this.reviewText,
  });

  factory RelatedReviewScore.fromJson(Map<String, dynamic> json) =>
      RelatedReviewScore(
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

class ReviewLists {
  int? currentPage;
  List<dynamic>? data;
  String? firstPageUrl;
  dynamic from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  dynamic to;
  int? total;

  ReviewLists({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ReviewLists.fromJson(Map<String, dynamic> json) => ReviewLists(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<dynamic>.from(json["data"]?.map((x) => x) ?? []),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(
                json["links"]?.map((x) => Link.fromJson(x)) ?? []),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data":
            data == null ? [] : List<dynamic>.from(data?.map((x) => x) ?? []),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links?.map((x) => x.toJson()) ?? []),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}

class DatumReviewScore {
  dynamic scoreTotal;
  String? scoreText;
  int? totalReview;
  List<RateScore>? rateScore;

  DatumReviewScore({
    this.scoreTotal,
    this.scoreText,
    this.totalReview,
    this.rateScore,
  });

  factory DatumReviewScore.fromJson(Map<String, dynamic> json) =>
      DatumReviewScore(
        scoreTotal: json["score_total"],
        scoreText: json["score_text"],
        totalReview: json["total_review"],
        rateScore: json["rate_score"] == null
            ? []
            : List<RateScore>.from(
                json["rate_score"]?.map((x) => RateScore.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "score_total": scoreTotal,
        "score_text": scoreText,
        "total_review": totalReview,
        "rate_score": rateScore == null
            ? []
            : List<dynamic>.from(rateScore?.map((x) => x.toJson()) ?? []),
      };
}

class RateScore {
  String? title;
  int? total;
  int? percent;

  RateScore({
    this.title,
    this.total,
    this.percent,
  });

  factory RateScore.fromJson(Map<String, dynamic> json) => RateScore(
        title: json["title"],
        total: json["total"],
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "total": total,
        "percent": percent,
      };
}

class Surrounding {
  dynamic name;
  String? content;
  String? value;
  String? type;

  Surrounding({
    this.name,
    this.content,
    this.value,
    this.type,
  });

  factory Surrounding.fromJson(Map<String, dynamic> json) => Surrounding(
        name: json["name"],
        content: json["content"],
        value: json["value"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "content": content,
        "value": value,
        "type": type,
      };
}

class Term {
  Parent? parent;
  List<Child>? child;

  Term({
    this.parent,
    this.child,
  });

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
        child: json["child"] == null
            ? []
            : List<Child>.from(
                json["child"]?.map((x) => Child.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "parent": parent?.toJson(),
        "child": child == null
            ? []
            : List<dynamic>.from(child?.map((x) => x.toJson()) ?? []),
      };
}

class Child {
  int? id;
  String? title;
  dynamic content;
  int? imageId;
  String? imageUrl;
  String? icon;
  int? attrId;
  String? slug;

  Child({
    this.id,
    this.title,
    this.content,
    this.imageId,
    this.imageUrl,
    this.icon,
    this.attrId,
    this.slug,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        imageId: json["image_id"],
        imageUrl: json["image_url"],
        icon: json["icon"],
        attrId: json["attr_id"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "image_id": imageId,
        "image_url": imageUrl,
        "icon": icon,
        "attr_id": attrId,
        "slug": slug,
      };
}

class Parent {
  int? id;
  String? title;
  String? slug;
  String? service;
  dynamic displayType;
  dynamic hideInSingle;

  Parent({
    this.id,
    this.title,
    this.slug,
    this.service,
    this.displayType,
    this.hideInSingle,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        id: json["id"],
        title: json["title"],
        slug: json["slug"],
        service: json["service"],
        displayType: json["display_type"],
        hideInSingle: json["hide_in_single"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "slug": slug,
        "service": service,
        "display_type": displayType,
        "hide_in_single": hideInSingle,
      };
}

class Vendor {
  int? id;
  String? name;
  String? email;
  DateTime? createdAt;
  String? avatarUrl;

  Vendor({
    this.id,
    this.name,
    this.email,
    this.createdAt,
    this.avatarUrl,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        avatarUrl: json["avatar_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "created_at": createdAt?.toIso8601String(),
        "avatar_url": avatarUrl,
      };
}
