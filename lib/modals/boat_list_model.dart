class BoatList {
  List<Boat>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? status;
  int? startId; // Add this line
  int? endId; // Add this line
  String? text;

  BoatList({
    this.data,
    this.total,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.status,
    this.startId, // Add this line
    this.endId, // Add this line
    this.text,
  });

  BoatList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Boat>[];
      json['data'].forEach((v) {
        data!.add(Boat.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    status = json['status'];
    startId = json['start_id']; // Add this line
    endId = json['end_id']; // Add this line
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['status'] = status;
    data['start_id'] = startId; // Add this line
    data['end_id'] = endId; // Add this line
    data['text'] = text;
    return data;
  }
}

class Boat {
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
  List<Faqs>? faqs;
  int? number;
  String? pricePerHour;
  String? pricePerDay;
  String? minPrice;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  int? maxGuest;
  int? cabin;
  String? length;
  String? speed;
  List<Specs>? specs;
  String? cancelPolicy;
  String? termsInformation;
  dynamic reviewScore;
  String? status;
  int? defaultState;
  dynamic enableServiceFee;
  dynamic serviceFee;
  dynamic minDayBeforeBooking;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  int? authorId;
  dynamic include;
  dynamic exclude;
  dynamic startTimeBooking;
  dynamic endTimeBooking;
  String? reviewText;
  int? reviewCount;
  bool? isInWishlist;
  String? bannerImgUrl;
  String? locationName;
  Translation? translation;
  Location? location;
  dynamic hasWishList;

  Boat(
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
      this.faqs,
      this.number,
      this.pricePerHour,
      this.pricePerDay,
      this.minPrice,
      this.enableExtraPrice,
      this.extraPrice,
      this.maxGuest,
      this.cabin,
      this.length,
      this.speed,
      this.specs,
      this.cancelPolicy,
      this.termsInformation,
      this.reviewScore,
      this.status,
      this.defaultState,
      this.enableServiceFee,
      this.serviceFee,
      this.minDayBeforeBooking,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.authorId,
      this.include,
      this.exclude,
      this.startTimeBooking,
      this.endTimeBooking,
      this.reviewText,
      this.reviewCount,
      this.isInWishlist,
      this.bannerImgUrl,
      this.locationName,
      this.translation,
      this.location,
      this.hasWishList});

  Boat.fromJson(Map<String, dynamic> json) {
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

    // ✅ Handle both gallery array and single image URL
    if (json['gallery'] != null) {
      gallery = json['gallery'].cast<String>();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      // ✅ If no gallery but image exists, use it
      gallery = [json['image'].toString()];
      print("IMAGE URL => ${json['image']}");
    } else if (json['banner_img_url'] != null &&
        json['banner_img_url'].toString().isNotEmpty) {
      // ✅ Fallback to banner_img_url
      gallery = [json['banner_img_url'].toString()];
      print("IMAGE URL => ${json['banner_img_url']}");
    } else {
      gallery = [];
    }

    video = json['video'];
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faqs.fromJson(v));
      });
    }
    number = json['number'];
    pricePerHour = json['price_per_hour'];
    pricePerDay = json['price_per_day'];
    minPrice = json['min_price'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(ExtraPrice.fromJson(v));
      });
    }
    maxGuest = json['max_guest'];
    cabin = json['cabin'];
    length = json['length'];
    speed = json['speed'];
    if (json['specs'] != null) {
      specs = <Specs>[];
      json['specs'].forEach((v) {
        specs!.add(Specs.fromJson(v));
      });
    }
    cancelPolicy = json['cancel_policy'];
    termsInformation = json['terms_information'];
    reviewScore = json['review_score'] ?? 0;
    status = json['status'];
    defaultState = json['default_state'];
    enableServiceFee = json['enable_service_fee'];
    serviceFee = json['service_fee'];
    minDayBeforeBooking = json['min_day_before_booking'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    authorId = json['author_id'];
    include = json['include'];
    exclude = json['exclude'];
    startTimeBooking = json['start_time_booking'];
    endTimeBooking = json['end_time_booking'];
    reviewText = json['review_text'];
    reviewCount = json['review_count'];
    isInWishlist = json['is_in_wishlist'] ?? false;
    bannerImgUrl = json['banner_img_url'];
    locationName = json['location_name'];
    translation = json['translation'] != null
        ? Translation.fromJson(json['translation'])
        : null;
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    hasWishList = json['has_wish_list'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    data['number'] = number;
    data['price_per_hour'] = pricePerHour;
    data['price_per_day'] = pricePerDay;
    data['min_price'] = minPrice;
    data['enable_extra_price'] = enableExtraPrice;
    if (extraPrice != null) {
      data['extra_price'] = extraPrice!.map((v) => v.toJson()).toList();
    }
    data['max_guest'] = maxGuest;
    data['cabin'] = cabin;
    data['length'] = length;
    data['speed'] = speed;
    if (specs != null) {
      data['specs'] = specs!.map((v) => v.toJson()).toList();
    }
    data['cancel_policy'] = cancelPolicy;
    data['terms_information'] = termsInformation;
    data['review_score'] = reviewScore;
    data['status'] = status;
    data['default_state'] = defaultState;
    data['enable_service_fee'] = enableServiceFee;
    data['service_fee'] = serviceFee;
    data['min_day_before_booking'] = minDayBeforeBooking;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['author_id'] = authorId;
    data['include'] = include;
    data['exclude'] = exclude;
    data['start_time_booking'] = startTimeBooking;
    data['end_time_booking'] = endTimeBooking;
    data['review_text'] = reviewText;
    data['review_count'] = reviewCount;
    data['is_in_wishlist'] = isInWishlist;
    data['banner_img_url'] = bannerImgUrl;
    data['location_name'] = locationName;
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

class ExtraPrice {
  String? name;
  dynamic nameJa;
  dynamic nameEgy;
  String? price;
  String? type;

  ExtraPrice({this.name, this.nameJa, this.nameEgy, this.price, this.type});

  ExtraPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nameJa = json['name_ja'];
    nameEgy = json['name_egy'];
    price = json['price'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['name_ja'] = nameJa;
    data['name_egy'] = nameEgy;
    data['price'] = price;
    data['type'] = type;
    return data;
  }
}

class Translation {
  int? id;
  int? originId;
  String? locale;
  String? title;
  String? content;
  List<Faqs>? faqs;
  List<Specs>? specs;
  String? cancelPolicy;
  String? termsInformation;
  String? address;
  int? createUser;
  dynamic updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic include;
  dynamic exclude;

  Translation(
      {this.id,
      this.originId,
      this.locale,
      this.title,
      this.content,
      this.faqs,
      this.specs,
      this.cancelPolicy,
      this.termsInformation,
      this.address,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.include,
      this.exclude});

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    originId = json['origin_id'];
    locale = json['locale'];
    title = json['title'];
    content = json['content'];
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faqs.fromJson(v));
      });
    }
    if (json['specs'] != null) {
      specs = <Specs>[];
      json['specs'].forEach((v) {
        specs!.add(Specs.fromJson(v));
      });
    }
    cancelPolicy = json['cancel_policy'];
    termsInformation = json['terms_information'];
    address = json['address'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    include = json['include'];
    exclude = json['exclude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['origin_id'] = originId;
    data['locale'] = locale;
    data['title'] = title;
    data['content'] = content;
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    if (specs != null) {
      data['specs'] = specs!.map((v) => v.toJson()).toList();
    }
    data['cancel_policy'] = cancelPolicy;
    data['terms_information'] = termsInformation;
    data['address'] = address;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['include'] = include;
    data['exclude'] = exclude;
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
    // tripIdeas = json['trip_ideas'];
    gallery = json['gallery'];
    translation = json['translation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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

class Specs {
  String? name;
  String? content;

  Specs({
    this.name,
    this.content,
  });

  Specs.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['name'] = name;
    data['content'] = content;

    return data;
  }
}
