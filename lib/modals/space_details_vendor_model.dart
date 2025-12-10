// lib/modals/space_details_vendor_model.dart

class SpaceDetailsVendor {
  String message;
  List<SpaceData> data;

  SpaceDetailsVendor({required this.message, required this.data});

  // Method to convert JSON to SpaceDetails
  SpaceDetailsVendor.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        data = List<SpaceData>.from(
            json['data'].map((item) => SpaceData.fromJson(item)));
}

class SpaceData {
  int id;

  String objectModel;
  int? min_day_before_booking;
  String title;
  String price;
  String salePrice;
  String? discountPercent;
  String image;
  String content;
  int? min_day_stays;
  String ical_import_url;
  Location location;
  bool? isFeatured;
  String address;
  String? mapLat;
  String? mapLng;
  dynamic mapZoom;
  String bannerImage;
  List<String> gallery;
  String video;
  Map<String, List<SurroundingItem>>? surrounding;
  int enableExtraPrice;
  List<SpaceDetailExtraPriceVendor> extraPrice;
  int maxGuests;
  int bed;
  int? bathroom;
  int? square;
  String updatedAt;
  String status;
  String detailsUrl;
  Vendor vendor;
  String shareUrl;
  bool isInWishlist;
  ReviewScore reviewScore;
  List<String> reviewStats;
  ReviewLists reviewLists;
  List<FaqClass>? faqs;

  int allowChildren;
  int allowInfant;
  List<DiscountByDays>? discountByDays;
  int defaultState;
  List<BookingFee> bookingFee;
  List<Related> related;
  List<Terms> terms;

  SpaceData({
    required this.id,
    required this.objectModel,
    required this.surrounding,
    required this.title,
    required this.price,
    required this.salePrice,
    required this.ical_import_url,
    required this.min_day_stays,
    required this.discountPercent,
    required this.image,
    required this.content,
    required this.location,
    this.isFeatured,
    required this.address,
    this.mapLat,
    this.mapLng,
    this.min_day_before_booking,
    this.mapZoom,
    required this.bannerImage,
    required this.gallery,
    required this.video,
    required this.enableExtraPrice,
    required this.extraPrice,
    required this.maxGuests,
    required this.bed,
    this.bathroom,
    this.square,
    required this.updatedAt,
    required this.status,
    required this.detailsUrl,
    required this.vendor,
    required this.shareUrl,
    required this.isInWishlist,
    required this.reviewScore,
    required this.reviewStats,
    required this.reviewLists,
    required this.faqs,
    required this.allowChildren,
    required this.allowInfant,
    this.discountByDays,
    required this.defaultState,
    required this.bookingFee,
    required this.related,
    required this.terms,
  });

  // Method to convert JSON to SpaceData
  SpaceData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        objectModel = json['object_model'],
        surrounding = json['surrounding'] != null
            ? (json['surrounding'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  List<SurroundingItem>.from(
                    (value as List)
                        .map((item) => SurroundingItem.fromJson(item)),
                  ),
                ),
              )
            : {},
        title = json['title'],
        ical_import_url = json["ical_import_url"] ?? "",
        price = json['price'],
        min_day_before_booking = json['min_day_before_booking'] ?? 0,
        salePrice = json['sale_price'],
        discountPercent = json['discount_percent'] ?? "0",
        image = json['image'],
        min_day_stays = json['min_day_stays'] ?? 0,
        content = json['content'],
        location = Location.fromJson(json['location']),
        isFeatured = json['is_featured'],
        address = json['address'],
        mapLat = json['map_lat'],
        mapLng = json['map_lng'],
        mapZoom = json['map_zoom'],
        bannerImage = json['banner_image'],
        gallery = List<String>.from(json['gallery']),
        video = json['video'] ?? "",
        enableExtraPrice = json['enable_extra_price'],
        extraPrice = json['extra_price'] == null
            ? []
            : List<SpaceDetailExtraPriceVendor>.from(json['extra_price']
                .map((item) => SpaceDetailExtraPriceVendor.fromJson(item))),
        maxGuests = json['max_guests'] ?? 0,
        bed = json['bed'] ?? 0,
        bathroom = json['bathroom'] ?? 0,
        square = json['square'] ?? 0,
        updatedAt = json['updated_at'],
        status = json['status'],
        detailsUrl = json['details_url'],
        vendor = Vendor.fromJson(json['vendor']),
        shareUrl = json['share_url'],
        isInWishlist = json['is_in_wishlist'],
        reviewScore = ReviewScore.fromJson(json['review_score']),
        reviewStats = List<String>.from(json['review_stats']),
        reviewLists = ReviewLists.fromJson(json['review_lists']),
        faqs = json['faqs'] != null
            ? List<FaqClass>.from(
                json['faqs'].map((item) => FaqClass.fromJson(item)))
            : [],
        allowChildren = json['allow_children'],
        allowInfant = json['allow_infant'],
        discountByDays = json['discount_by_days'] == null
            ? []
            : List<DiscountByDays>.from(json['discount_by_days']
                .map((item) => DiscountByDays.fromJson(item))),
        defaultState = json['default_state'] ?? 0,
        bookingFee = json['booking_fee'] != null
            ? List<BookingFee>.from(
                json['booking_fee'].map((item) => BookingFee.fromJson(item)))
            : [],
        related = json['related'] == null
            ? []
            : List<Related>.from(
                json['related'].map((item) => Related.fromJson(item))),
        terms =
            List<Terms>.from(json['terms'].map((item) => Terms.fromJson(item)));
}

