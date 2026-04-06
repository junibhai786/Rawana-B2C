import 'package:moonbnd/modals/model_helper/list_map_dynamic.dart';

class HotelDetail {
  Data? data;
  Availability? availability;
  int? status;

  HotelDetail({this.data, this.availability, this.status});

  HotelDetail.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
      availability = json['availability'] != null
          ? Availability.fromJson(json['availability'])
          : null;
      status = json['status'];
    } else if (json is List && json.isNotEmpty) {
      // Assuming the first item in the list contains the hotel details
      var firstItem = json.first;
      if (firstItem is Map<String, dynamic>) {
        data = Data.fromJson(firstItem);
        // You might need to adjust these fields based on the actual structure
        availability = firstItem['availability'] != null
            ? Availability.fromJson(firstItem['availability'])
            : null;
        status = firstItem['status'];
      }
    }
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
  String? price;
  dynamic salePrice;
  String? discountPercent;
  String? image;
  String? content;
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
  List<ExtraPriceHotel>? extraPrice;
  ReviewScore? reviewScore;
  List<String>? reviewStats;
  ReviewLists? reviewLists;
  List<Policy>? policy;
  int? starRate;
  String? checkInTime;
  String? checkOutTime;
  String? allowFullDay;
  List<BookingFee>? bookingFee;
  List<Related>? related;
  List<Terms>? terms;
  Vendor? vendor;
  String? shareUrl;
  bool? isInWishlist;

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
      this.address,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.bannerImage,
      this.gallery,
      this.video,
      this.enableExtraPrice,
      this.extraPrice,
      this.reviewScore,
      this.reviewStats,
      this.reviewLists,
      this.policy,
      this.starRate,
      this.checkInTime,
      this.checkOutTime,
      this.allowFullDay,
      this.bookingFee,
      this.related,
      this.terms,
      this.vendor,
      this.shareUrl,
      this.isInWishlist});

  Data.fromJson(Map<String, dynamic> json) {
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
    address = json['address'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    bannerImage = json['banner_image'];
    gallery =
        json['gallery'] != null ? List<String>.from(json['gallery']) : null;
    video = json['video'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPriceHotel>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(ExtraPriceHotel.fromJson(v));
      });
    }
    reviewScore = json['review_score'] != null
        ? ReviewScore.fromJson(json['review_score'])
        : null;
    reviewStats = json['review_stats'] != null
        ? List<String>.from(json['review_stats'])
        : null;
    reviewLists = json['review_lists'] != null
        ? ReviewLists.fromJson(json['review_lists'])
        : null;
    if (json['policy'] != null) {
      policy = <Policy>[];
      json['policy'].forEach((v) {
        policy!.add(Policy.fromJson(v));
      });
    }
    starRate = json['star_rate'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    allowFullDay = json['allow_full_day'];
    if (json['booking_fee'] != null) {
      bookingFee = <BookingFee>[];
      json['booking_fee'].forEach((v) {
        bookingFee!.add(BookingFee.fromJson(v));
      });
    }
    if (json['related'] != null) {
      related = <Related>[];
      json['related'].forEach((v) {
        related!.add(Related.fromJson(v));
      });
    }
    // if (json['terms'] != null) {
    //   terms = <Terms>[];
    //   json['terms'].forEach((v) {
    //     terms!.add(Terms.fromJson(v));
    //   });
    // }
    terms = parseMapOrList(json['terms'], (v) => Terms.fromJson(v));

    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    shareUrl = json['share_url'];
    isInWishlist = json['is_in_wishlist'];
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
    if (reviewScore != null) {
      data['review_score'] = reviewScore!.toJson();
    }
    data['review_stats'] = reviewStats;
    if (reviewLists != null) {
      data['review_lists'] = reviewLists!.toJson();
    }
    if (policy != null) {
      data['policy'] = policy!.map((v) => v.toJson()).toList();
    }
    data['star_rate'] = starRate;
    data['check_in_time'] = checkInTime;
    data['check_out_time'] = checkOutTime;
    data['allow_full_day'] = allowFullDay;
    if (bookingFee != null) {
      data['booking_fee'] = bookingFee!.map((v) => v.toJson()).toList();
    }
    if (related != null) {
      data['related'] = related!.map((v) => v.toJson()).toList();
    }
    if (terms != null) {
      data['terms'] = terms!.map((v) => v.toJson()).toList();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['share_url'] = shareUrl;
    data['is_in_wishlist'] = isInWishlist;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ExtraPriceHotel {
  String? name;
  String? price;
  String? type;
  bool? valueType;

  ExtraPriceHotel({this.name, this.price, this.type, this.valueType = false});

  ExtraPriceHotel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    valueType = json['value_type'] ?? false;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data["value_type"] = valueType;

    data['type'] = type;
    return data;
  }
}

class ReviewScore {
  String? scoreTotal;
  String? scoreText;
  int? totalReview;
  List<RateScore>? rateScore;

  ReviewScore(
      {this.scoreTotal, this.scoreText, this.totalReview, this.rateScore});

  ReviewScore.fromJson(Map<String, dynamic> json) {
    scoreTotal = json['score_total'].toString();
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
  final String title;
  final int total;
  final int percent;

  RateScore({required this.title, required this.total, required this.percent});

  factory RateScore.fromJson(Map<String, dynamic> json) {
    return RateScore(
      title: json['title'] ?? '',
      total: json['total'] ?? 0,
      percent: json['percent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'total': total,
      'percent': percent,
    };
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
      data = <ReviewData>[]; // Change Data to ReviewData
      json['data'].forEach((v) {
        data!.add(ReviewData.fromJson(v)); // Use ReviewData instead of Data
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
  int? avatarId;
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
    avatarUrl = json['avatar_url'];
    avatarId = json['avatar_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['avatar_id'] = avatarId;
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

class Policy {
  String? title;
  String? content;

  Policy({this.title, this.content});

  Policy.fromJson(Map<String, dynamic> json) {
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
  RelatedReviewScore? reviewScore;

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
    reviewScore = json['review_score'] != null
        ? RelatedReviewScore.fromJson(json['review_score'])
        : null;
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
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['is_featured'] = isFeatured;
    if (reviewScore != null) {
      data['review_score'] = reviewScore!.toJson();
    }
    return data;
  }
}

class RelatedReviewScore {
  dynamic scoreTotal;
  int? totalReview;
  String? reviewText;

  RelatedReviewScore({this.scoreTotal, this.totalReview, this.reviewText});

  RelatedReviewScore.fromJson(Map<String, dynamic> json) {
    scoreTotal = json['score_total'];
    totalReview = json['total_review'];
    reviewText = json['review_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score_total'] = scoreTotal;
    data['total_review'] = totalReview;
    data['review_text'] = reviewText;
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
  String? imageUrl; // New field added

  Child({
    this.id,
    this.title,
    this.content,
    this.imageId,
    this.icon,
    this.attrId,
    this.slug,
    this.imageUrl, // New field added to constructor
  });

  Child.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    imageId = json['image_id'];
    icon = json['icon'];
    attrId = json['attr_id'];
    slug = json['slug'];
    imageUrl = json['image_url']; // New field parsed from JSON
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
    data['image_url'] = imageUrl; // New field added to JSON output
    return data;
  }
}

class Availability {
  dynamic headers;
  Original? original;
  dynamic exception;

  Availability({this.headers, this.original, this.exception});

  Availability.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      headers = json['headers'];
      original =
          json['original'] != null ? Original.fromJson(json['original']) : null;
      exception = json['exception'];
    } else if (json is List && json.isNotEmpty) {
      // Assuming the first item contains the availability data
      var firstItem = json.first;
      if (firstItem is Map<String, dynamic>) {
        headers = firstItem['headers'];
        original = firstItem['original'] != null
            ? Original.fromJson(firstItem['original'])
            : null;
        exception = firstItem['exception'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (headers != null) {
      data['headers'] = headers!.toJson();
    }
    if (original != null) {
      data['original'] = original!.toJson();
    }
    data['exception'] = exception;
    return data;
  }
}

class Original {
  List<Rooms>? rooms;
  int? status;

  Original({this.rooms, this.status});

  Original.fromJson(Map<String, dynamic> json) {
    //   if (json['rooms'] != null) {
    //     rooms = <Rooms>[];
    //     json['rooms'].forEach((v) {
    //       rooms!.add(Rooms.fromJson(v));
    //     });
    //   }
    //   status = json['status'];
    rooms = parseMapOrList(json['rooms'], (v) => Rooms.fromJson(v));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rooms != null) {
      data['rooms'] = rooms!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Rooms {
  int? id;
  String? title;
  int? price;
  String? sizeHtml;
  String? bedsHtml;
  String? adultsHtml;
  String? childrenHtml;
  int? numberSelected;
  int? number;
  int? minDayStays;
  String? image;
  dynamic tmpNumber;
  List<Gallery>? gallery;
  String? priceHtml;
  String? priceText;
  List<Terms>? terms;
  List<TermFeatures>? termFeatures;

  Rooms(
      {this.id,
      this.title,
      this.price,
      this.sizeHtml,
      this.bedsHtml,
      this.adultsHtml,
      this.childrenHtml,
      this.numberSelected,
      this.number,
      this.minDayStays,
      this.image,
      this.tmpNumber,
      this.gallery,
      this.priceHtml,
      this.priceText,
      this.terms,
      this.termFeatures});

  Rooms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    sizeHtml = json['size_html'];
    bedsHtml = json['beds_html'];
    adultsHtml = json['adults_html'];
    childrenHtml = json['children_html'];
    numberSelected = json['number_selected'];
    number = json['number'];
    minDayStays = json['min_day_stays'];
    image = json['image'];
    tmpNumber = json['tmp_number'];
    if (json['gallery'] != null) {
      gallery = <Gallery>[];
      json['gallery'].forEach((v) {
        gallery!.add(Gallery.fromJson(v));
      });
    }
    priceHtml = json['price_html'];
    priceText = json['price_text'];
    // if (json['terms'] != null) {
    //   terms = <Terms>[];
    //   json['terms'].forEach((v) {
    //     terms!.add(Terms.fromJson(v));
    //   });
    // }
    terms = parseMapOrList(json['terms'], (v) => Terms.fromJson(v));

    if (json['term_features'] != null) {
      termFeatures = <TermFeatures>[];
      json['term_features'].forEach((v) {
        termFeatures!.add(TermFeatures.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['size_html'] = sizeHtml;
    data['beds_html'] = bedsHtml;
    data['adults_html'] = adultsHtml;
    data['children_html'] = childrenHtml;
    data['number_selected'] = numberSelected;
    data['number'] = number;
    data['min_day_stays'] = minDayStays;
    data['image'] = image;
    data['tmp_number'] = tmpNumber;
    if (gallery != null) {
      data['gallery'] = gallery!.map((v) => v.toJson()).toList();
    }
    data['price_html'] = priceHtml;
    data['price_text'] = priceText;
    if (terms != null) {
      data['terms'] = terms!.map((v) => v.toJson()).toList();
    }
    if (termFeatures != null) {
      data['term_features'] = termFeatures!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Gallery {
  String? large;
  String? thumb;

  Gallery({this.large, this.thumb});

  Gallery.fromJson(Map<String, dynamic> json) {
    large = json['large'];
    thumb = json['thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['large'] = large;
    data['thumb'] = thumb;
    return data;
  }
}

class TermFeatures {
  String? icon;
  String? title;

  TermFeatures({this.icon, this.title});

  TermFeatures.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['icon'] = icon;
    data['title'] = title;
    return data;
  }
}

class Vendor {
  int? id;
  String? name;
  String? email;
  String? createdAt;
  String? avatarUrl;

  Vendor({
    this.id,
    this.name,
    this.email,
    this.createdAt,
    this.avatarUrl,
  });

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
