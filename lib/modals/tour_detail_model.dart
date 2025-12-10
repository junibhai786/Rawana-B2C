// ignore_for_file: prefer_collection_literals

import 'package:moonbnd/modals/model_helper/list_map_dynamic.dart';

class TourDetailModal {
  Data? data;
  dynamic availability;
  int? status;

  TourDetailModal({this.data, this.availability, this.status});

  TourDetailModal.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    availability = json['availability'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['availability'] = availability;
    data['status'] = status;
    return data;
  }
}

class Data {
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
  String? address;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? bannerImage;
  List<String>? gallery;
  String? video;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  String? duration;
  Vendor? vendor;
  String? shareUrl;
  bool? isWishlist;
  ReviewScore? reviewScore;
  List<String>? reviewStats;
  ReviewLists? reviewLists;
  Location? category;
  int? minPeople;
  int? maxPeople;
  List<Faqs>? faqs;
  List<Include>? include;
  List<Exclude>? exclude;
  List<Itinerary>? itinerary;
  List<PersonTypes>? personTypes;
  dynamic discountByPeople;
  int? enableOpenHours;
  dynamic openHours;
  List<BookingFee>? bookingFee;
  List<Related>? related;
  List<Terms>? terms;

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
      this.duration,
      this.vendor,
      this.shareUrl,
      this.isWishlist,
      this.reviewScore,
      this.reviewStats,
      this.reviewLists,
      this.category,
      this.minPeople,
      this.maxPeople,
      this.faqs,
      this.include,
      this.exclude,
      this.itinerary,
      this.personTypes,
      this.discountByPeople,
      this.enableOpenHours,
      this.openHours,
      this.bookingFee,
      this.related,
      this.terms});

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
    gallery = json['gallery'].cast<String>();
    video = json['video'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(ExtraPrice.fromJson(v));
      });
    }
    duration = json['duration'];
    vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    shareUrl = json['share_url'];
    isWishlist = json['is_in_wishlist'];
    reviewScore = json['review_score'] != null
        ? ReviewScore.fromJson(json['review_score'])
        : null;
    reviewStats = json['review_stats'].cast<String>();
    reviewLists = json['review_lists'] != null
        ? ReviewLists.fromJson(json['review_lists'])
        : null;
    category =
        json['category'] != null ? Location.fromJson(json['category']) : null;
    minPeople = json['min_people'];
    maxPeople = json['max_people'];
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faqs.fromJson(v));
      });
    }
    if (json['include'] != null) {
      include = <Include>[];
      json['include'].forEach((v) {
        include!.add(Include.fromJson(v));
      });
    }
    if (json['exclude'] != null) {
      exclude = <Exclude>[];
      json['exclude'].forEach((v) {
        exclude!.add(Exclude.fromJson(v));
      });
    }
    if (json['itinerary'] != null) {
      itinerary = <Itinerary>[];
      json['itinerary'].forEach((v) {
        itinerary!.add(Itinerary.fromJson(v));
      });
    }
    if (json['person_types'] != null) {
      personTypes = <PersonTypes>[];
      json['person_types'].forEach((v) {
        personTypes!.add(PersonTypes.fromJson(v));
      });
    }
    discountByPeople = json['discount_by_people'];
    enableOpenHours = json['enable_open_hours'];
    openHours = json['open_hours'];
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
    terms = parseMapOrList(json['terms'], (v) => Terms.fromJson(v));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    data['duration'] = duration;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['share_url'] = shareUrl;
    data['is_in_wishlist'] = isWishlist;
    if (reviewScore != null) {
      data['review_score'] = reviewScore!.toJson();
    }
    data['review_stats'] = reviewStats;
    if (reviewLists != null) {
      data['review_lists'] = reviewLists!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['min_people'] = minPeople;
    data['max_people'] = maxPeople;
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    if (include != null) {
      data['include'] = include!.map((v) => v.toJson()).toList();
    }
    if (exclude != null) {
      data['exclude'] = exclude!.map((v) => v.toJson()).toList();
    }
    if (itinerary != null) {
      data['itinerary'] = itinerary!.map((v) => v.toJson()).toList();
    }
    if (personTypes != null) {
      data['person_types'] = personTypes!.map((v) => v.toJson()).toList();
    }
    data['discount_by_people'] = discountByPeople;
    data['enable_open_hours'] = enableOpenHours;
    data['open_hours'] = openHours;
    if (bookingFee != null) {
      data['booking_fee'] = bookingFee!.map((v) => v.toJson()).toList();
    }
    if (related != null) {
      data['related'] = related!.map((v) => v.toJson()).toList();
    }
    if (terms != null) {
      data['terms'] = terms!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ExtraPrice {
  String? name;
  String? namear;
  String? price;
  String? type;
  bool? valueType;

  ExtraPrice(
      {this.name, this.namear, this.price, this.type, this.valueType = false});

  ExtraPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    namear = json['namear'];
    price = json['price'];
    type = json['type'];
    valueType = json['value_type'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['namear'] = namear;
    data['price'] = price;
    data['type'] = type;
    data['value_type'] = valueType;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['created_at'] = createdAt;
    data['avatar_url'] = avatarUrl;
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
    scoreTotal = json['score_total'];
    scoreText = json['score_text'];
    totalReview = json['total_review'];
    rateScore =
        parseMapOrList(json['rate_score'], (v) => RateScore.fromJson(v));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
  dynamic lastName;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['content'] = content;
    return data;
  }
}

class Include {
  String? title;

  Include({this.title});

  Include.fromJson(Map<String, dynamic> json) {
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    return data;
  }
}

class Exclude {
  String? title;

  Exclude({this.title});

  Exclude.fromJson(Map<String, dynamic> json) {
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    return data;
  }
}

class Itinerary {
  String? imageId;
  String? title;
  String? desc;
  String? content;
  String? image;

  Itinerary({this.imageId, this.title, this.desc, this.content, this.image});

  Itinerary.fromJson(Map<String, dynamic> json) {
    imageId = json['image_id'];
    title = json['title'];
    desc = json['desc'];
    content = json['content'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['image_id'] = imageId;
    data['title'] = title;
    data['desc'] = desc;
    data['content'] = content;
    data['image'] = image;
    return data;
  }
}

class PersonTypes {
  String? name;
  String? namear;
  String? desc;
  String? descar;
  String? min;
  String? max;
  String? price;
  int? count;

  PersonTypes(
      {this.name,
      this.namear,
      this.desc,
      this.descar,
      this.count = 0,
      this.min,
      this.max,
      this.price});

  PersonTypes.fromJson(Map<String, dynamic> json) {
    name = json['name'];

    namear = json['name_ar'];
    desc = json['desc'];
    descar = json['desc_ar'];
    min = json['min'];
    max = json['max'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['name_ar'] = namear;
    data['desc'] = desc;
    data['desc_ar'] = descar;
    data['min'] = min;
    data['max'] = max;
    data['price'] = price;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
  String? duration;
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
      this.duration,
      this.reviewScore});

  Related.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    objectModel = json['object_model'];
    title = json['title'];
    price = json['price'];
    salePrice = json['sale_price'] ?? "";
    discountPercent = json['discount_percent'];
    image = json['image'];
    content = json['content'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    isFeatured = json['is_featured'];
    duration = json['duration'];
    reviewScore = json['review_score'] != null
        ? ReviewScore.fromJson(json['review_score'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    data['duration'] = duration;
    if (reviewScore != null) {
      data['review_score'] = reviewScore!.toJson();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['image_id'] = imageId;
    data['image_url'] = imageUrl;
    data['icon'] = icon;
    data['attr_id'] = attrId;
    data['slug'] = slug;
    return data;
  }
}