class SurroundingItem {
  String name;
  String content;
  String value;
  String type;

  SurroundingItem({
    required this.name,
    required this.content,
    required this.value,
    required this.type,
  });

  SurroundingItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        content = json['content'],
        value = json['value'],
        type = json['type'];
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

class FaqClass {
  String? title;
  String? name;

  FaqClass({this.title, this.name});

  FaqClass.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    name = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['content'] = this.name;
    return data;
  }
}

class SpaceDetailExtraPriceVendor {
  String? name;
  String? nameja;
  String? nameegy;
  String? price;
  String? type;
  String? perPerson;

  SpaceDetailExtraPriceVendor({this.name, this.price, this.type});

  SpaceDetailExtraPriceVendor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nameja = json['name_ja'];
    nameegy = json['name_egy'];
    price = json['price'];
    type = json['type'];
    perPerson = json['per_person'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = this.name;
    data['price'] = this.price;
    data['type'] = this.type;
    data['price'] = this.price;
    data['name_ja'] = this.nameja;
    data['name_egy'] = this.nameegy;
    data['per_person'] = this.perPerson;

    return data;
  }
}

class Vendor {
  int? id;
  String? name;
  String? email;
  String? createdAt;
  String? avatarUrl;

  Vendor({this.id, this.name, this.email, this.createdAt, this.avatarUrl});

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    createdAt = json['created_at'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['created_at'] = this.createdAt;
    data['avatar_url'] = this.avatarUrl;
    return data;
  }
}

class ReviewScore {
  dynamic scoreTotal;
  String? scoreText;
  int? totalReview;
  List<RateScore>? rateScore;

  ReviewScore(
      {this.scoreTotal, this.scoreText, this.totalReview, this.rateScore});

  ReviewScore.fromJson(Map<String, dynamic> json) {
    scoreTotal = json['score_total'];
    scoreText = json['score_text'];
    totalReview = json['total_review'];
    if (json['rate_score'] != null) {
      rateScore = <RateScore>[];
      json['rate_score'].forEach((v) {
        rateScore!.add(RateScore.fromJson(v));
      });
    }
  }
}

class RateScore {
  String? title;
  int? total;
  int? percent;

  RateScore({this.title, this.total, this.percent});

  RateScore.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    total = json['total'];
    percent = json['percent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['total'] = this.total;
    data['percent'] = this.percent;
    return data;
  }
}

class ReviewLists {
  int? currentPage;
  List<ReviewData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  ReviewLists(
      {this.currentPage,
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
      this.total});

