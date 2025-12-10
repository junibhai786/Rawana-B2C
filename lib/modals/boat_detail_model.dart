// lib/models/boat_detail_model.dart

import 'package:moonbnd/modals/car_detail_model.dart';

class BoatDetailModel {
  final Data data;
  final int status;

  BoatDetailModel({required this.data, required this.status});

  factory BoatDetailModel.fromJson(Map<String, dynamic> json) {
    return BoatDetailModel(
      data: Data.fromJson(json['data']),
      status: json['status'],
    );
  }
}

class Data {
  final int id;
  final String objectModel;
  final String title;
  final dynamic price;
  final dynamic salePrice;
  final String? discountPercent;
  final String image;
  final String content;
  final Location location;
  final dynamic isFeatured;
  final String address;
  final String mapLat;
  final String mapLng;
  final int mapZoom;
  final String bannerImage;
  final List<String> gallery;
  final String video;
  final int enableExtraPrice;
  final List<ExtraPriceBoat> extraPrice;
  final int maxGuest;
  final int cabin;
  final String length;
  final dynamic speed;
  final Vendor? vendor;
  final String shareUrl;
  bool isInWishlist;
  final ReviewScore? reviewScore;
  final List<String> reviewStats;
  final ReviewLists? reviewLists;
  final List<Faq> faqs;
  final String cancelPolicy;
  final String termsInformation;
  final int? minDayBeforeBooking;
  final bool? isInstant;
  final int number;
  final String pricePerHour;
  final String pricePerDay;
  final int defaultState;
  final List<BookingFee> bookingFee;
  final List<Related> related;
  final List<Term> terms;

  Data({
    required this.id,
    required this.objectModel,
    required this.title,
    required this.price,
    this.salePrice,
    this.discountPercent,
    required this.image,
    required this.content,
    required this.location,
    required this.isFeatured,
    required this.address,
    required this.mapLat,
    required this.mapLng,
    required this.mapZoom,
    required this.bannerImage,
    required this.gallery,
    required this.video,
    required this.enableExtraPrice,
    required this.extraPrice,
    required this.maxGuest,
    required this.cabin,
    required this.length,
    required this.speed,
    this.vendor,
    required this.shareUrl,
    required this.isInWishlist,
    this.reviewScore,
    required this.reviewStats,
    this.reviewLists,
    required this.faqs,
    required this.cancelPolicy,
    required this.termsInformation,
    this.minDayBeforeBooking,
    this.isInstant,
    required this.number,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.defaultState,
    required this.bookingFee,
    required this.related,
    required this.terms,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      objectModel: json['object_model'] ?? "",
      title: json['title'] ?? "",
      price: json['price'],
      salePrice: json['sale_price'],
      discountPercent: json['discount_percent'],
      image: json['image'] ?? "",
      content: json['content'] ?? "",
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : Location(id: 0, name: ''),
      isFeatured: json['is_featured'],
      address: json['address'] ?? "",
      mapLat: json['map_lat'] ?? "",
      mapLng: json['map_lng'] ?? "",
      mapZoom: json['map_zoom'] ?? 0,
      bannerImage: json['banner_image'] ?? "",
      gallery: List<String>.from(json['gallery'] ?? []),
      video: json['video'] ?? "",
      enableExtraPrice: json['enable_extra_price'],
      extraPrice: json['extra_price'] != null
          ? List<ExtraPriceBoat>.from(
              json['extra_price'].map((x) => ExtraPriceBoat.fromJson(x)))
          : [],
      maxGuest: json['max_guest'],
      cabin: json['cabin'],
      length: json['length'] ?? "",
      speed: json['speed'],
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      shareUrl: json['share_url'] ?? "",
      isInWishlist:
          json['is_in_wishlist'] == 1 || json['is_in_wishlist'] == true,
      reviewScore: json['review_score'] != null
          ? ReviewScore.fromJson(json['review_score'])
          : null,
      reviewStats: json['review_stats'] != null
          ? List<String>.from(json['review_stats'])
          : [],
      reviewLists: json['review_lists'] != null
          ? ReviewLists.fromJson(json['review_lists'])
          : null,
      faqs: json['faqs'] != null
          ? List<Faq>.from(json['faqs'].map((x) => Faq.fromJson(x)))
          : [],
      cancelPolicy: json['cancel_policy'] ?? "",
      termsInformation: json['terms_information'] ?? "",
      minDayBeforeBooking: json['min_day_before_booking'],
      isInstant: json['is_instant'],
      number: json['number'] ?? 0,
      pricePerHour: json['price_per_hour'] ?? "",
      pricePerDay: json['price_per_day'] ?? "",
      defaultState: json['default_state'],
      bookingFee: json['booking_fee'] != null
          ? List<BookingFee>.from(
              json['booking_fee'].map((x) => BookingFee.fromJson(x)))
          : [],
      related: json['related'] != null
          ? List<Related>.from(json['related'].map((x) => Related.fromJson(x)))
          : [],
      terms: json['terms'] != null && json['terms'] is Map
          ? (json['terms'] as Map<String, dynamic>)
              .values
              .map((x) => Term.fromJson(x))
              .toList()
          : [],
    );
  }
}

class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Vendor {
  final int id;
  final String name;
  final String email;
  final String createdAt;
  final String avatarUrl;

