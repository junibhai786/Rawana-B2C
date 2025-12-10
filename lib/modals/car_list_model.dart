class CarList {
  List<Car>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? status;
  int? startId;
  int? endId;

  CarList(
      {this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.perPage,
      this.status,
      this.startId,
      this.endId});

  CarList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Car>[];
      json['data'].forEach((v) {
        data!.add(new Car.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
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
    data['status'] = status;
    return data;
  }
}

class Car {
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
  String? detailsurl;

  List<Faqs>? faqs;
  int? number;
  int? price;
  int? salePrice;
  int? isInstant;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  String? discountByDays;
  int? passenger;
  String? gear;
  int? baggage;
  int? door;
  String? status;
  int? defaultState;
  int? createUser;

  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic reviewScore;
  String? enableServiceFee;
  String? serviceFee;
  int? authorId;
  String? icalImportUrl;
  int? minDayBeforeBooking;
  int? minDayStays;
  String? reviewText;
  int? reviewCount;
  bool? isInWishlist;
  String? bannerImgUrl;
  String? locationName;
  String? availability_url;
  Translation? translation;
  Location? location;
  dynamic hasWishList;

  Car(
      {this.id,
      this.title,
      this.slug,
      this.content,
      this.imageId,
      this.bannerImageId,
      this.availability_url,
      this.locationId,
      this.address,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.isFeatured,
      this.gallery,
      this.video,
      this.faqs,
      this.detailsurl,
      this.number,
      this.price,
      this.salePrice,
      this.isInstant,
      this.enableExtraPrice,
      this.extraPrice,
      this.discountByDays,
      this.passenger,
      this.gear,
      this.baggage,
      this.door,
      this.status,
      this.defaultState,
      this.createUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.reviewScore,
      this.enableServiceFee,
      this.serviceFee,
      this.authorId,
      this.icalImportUrl,
      this.minDayBeforeBooking,
      this.minDayStays,
      this.reviewText,
      this.reviewCount,
      this.isInWishlist,
      this.bannerImgUrl,
      this.locationName,
      this.translation,
      this.location,
      this.hasWishList});

  Car.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    imageId = json['image_id'];
    bannerImageId = json['banner_image_id'];
    locationId = json['location_id'];
    address = json['address'];
    detailsurl = json['details_url'];

    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    availability_url = json['availability_url'];
    isFeatured = json['is_featured'];
    gallery = json['gallery'] != null ? json['gallery'].cast<String>() : [];
    video = json['video'];
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faqs.fromJson(v));
      });
    }
    number = json['number'];
    price = json['price'];
    salePrice = json['sale_price'];
    isInstant = json['is_instant'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(new ExtraPrice.fromJson(v));
      });
    }
    discountByDays = json['discount_by_days'];
    passenger = json['passenger'];
    gear = json['gear'];
    baggage = json['baggage'];
    door = json['door'];
    status = json['status'];
    defaultState = json['default_state'];
    createUser = json['create_user'];

    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reviewScore = json['review_score'];
    enableServiceFee = json['enable_service_fee'];
    serviceFee = json['service_fee'];
    authorId = json['author_id'];
    icalImportUrl = json['ical_import_url'];
    minDayBeforeBooking = json['min_day_before_booking'] ?? 0;
    minDayStays = json['min_day_stays'] ?? 0;
    reviewText = json['review_text'];
    reviewCount = json['review_count'];
    isInWishlist = json['is_in_wishlist'] ?? false;
    bannerImgUrl = json['banner_img_url'];
    locationName = json['location_name'];
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
    data['details_url'] = detailsurl;

    data['address'] = address;
    data['availability_url'] = availability_url;
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
    data['price'] = price;
    data['sale_price'] = salePrice;
    data['is_instant'] = isInstant;
    data['enable_extra_price'] = enableExtraPrice;
    if (extraPrice != null) {
      data['extra_price'] = extraPrice!.map((v) => v.toJson()).toList();
    }
    data['discount_by_days'] = discountByDays;
    data['passenger'] = passenger;
    data['gear'] = gear;
    data['baggage'] = baggage;
    data['door'] = door;
    data['status'] = status;
    data['default_state'] = defaultState;
    data['create_user'] = createUser;

    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['review_score'] = reviewScore;
    data['enable_service_fee'] = enableServiceFee;
    data['service_fee'] = serviceFee;
    data['author_id'] = authorId;
    data['ical_import_url'] = icalImportUrl;
    data['min_day_before_booking'] = minDayBeforeBooking;
    data['min_day_stays'] = minDayStays;
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
  String? nameJa;
  String? nameEgy;

  ExtraPrice({this.name, this.price, this.type, this.nameJa, this.nameEgy});

  ExtraPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    type = json['type'];
    nameJa = json['name_ja'];
    nameEgy = json['name_egy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  List<Faqs>? faqs;
  String? address;
  int? createUser;
  String? updateUser;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  Translation(
      {this.id,
      this.originId,
      this.locale,
      this.title,
      this.content,
      this.faqs,
      this.address,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt});

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    originId = json['origin_id'];
    locale = json['locale'];
    title = json['title'];
    content = json['content'];
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(new Faqs.fromJson(v));
      });
    }
    address = json['address'];
    createUser = json['create_user'];

    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['origin_id'] = originId;
    data['locale'] = locale;
    data['title'] = title;
    data['content'] = content;
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    data['address'] = address;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
  String? parentId;
  int? createUser;

  String? deletedAt;
  String? originId;
  String? lang;
  String? createdAt;
  String? updatedAt;
  int? bannerImageId;
  // String? tripIdeas;
  String? gallery;

  Location({
    this.id,
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
    this.deletedAt,
    this.originId,
    this.lang,
    this.createdAt,
    this.updatedAt,
    this.bannerImageId,
    // this.tripIdeas,
    this.gallery,
  });

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

    deletedAt = json['deleted_at'];
    originId = json['origin_id'];
    lang = json['lang'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bannerImageId = json['banner_image_id'];
    // tripIdeas = json['trip_ideas'] ?? "";
    gallery = json['gallery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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

    data['deleted_at'] = deletedAt;
    data['origin_id'] = originId;
    data['lang'] = lang;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['banner_image_id'] = bannerImageId;
    // data['trip_ideas'] = tripIdeas;
    data['gallery'] = gallery;

    return data;
  }
}