  ReviewLists.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <ReviewData>[];
      json['data'].forEach((v) {
        data!.add(new ReviewData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class ReviewData {
  int? id;
  String? title;
  String? content;
  int? rateNumber;
  String? authorIp;
  String? status;
  String? createdAt;
  int? vendorId;
  int? authorId;
  Author? author;

  ReviewData(
      {this.id,
      this.title,
      this.content,
      this.rateNumber,
      this.authorIp,
      this.status,
      this.createdAt,
      this.vendorId,
      this.authorId,
      this.author});

  ReviewData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    rateNumber = json['rate_number'];
    authorIp = json['author_ip'];
    status = json['status'];
    createdAt = json['created_at'];
    vendorId = json['vendor_id'];
    authorId = json['author_id'];
    author =
        json['author'] != null ? new Author.fromJson(json['author']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['rate_number'] = this.rateNumber;
    data['author_ip'] = this.authorIp;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['vendor_id'] = this.vendorId;
    data['author_id'] = this.authorId;
    if (this.author != null) {
      data['author'] = this.author!.toJson();
    }
    return data;
  }
}

class Author {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  dynamic avatarId;
  String? avatarUrl;

  Author(
      {this.id,
      this.name,
      this.firstName,
      this.lastName,
      this.avatarId,
      this.avatarUrl});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    avatarId = json['avatar_id'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['avatar_id'] = this.avatarId;
    data['avatar_url'] = this.avatarUrl;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}

class Faqs {
  String? title;
  String? content;

  Faqs({this.title, this.content});

  Faqs.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['content'] = this.content;
    return data;
  }
}

class DiscountByDays {
  String? from;
  String? to;
  String? amount;
  String? type;
  DiscountByDays({this.amount = "", this.to = "", this.from = "", this.type});

  DiscountByDays.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    amount = json['amount'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = this.from;
    data['to'] = this.to;
    data['amount'] = this.amount;
    data['type'] = this.type;
    return data;
  }
}

class BookingFee {
  String? name;
  String? desc;
  String? nameJa;
  String? descJa;
  String? price;
  String? type;

  BookingFee(
      {this.name, this.desc, this.nameJa, this.descJa, this.price, this.type});

  BookingFee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    desc = json['desc'];
    nameJa = json['name_ja'];
    descJa = json['desc_ja'];
    price = json['price'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['name_ja'] = this.nameJa;
    data['desc_ja'] = this.descJa;
    data['price'] = this.price;
    data['type'] = this.type;
    return data;
  }
}

class Related {
  int? id;
  String? objectModel;
  String? title;
  String? price;
  String? salePrice;
  String? discountPercent;
  String? image;
  String? content;
  Location? location;
  int? isFeatured;
  int? maxGuests;
  int? bed;
  int? bathroom;
  int? square;
  ReviewScore? reviewScore;

  Related(
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
      this.maxGuests,
      this.bed,
      this.bathroom,
      this.square,
      this.reviewScore});

  Related.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    objectModel = json['object_model'];
    title = json['title'];
    price = json['price'];
    salePrice = json['sale_price'];
    discountPercent = json['discount_percent'];
    image = json['image'];
    content = json['content'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    isFeatured = json['is_featured'];
    maxGuests = json['max_guests'];
    bed = json['bed'];
    bathroom = json['bathroom'];
    square = json['square'];
    reviewScore = json['review_score'] != null
        ? ReviewScore.fromJson(json['review_score'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // ignore: unnecessary_this
    data['id'] = this.id;
    // ignore: unnecessary_this
    data['object_model'] = this.objectModel;
    // ignore: unnecessary_this
    data['title'] = this.title;
    // ignore: unnecessary_this
    data['price'] = this.price;
    // ignore: unnecessary_this
    data['sale_price'] = this.salePrice;
    // ignore: unnecessary_this
    data['discount_percent'] = this.discountPercent;
    // ignore: unnecessary_this
    data['image'] = this.image;
    // ignore: unnecessary_this
    data['content'] = this.content;
    // ignore: unnecessary_this
    if (this.location != null) {
      // ignore: unnecessary_this
      data['location'] = this.location!.toJson();
    }
    // ignore: unnecessary_this
    data['is_featured'] = this.isFeatured;
    // ignore: unnecessary_this
    data['max_guests'] = this.maxGuests;
    // ignore: unnecessary_this
    data['bed'] = this.bed;
    // ignore: unnecessary_this
    data['bathroom'] = this.bathroom;
    // ignore: unnecessary_this
    data['square'] = this.square;
    // ignore: unnecessary_this
    if (this.reviewScore != null) {
      // ignore: unnecessary_this
      data['review_score'] = this.reviewScore;
    }
    return data;
  }
}

class Terms {
  Parent? parent;
  List<Child>? child;

  Terms({this.parent, this.child});

  Terms.fromJson(Map<String, dynamic> json) {
    parent = json['parent'] != null ? Parent.fromJson(json['parent']) : null;
    if (json['child'] != null) {
      child = <Child>[];
      json['child'].forEach((v) {
        child!.add(Child.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // ignore: unnecessary_this
    if (this.parent != null) {
      // ignore: unnecessary_this
      data['parent'] = this.parent!.toJson();
    }
    // ignore: unnecessary_this
    if (this.child != null) {
      // ignore: unnecessary_this
      data['child'] = this.child!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Parent {
  int? id;
  String? title;
  String? slug;
  String? service;
  dynamic displayType;
  dynamic hideInSingle;

  Parent(
      {this.id,
      this.title,
      this.slug,
      this.service,
      this.displayType,
      this.hideInSingle});

  Parent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    service = json['service'];
    displayType = json['display_type'];
    hideInSingle = json['hide_in_single'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // ignore: unnecessary_this
    data['id'] = this.id;
    // ignore: unnecessary_this
    data['title'] = this.title;
    // ignore: unnecessary_this
    data['slug'] = this.slug;
    // ignore: unnecessary_this
    data['service'] = this.service;
    // ignore: unnecessary_this
    data['display_type'] = this.displayType;
    // ignore: unnecessary_this
    data['hide_in_single'] = this.hideInSingle;
    return data;
  }
}

class Child {
  int? id;
  String? title;
  dynamic content;
  int? imageId;
  String? imageUrl;
  dynamic icon;
  int? attrId;
  String? slug;

  Child(
      {this.id,
      this.title,
      this.content,
      this.imageId,
      this.imageUrl,
      this.icon,
      this.attrId,
      this.slug});

  Child.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    imageId = json['image_id'];
    imageUrl = json['image_url'];
    icon = json['icon'];
    attrId = json['attr_id'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['image_id'] = this.imageId;
    data['image_url'] = this.imageUrl;
    data['icon'] = this.icon;
    data['attr_id'] = this.attrId;
    data['slug'] = this.slug;
    return data;
  }
}



// lib/modals/space_details_vendor_model.dart


