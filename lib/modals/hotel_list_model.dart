class HotelList {
  List<Hotel>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? startId;
  int? endId;
  int? status;

  HotelList(
      {this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.perPage,
      this.startId,
      this.endId,
      this.status});

  HotelList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Hotel>[];
      json['data'].forEach((v) {
        data!.add(Hotel.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    startId = json['start_id'];
    endId = json['end_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['start_id'] = startId;
    data['end_id'] = endId;
    data['status'] = status;
    return data;
  }
}

class Hotel {
  int? id;
  String? title;
  String? slug;
  String? content;
  int? imageId;
  int? bannerImageId;
  int? locationId;
  String? address;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  int? isFeatured;
  List<String>? gallery;
  String? video;
  List<Policy>? policy;
  int? starRate;
  String? price;
  String? checkInTime;
  String? checkOutTime;
  dynamic allowFullDay;
  dynamic salePrice;
  dynamic relatedIds;
  String? status;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  String? reviewScore;
  dynamic icalImportUrl;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  dynamic enableServiceFee;
  dynamic serviceFee;
  dynamic surrounding;
  int? authorId;
  dynamic minDayBeforeBooking;
  dynamic minDayStays;
  String? reviewText;
  int? reviewCount;
  bool? isInWishlist;
  String? bannerImgUrl;
  Translation? translation;
  Location? location;
  dynamic hasWishList;

  Hotel(
      {this.id,
      this.title,
      this.slug,
      this.content,
      this.imageId,
      this.bannerImageId,
      this.locationId,
      this.address,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.isFeatured,
      this.gallery,
      this.video,
      this.policy,
      this.starRate,
      this.price,
      this.checkInTime,
      this.checkOutTime,
      this.allowFullDay,
      this.salePrice,
      this.relatedIds,
      this.status,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.reviewScore,
      this.icalImportUrl,
      this.enableExtraPrice,
      this.extraPrice,
      this.enableServiceFee,
      this.serviceFee,
      this.surrounding,
      this.authorId,
      this.minDayBeforeBooking,
      this.minDayStays,
      this.reviewText,
      this.reviewCount,
      this.isInWishlist,
      this.bannerImgUrl,
      this.translation,
      this.location,
      this.hasWishList});

  Hotel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    imageId = json['image_id'];
    bannerImageId = json['banner_image_id'];
    locationId = json['location_id'];
    address = json['address'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    isFeatured = json['is_featured'];
    if (json['gallery'] != null) {
      gallery = <String>[];
      json['gallery'].forEach((v) {
        gallery?.add(v);
      });
    }
    video = json['video'];
    if (json['policy'] != null) {
      policy = <Policy>[];
      json['policy'].forEach((v) {
        policy!.add(Policy.fromJson(v));
      });
    }
    starRate = json['star_rate'];
    price = json['price'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    allowFullDay = json['allow_full_day'];
    salePrice = json['sale_price'];
    relatedIds = json['related_ids'];
    status = json['status'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reviewScore = json['review_score'].toString();
    icalImportUrl = json['ical_import_url'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(ExtraPrice.fromJson(v));
      });
    }
    enableServiceFee = json['enable_service_fee'];
    serviceFee = json['service_fee'];
    surrounding = json['surrounding'];
    authorId = json['author_id'];
    minDayBeforeBooking = json['min_day_before_booking'];
    minDayStays = json['min_day_stays'];
    reviewText = json['review_text'];
    reviewCount = json['review_count'];
    isInWishlist = json['is_in_wishlist'] ?? false;
    bannerImgUrl = json['banner_img_url'];
    translation = json['translation'] != null
        ? new Translation.fromJson(json['translation'])
        : null;
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    hasWishList = json['has_wish_list'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['content'] = content;
    data['image_id'] = imageId;
    data['banner_image_id'] = bannerImageId;
    data['location_id'] = locationId;
    data['address'] = address;
    data['map_lat'] = mapLat;
    data['map_lng'] = mapLng;
    data['map_zoom'] = mapZoom;
    data['is_featured'] = isFeatured;
    data['gallery'] = gallery;
    data['video'] = video;
    if (policy != null) {
      data['policy'] = policy!.map((v) => v.toJson()).toList();
    }
    data['star_rate'] = starRate;
    data['price'] = price;
    data['check_in_time'] = checkInTime;
    data['check_out_time'] = checkOutTime;
    data['allow_full_day'] = allowFullDay;
    data['sale_price'] = salePrice;
    data['related_ids'] = relatedIds;
    data['status'] = status;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['review_score'] = reviewScore;
    data['ical_import_url'] = icalImportUrl;
    data['enable_extra_price'] = enableExtraPrice;
    if (extraPrice != null) {
      data['extra_price'] = extraPrice!.map((v) => v.toJson()).toList();
    }
    data['enable_service_fee'] = enableServiceFee;
    data['service_fee'] = serviceFee;
    data['surrounding'] = surrounding;
    data['author_id'] = authorId;
    data['min_day_before_booking'] = minDayBeforeBooking;
    data['min_day_stays'] = minDayStays;
    data['review_text'] = reviewText;
    data['review_count'] = reviewCount;
    data['is_in_wishlist'] = isInWishlist;
    data['banner_img_url'] = bannerImgUrl;
    if (translation != null) {
      data['translation'] = translation!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['has_wish_list'] = hasWishList;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = title;
    data['content'] = content;
    return data;
  }
}

class ExtraPrice {
  String? name;
  String? price;
  String? type;
  dynamic nameJa;
  dynamic nameEgy;

  ExtraPrice({this.name, this.price, this.type, this.nameJa, this.nameEgy});

  ExtraPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    type = json['type'];
    nameJa = json['name_ja'];
    nameEgy = json['name_egy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['type'] = type;
    data['name_ja'] = nameJa;
    data['name_egy'] = nameEgy;
    return data;
  }
}

class Translation {
  int? id;
  int? originId;
  String? locale;
  String? title;
  String? content;
  String? address;
  List<Policy>? policy;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic surrounding;

  Translation(
      {this.id,
      this.originId,
      this.locale,
      this.title,
      this.content,
      this.address,
      this.policy,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.surrounding});

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    originId = json['origin_id'];
    locale = json['locale'];
    title = json['title'];
    content = json['content'];
    address = json['address'];
    if (json['policy'] != null) {
      policy = <Policy>[];
      json['policy'].forEach((v) {
        policy!.add(Policy.fromJson(v));
      });
    }
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    surrounding = json['surrounding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['origin_id'] = originId;
    data['locale'] = locale;
    data['title'] = title;
    data['content'] = content;
    data['address'] = address;
    if (policy != null) {
      data['policy'] = policy!.map((v) => v.toJson()).toList();
    }
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['surrounding'] = surrounding;
    return data;
  }
}

class Location {
  int? id;
  String? name;
  String? content;
  String? slug;
  int? imageId;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? status;
  int? iLft;
  int? iRgt;
  dynamic parentId;
  int? createUser;
  dynamic updateUser;
  dynamic deletedAt;
  dynamic originId;
  dynamic lang;
  String? createdAt;
  String? updatedAt;
  int? bannerImageId;
  // String? tripIdeas;
  dynamic gallery;
  dynamic translation;

  Location(
      {this.id,
      this.name,
      this.content,
      this.slug,
      this.imageId,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.status,
      this.iLft,
      this.iRgt,
      this.parentId,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.originId,
      this.lang,
      this.createdAt,
      this.updatedAt,
      this.bannerImageId,
      // this.tripIdeas,
      this.gallery,
      this.translation});

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    content = json['content'];
    slug = json['slug'];
    imageId = json['image_id'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    status = json['status'];
    iLft = json['_lft'];
    iRgt = json['_rgt'];
    parentId = json['parent_id'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    originId = json['origin_id'];
    lang = json['lang'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bannerImageId = json['banner_image_id'];
    // tripIdeas = json['trip_ideas'] ?? "";
    gallery = json['gallery'];
    translation = json['translation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['content'] = content;
    data['slug'] = slug;
    data['image_id'] = imageId;
    data['map_lat'] = mapLat;
    data['map_lng'] = mapLng;
    data['map_zoom'] = mapZoom;
    data['status'] = status;
    data['_lft'] = iLft;
    data['_rgt'] = iRgt;
    data['parent_id'] = parentId;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['origin_id'] = originId;
    data['lang'] = lang;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['banner_image_id'] = bannerImageId;
    // data['trip_ideas'] = tripIdeas;
    data['gallery'] = gallery;
    data['translation'] = translation;
    return data;
  }


}
