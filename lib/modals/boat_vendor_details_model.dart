import 'dart:convert';

BoatVendorDetailModel boatVendorDetailsModelFromJson(String str) =>
    BoatVendorDetailModel.fromJson(json.decode(str));

String boatVendorDetailsModelToJson(BoatVendorDetailModel data) =>
    json.encode(data.toJson());

class BoatVendorDetailModel {
  String? message;
  List<BoatDetailDatum>? data;

  BoatVendorDetailModel({
    this.message,
    this.data,
  });

  factory BoatVendorDetailModel.fromJson(Map<String, dynamic> json) =>
      BoatVendorDetailModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<BoatDetailDatum>.from(
                json["data"]!.map((x) => BoatDetailDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BoatDetailDatum {
  int? id;
  String? objectModel;
  String? title;
  dynamic price;
  int? salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  Location? location;
  dynamic isFeatured;
  String? address;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? bannerImage;
  List<String>? gallery;
  String? video;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  int? maxGuest;
  int? cabin;
  String? length;
  String? speed;
  String? status;
  DateTime? updatedAt;
  String? detailsUrl;
  Vendor? vendor;
  String? shareUrl;
  bool? isInWishlist;
  ReviewScore? reviewScore;
  List<String>? reviewStats;
  ReviewLists? reviewLists;
  List<Faq>? faqs;
  List<Faq>? specs;
  String? cancelPolicy;
  String? termsInformation;
  dynamic minDayBeforeBooking;
  dynamic isInstant;
  dynamic number;
  String? startTime;
  String? endTime;
  String? pricePerHour;
  String? pricePerDay;
  int? defaultState;
  List<BookingFee>? bookingFee;
  List<dynamic>? related;
  List<Term>? terms;
  List<IncludeExclude>? include;
  List<IncludeExclude>? exclude;

  BoatDetailDatum({
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
    this.address,
    this.mapLat,
    this.mapLng,
    this.mapZoom,
    this.bannerImage,
    this.gallery,
    this.video,
    this.enableExtraPrice,
    this.extraPrice,
    this.maxGuest,
    this.cabin,
    this.length,
    this.speed,
    this.status,
    this.updatedAt,
    this.detailsUrl,
    this.vendor,
    this.shareUrl,
    this.isInWishlist,
    this.reviewScore,
    this.reviewStats,
    this.reviewLists,
    this.faqs,
    this.specs,
    this.cancelPolicy,
    this.termsInformation,
    this.minDayBeforeBooking,
    this.isInstant,
    this.number,
    this.startTime,
    this.endTime,
    this.pricePerHour,
    this.pricePerDay,
    this.defaultState,
    this.bookingFee,
    this.related,
    this.terms,
    this.include,
    this.exclude,
  });

  factory BoatDetailDatum.fromJson(Map<String, dynamic> json) =>
      BoatDetailDatum(
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
        address: json["address"],
        mapLat: json["map_lat"],
        mapLng: json["map_lng"],
        mapZoom: json["map_zoom"],
        bannerImage: json["banner_image"],
        gallery: json["gallery"] == null
            ? []
            : List<String>.from(json["gallery"]!.map((x) => x)),
        video: json["video"],
        enableExtraPrice: json["enable_extra_price"],
        extraPrice: json["extra_price"] == null
            ? []
            : List<ExtraPrice>.from(
                json["extra_price"]!.map((x) => ExtraPrice.fromJson(x))),
        maxGuest: json["max_guest"],
        cabin: json["cabin"],
        length: json["length"],
        speed: json["speed"],
        status: json["status"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        detailsUrl: json["details_url"],
        vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
        shareUrl: json["share_url"],
        isInWishlist: json["is_in_wishlist"],
        reviewScore: json["review_score"] == null
            ? null
            : ReviewScore.fromJson(json["review_score"]),
        reviewStats: json["review_stats"] == null
            ? []
            : List<String>.from(json["review_stats"]!.map((x) => x)),
        reviewLists: json["review_lists"] == null
            ? null
            : ReviewLists.fromJson(json["review_lists"]),
        faqs: json["faqs"] == null
            ? []
            : List<Faq>.from(json["faqs"]!.map((x) => Faq.fromJson(x))),
        specs: json["specs"] == null
            ? []
            : List<Faq>.from(json["specs"]!.map((x) => Faq.fromJson(x))),
        cancelPolicy: json["cancel_policy"],
        termsInformation: json["terms_information"],
        minDayBeforeBooking: json["min_day_before_booking"] ?? "",
        isInstant: json["is_instant"],
        number: json["number"],
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        pricePerHour: json["price_per_hour"],
        pricePerDay: json["price_per_day"],
        defaultState: json["default_state"],
        bookingFee: json["booking_fee"] == null
            ? []
            : List<BookingFee>.from(
                json["booking_fee"]!.map((x) => BookingFee.fromJson(x))),
        related: json["related"] == null
            ? []
            : List<dynamic>.from(json["related"]!.map((x) => x)),
        terms: json["terms"] == null
            ? []
            : List<Term>.from(json["terms"]!.map((x) => Term.fromJson(x))),
        include: json["include"] == null
            ? []
            : List<IncludeExclude>.from(
                json["include"]!.map((x) => IncludeExclude.fromJson(x))),
        exclude: json["exclude"] == null
            ? []
            : List<IncludeExclude>.from(
                json["exclude"]!.map((x) => IncludeExclude.fromJson(x))),
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
        "address": address,
        "map_lat": mapLat,
        "map_lng": mapLng,
        "map_zoom": mapZoom,
        "banner_image": bannerImage,
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "video": video,
        "enable_extra_price": enableExtraPrice,
        "extra_price": extraPrice == null
            ? []
            : List<dynamic>.from(extraPrice!.map((x) => x.toJson())),
        "max_guest": maxGuest,
        "cabin": cabin,
        "length": length,
        "speed": speed,
        "status": status,
        "updated_at": updatedAt?.toIso8601String(),
        "details_url": detailsUrl,
        "vendor": vendor?.toJson(),
        "share_url": shareUrl,
        "is_in_wishlist": isInWishlist,
        "review_score": reviewScore?.toJson(),
        "review_stats": reviewStats == null
            ? []
            : List<dynamic>.from(reviewStats!.map((x) => x)),
        "review_lists": reviewLists?.toJson(),
        "faqs": faqs == null
            ? []
            : List<dynamic>.from(faqs!.map((x) => x.toJson())),
        "specs": specs == null
            ? []
            : List<dynamic>.from(specs!.map((x) => x.toJson())),
        "cancel_policy": cancelPolicy,
        "terms_information": termsInformation,
        "min_day_before_booking": minDayBeforeBooking,
        "is_instant": isInstant,
        "number": number,
        "start_time": startTime,
        "end_time": endTime,
        "price_per_hour": pricePerHour,
        "price_per_day": pricePerDay,
        "default_state": defaultState,
        "booking_fee": bookingFee == null
            ? []
            : List<dynamic>.from(bookingFee!.map((x) => x.toJson())),
        "related":
            related == null ? [] : List<dynamic>.from(related!.map((x) => x)),
        "terms": terms == null
            ? []
            : List<dynamic>.from(terms!.map((x) => x.toJson())),
        "include": include == null
            ? []
            : List<dynamic>.from(include!.map((x) => x.toJson())),
        "exclude": exclude == null
            ? []
            : List<dynamic>.from(exclude!.map((x) => x.toJson())),
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
  String? nameJa;
  String? nameEgy;

  String? price;
  String? type;

  ExtraPrice({
    this.name,
    this.price,
    this.type,
    this.nameJa,
    this.nameEgy,
  });

  factory ExtraPrice.fromJson(Map<String, dynamic> json) => ExtraPrice(
        name: json["name"],
        price: json["price"],
        type: json["type"],
        nameJa: json["name_ja"],
        nameEgy: json["name_egy"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "type": type,
      };
}

class Faq {
  String? title;
  String? content;

  Faq({
    this.title,
    this.content,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
        title: json["title"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
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
            : List<dynamic>.from(json["data"]!.map((x) => x)),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
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

class ReviewScore {
  int? scoreTotal;
  String? scoreText;
  int? totalReview;
  List<RateScore>? rateScore;

  ReviewScore({
    this.scoreTotal,
    this.scoreText,
    this.totalReview,
    this.rateScore,
  });

  factory ReviewScore.fromJson(Map<String, dynamic> json) => ReviewScore(
        scoreTotal: json["score_total"],
        scoreText: json["score_text"],
        totalReview: json["total_review"],
        rateScore: json["rate_score"] == null
            ? []
            : List<RateScore>.from(
                json["rate_score"]!.map((x) => RateScore.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "score_total": scoreTotal,
        "score_text": scoreText,
        "total_review": totalReview,
        "rate_score": rateScore == null
            ? []
            : List<dynamic>.from(rateScore!.map((x) => x.toJson())),
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
            : List<Child>.from(json["child"]!.map((x) => Child.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "parent": parent?.toJson(),
        "child": child == null
            ? []
            : List<dynamic>.from(child!.map((x) => x.toJson())),
      };
}

class Child {
  int? id;
  String? title;
  dynamic content;
  dynamic imageId;
  String? imageUrl;
  dynamic icon;
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

class IncludeExclude {
  String? title;

  IncludeExclude({
    this.title,
  });

  factory IncludeExclude.fromJson(Map<String, dynamic> json) => IncludeExclude(
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
      };
}
