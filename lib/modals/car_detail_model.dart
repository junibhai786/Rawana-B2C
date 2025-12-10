import 'package:moonbnd/modals/model_helper/list_map_dynamic.dart';

class CarDetailModal {
  Data? data;
  Availability? availability;
  int? status;

  CarDetailModal({this.data, this.availability, this.status});

  CarDetailModal.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    availability = json['availability'] != null
        ? Availability.fromJson(json['availability'])
        : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (availability != null) {
      data['availability'] = availability!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Data {
  int? id;
  String? objectModel;
  String? title;
  int? price;
  int? salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  int? min_day_before_booking;
  int? min_day_stays;
  String? ical_import_url;

  Location? location;
  int? isFeatured;
  String? address;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? bannerImage;
  List<String>? gallery;
  String? video;
  int? enableExtraPrice;
  List<ExtraPriceCar>? extraPrice;
  int? passenger;
  String? gear;
  int? baggage;
  int? door;
  Vendor? vendor;
  String? shareUrl;
  bool? isInWishlist;
  ReviewScore? reviewScore;
  List<String>? reviewStats;
  ReviewLists? reviewLists;
  List<Faq>? faqs;
  int? isInstant;
  int? number;
  dynamic discountByDays;
  int? defaultState;
  List<BookingFee>? bookingFee;
  List<Term>? terms;

  Data({
    this.id,
    this.objectModel,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.image,
    this.content,
    this.min_day_before_booking,
    this.min_day_stays,
    this.ical_import_url,
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
    this.passenger,
    this.gear,
    this.baggage,
    this.door,
    this.vendor,
    this.shareUrl,
    this.isInWishlist,
    this.reviewScore,
    this.reviewStats,
    this.reviewLists,
    this.faqs,
    this.isInstant,
    this.number,
    this.discountByDays,
    this.defaultState,
    this.bookingFee,
    this.terms,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    objectModel = json['object_model'];
    title = json['title'];
    price = json['price'];
    salePrice = json['sale_price'];
    discountPercent = json['discount_percent'];
    image = json['image'];
    content = json['content'];
    min_day_before_booking = json['min_day_before_booking'];
    min_day_stays = json['min_day_stays'];
    ical_import_url = json['ical_import_url'];

    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    isFeatured = json['is_featured'];
    address = json['address'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    bannerImage = json['banner_image'];
    gallery = json['gallery'].cast<String>();
    video = json['video'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPriceCar>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(ExtraPriceCar.fromJson(v));
      });
    }
    passenger = json['passenger'];
    gear = json['gear'];
    baggage = json['baggage'];
    door = json['door'];
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    shareUrl = json['share_url'];
    isInWishlist = json['is_in_wishlist'];
    reviewScore = json['review_score'] != null
        ? ReviewScore.fromJson(json['review_score'])
        : null;
    reviewStats = json['review_stats'].cast<String>();
    reviewLists = json['review_lists'] != null
        ? ReviewLists.fromJson(json['review_lists'])
        : null;
    if (json['faqs'] != null) {
      faqs = <Faq>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faq.fromJson(v));
      });
    }
    isInstant = json['is_instant'];
    number = json['number'];
    discountByDays = json['discount_by_days'];
    defaultState = json['default_state'];
    if (json['booking_fee'] != null) {
      bookingFee = <BookingFee>[];
      json['booking_fee'].forEach((v) {
        bookingFee!.add(BookingFee.fromJson(v));
      });
    }
    // if (json['terms'] != null) {
    //   terms = <Term>[];
    //   json['terms'].forEach((v) {
    //     terms?.add(Term.fromJson(v));
    //   });
    // } else {
    //   terms = [];
    // }
    terms = parseMapOrList(json['terms'], (v) => Term.fromJson(v));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['object_model'] = objectModel;
    data['title'] = title;
    data['price'] = price;
    data['sale_price'] = salePrice;
    data['discount_percent'] = discountPercent;
    data['image'] = image;
    data['content'] = content;
    data['min_day_before_booking'] = min_day_before_booking;
    data['min_day_stays'] = min_day_stays;
    data['ical_import_url'] = ical_import_url;

    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['is_featured'] = isFeatured;
    data['address'] = address;
    data['map_lat'] = mapLat;
    data['map_lng'] = mapLng;
    data['map_zoom'] = mapZoom;
    data['banner_image'] = bannerImage;
    data['gallery'] = gallery;
    data['video'] = video;
    data['enable_extra_price'] = enableExtraPrice;
    if (extraPrice != null) {
      data['extra_price'] = extraPrice!.map((v) => v.toJson()).toList();
    }
    data['passenger'] = passenger;
    data['gear'] = gear;
    data['baggage'] = baggage;
    data['door'] = door;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['share_url'] = shareUrl;
    data['is_in_wishlist'] = isInWishlist;
    if (reviewScore != null) {
      data['review_score'] = reviewScore!.toJson();
    }
    data['review_stats'] = reviewStats;
    if (reviewLists != null) {
      data['review_lists'] = reviewLists!.toJson();
    }
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    data['is_instant'] = isInstant;
    data['number'] = number;
    data['discount_by_days'] = discountByDays;
    data['default_state'] = defaultState;
    if (bookingFee != null) {
      data['booking_fee'] = bookingFee!.map((v) => v.toJson()).toList();
    }
    if (terms != null) {
      data['terms'] = terms?.map((v) => v.toJson()).toList() ?? [];
    }
    return data;
  }
}