  Vendor(
      {required this.id,
      required this.name,
      required this.email,
      required this.createdAt,
      required this.avatarUrl});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class ExtraPriceBoat {
  String? name;
  String? price;
  String? type;
  bool? valueType;

  ExtraPriceBoat({this.name, this.price, this.type, this.valueType = false});

  factory ExtraPriceBoat.fromJson(Map<String, dynamic> json) {
    return ExtraPriceBoat(
      name: json['name'],
      price: json['price'],
      type: json['type'],
    );
  }
}

class RateScore {
  final String title;
  final int total;
  final int percent;

  RateScore({required this.title, required this.total, required this.percent});

  factory RateScore.fromJson(Map<String, dynamic> json) {
    return RateScore(
      title: json['title'],
      total: json['total'],
      percent: json['percent'],
    );
  }
}

class ReviewLists {
  final int currentPage;
  final List<Review> data;
  final String firstPageUrl;
  final dynamic from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ReviewLists({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ReviewLists.fromJson(Map<String, dynamic> json) {
    return ReviewLists(
      currentPage: json['current_page'],
      data: List<Review>.from(json['data'].map((x) => Review.fromJson(x))),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: List<Link>.from(json['links'].map((x) => Link.fromJson(x))),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'],
    );
  }
}

class Review {
  final int id;
  final String title;
  final String content;
  final int rateNumber;
  final String authorIp;
  final String status;
  final String createdAt;
  final int vendorId;
  final int authorId;
  final Author author;

  Review({
    required this.id,
    required this.title,
    required this.content,
    required this.rateNumber,
    required this.authorIp,
    required this.status,
    required this.createdAt,
    required this.vendorId,
    required this.authorId,
    required this.author,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      rateNumber: json['rate_number'],
      authorIp: json['author_ip'],
      status: json['status'],
      createdAt: json['created_at'],
      vendorId: json['vendor_id'],
      authorId: json['author_id'],
      author: Author.fromJson(json['author']),
    );
  }
}

class Author {
  final dynamic id;
  final dynamic name;
  final dynamic firstName;
  final dynamic lastName;
  final dynamic avatarId;
  final dynamic avatarUrl;

  Author({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.avatarId,
    required this.avatarUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'] ?? "",
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarId: json['avatar_id'],
      avatarUrl: json['avatar_url'] ?? "",
    );
  }
}

class Faq {
  final String title;
  final String content;

  Faq({required this.title, required this.content});

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      title: json['title'],
      content: json['content'],
    );
  }
}

class BookingFee {
  final String name;
  final String desc;
  final String nameJa;
  final String descJa;
  final String? price;
  final String type;

  BookingFee({
    required this.name,
    required this.desc,
    required this.nameJa,
    required this.descJa,
    required this.price,
    required this.type,
  });

  factory BookingFee.fromJson(Map<String, dynamic> json) {
    return BookingFee(
      name: json['name'],
      desc: json['desc'],
      nameJa: json['name_ja'],
      descJa: json['desc_ja'],
      price: json['price'],
      type: json['type'],
    );
  }
}

class Related {
  final int id;
  final String objectModel;
  final String title;
  final dynamic price;
  final dynamic salePrice;
  final String? discountPercent;
  final String image;
  final String content;
  final Location location;
  final dynamic isFeatured;
  final int maxGuest;
  final int cabin;
  final ReviewScore reviewScore;

  Related({
    required this.id,
    required this.objectModel,
    required this.title,
    required this.price,
    this.salePrice,
    this.discountPercent,
    required this.image,
    required this.content,
    required this.location,
    required this.isFeatured,
    required this.maxGuest,
    required this.cabin,
    required this.reviewScore,
  });

  factory Related.fromJson(Map<String, dynamic> json) {
    return Related(
      id: json['id'],
      objectModel: json['object_model'],
      title: json['title'],
      price: json['price'],
      salePrice: json['sale_price'],
      discountPercent: json['discount_percent'],
      image: json['image'] ?? "",
      content: json['content'] ?? "",
      location: Location.fromJson(json['location']),
      isFeatured: json['is_featured'],
      maxGuest: json['max_guest'] ?? 0,
      cabin: json['cabin'] ?? 0,
      reviewScore: ReviewScore.fromJson(json['review_score']),
    );
  }
}

class Term {
  final Parent parent;
  final List<Child> child;

  Term({required this.parent, required this.child});

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      parent: Parent.fromJson(json['parent']),
      child: List<Child>.from(json['child'].map((x) => Child.fromJson(x))),
    );
  }
}

class Parent {
  final int id;
  final String title;
  final String slug;
  final String service;
  final String? displayType;
  final String? hideInSingle;

  Parent({
    required this.id,
    required this.title,
    required this.slug,
    required this.service,
    this.displayType,
    this.hideInSingle,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      service: json['service'],
      displayType: json['display_type'],
      hideInSingle: json['hide_in_single'],
    );
  }
}

class Child {
  final int id;
  final String title;
  final String? content;
  final String? imageId;
  final String? imageUrl;
  final String? icon;
  final int attrId;
  final String slug;

  Child({
    required this.id,
    required this.title,
    this.content,
    this.imageId,
    this.imageUrl,
    this.icon,
    required this.attrId,
    required this.slug,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageId: json['image_id'],
      imageUrl: json['image_url'],
      icon: json['icon'],
      attrId: json['attr_id'],
      slug: json['slug'],
    );
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({this.url, required this.label, required this.active});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