// Define other classes like Location, ExtraPrice, Vendor, ReviewScore, ReviewLists, Faq, BookingFee, Term here...

class Location {
  int? id;
  String? name;

  Location({this.id, this.name});

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ExtraPriceCar {
  String? name;
  String? egyptianame;
  String? japanesename;

  String? price;
  String? type;
  bool? valueType;

  ExtraPriceCar(
      {this.name,
      this.price,
      this.type,
      this.valueType = false,
      this.egyptianame,
      this.japanesename});

  ExtraPriceCar.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    egyptianame = json['name_egy'];
    japanesename = json['name_ja'];

    price = json['price'];
    valueType = json['value_type'] ?? false;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['name_egy'] = egyptianame;
    data['name_ja'] = japanesename;

    data['price'] = price;
    data["value_type"] = valueType;

    data['type'] = type;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['created_at'] = createdAt;
    data['avatar_url'] = avatarUrl;
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
    // if (json['rate_score'] != null) {
    //   rateScore = <RateScore>[];
    //   json['rate_score'].forEach((v) {
    //     rateScore!.add(RateScore.fromJson(v));
    //   });
    // }
    rateScore =
        parseMapOrList(json['rate_score'], (v) => RateScore.fromJson(v));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score_total'] = scoreTotal;
    data['score_text'] = scoreText;
    data['total_review'] = totalReview;
    if (rateScore != null) {
      data['rate_score'] = rateScore!.map((v) => v.toJson()).toList();
    }
    return data;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['total'] = total;
    data['percent'] = percent;
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
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
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
        data!.add(ReviewData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
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

  ReviewData({
    this.id,
    this.title,
    this.content,
    this.rateNumber,
    this.authorIp,
    this.status,
    this.createdAt,
    this.vendorId,
    this.authorId,
    this.author,
  });

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
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['rate_number'] = rateNumber;
    data['author_ip'] = authorIp;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['vendor_id'] = vendorId;
    data['author_id'] = authorId;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    return data;
  }
}

class Author {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  String? avatarUrl;

  Author({this.id, this.name, this.firstName, this.lastName, this.avatarUrl});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['avatar_url'] = avatarUrl;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}

class Faq {
  String? title;
  String? content;

  Faq({this.title, this.content});

  Faq.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['desc'] = desc;
    data['name_ja'] = nameJa;
    data['desc_ja'] = descJa;
    data['price'] = price;
    data['type'] = type;
    return data;
  }
}

class Term {
  Parent? parent;
  List<Child>? child;

  Term({this.parent, this.child});

  Term.fromJson(Map<String, dynamic> json) {
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
    if (parent != null) {
      data['parent'] = parent!.toJson();
    }
    if (child != null) {
      data['child'] = child!.map((v) => v.toJson()).toList();
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
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['service'] = service;
    data['display_type'] = displayType;
    data['hide_in_single'] = hideInSingle;
    return data;
  }
}

class Child {
  int? id;
  String? title;
  dynamic content;
  dynamic imageId;
  String? icon;
  int? attrId;
  String? slug;
  String? imageUrl;

  Child({
    this.id,
    this.title,
    this.content,
    this.imageId,
    this.icon,
    this.attrId,
    this.slug,
    this.imageUrl,
  });

  Child.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    imageId = json['image_id'];
    icon = json['icon'];
    attrId = json['attr_id'];
    slug = json['slug'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['image_id'] = imageId;
    data['icon'] = icon;
    data['attr_id'] = attrId;
    data['slug'] = slug;
    data['image_url'] = imageUrl;
    return data;
  }
}

class Availability {
  dynamic headers;
  dynamic original;
  dynamic exception;

  Availability({this.headers, this.original, this.exception});

  Availability.fromJson(Map<String, dynamic> json) {
    headers = json['headers'];
    original = json['original'];
    exception = json['exception'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['headers'] = headers;
    data['original'] = original;
    data['exception'] = exception;
    return data;
  }
}
