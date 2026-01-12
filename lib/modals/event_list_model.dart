class EventList {
  List<Event>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? startId;
  int? endId;
  int? status;

  EventList(
      {this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.perPage,
      this.startId,
      this.endId,
      this.status});

  EventList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Event>[];
      json['data'].forEach((v) {
        data!.add(new Event.fromJson(v));
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

class Event {
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
  List<TicketTypes>? ticketTypes;
  String? duration;
  String? startTime;
  int? price;
  int? salePrice;
  int? isInstant;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  dynamic reviewScore;
  dynamic icalImportUrl;
  String? status;
  int? defaultState;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic enableServiceFee;
  dynamic serviceFee;
  dynamic surrounding;
  dynamic endTime;
  String? durationUnit;
  int? authorId;
  String? reviewText;
  int? reviewCount;
  bool? isInWishlist;
  String? bannerImgUrl;
  String? locationName;
  int? discount;
  Translation? translation;
  Location? location;
  dynamic hasWishList;

  Event(
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
      this.ticketTypes,
      this.duration,
      this.startTime,
      this.price,
      this.salePrice,
      this.isInstant,
      this.enableExtraPrice,
      this.extraPrice,
      this.reviewScore,
      this.icalImportUrl,
      this.status,
      this.defaultState,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.enableServiceFee,
      this.serviceFee,
      this.surrounding,
      this.endTime,
      this.durationUnit,
      this.authorId,
      this.reviewText,
      this.reviewCount,
      this.isInWishlist,
      this.bannerImgUrl,
      this.locationName,
      this.discount,
      this.translation,
      this.location,
      this.hasWishList});

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    imageId = json['image_id'];
    bannerImageId = json['banner_image_id'];
    locationId = json['location_id'];
    address = json['address'];
    mapLat = json['map_lat'] != null ? json['map_lat'].toString() : null;
    mapLng = json['map_lng'] != null ? json['map_lng'].toString() : null;
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
        faqs!.add(new Faqs.fromJson(v));
      });
    }
    if (json['ticket_types'] != null) {
      ticketTypes = <TicketTypes>[];
      json['ticket_types'].forEach((v) {
        ticketTypes!.add(new TicketTypes.fromJson(v));
      });
    }
    duration = json['duration'] != null ? json['duration'].toString() : null;
    startTime = json['start_time'];
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
    reviewScore = json['review_score'] ?? 0;
    icalImportUrl = json['ical_import_url'];
    status = json['status'];
    defaultState = json['default_state'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    enableServiceFee = json['enable_service_fee'];
    serviceFee = json['service_fee'];
    surrounding = json['surrounding'];
    endTime = json['end_time'];
    durationUnit =
        json['duration_unit'] != null ? json['duration_unit'].toString() : null;
    authorId = json['author_id'];
    reviewText = json['review_text'];
    reviewCount = json['review_count'];
    isInWishlist = json['is_in_wishlist'] ?? false;
    bannerImgUrl = json['banner_img_url'];
    locationName = json['location_name'];
    discount = json['discount'];
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
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    if (ticketTypes != null) {
      data['ticket_types'] = ticketTypes!.map((v) => v.toJson()).toList();
    }
    data['duration'] = duration;
    data['start_time'] = startTime;
    data['price'] = price;
    data['sale_price'] = salePrice;
    data['is_instant'] = isInstant;
    data['enable_extra_price'] = enableExtraPrice;
    if (extraPrice != null) {
      data['extra_price'] = extraPrice!.map((v) => v.toJson()).toList();
    }
    data['review_score'] = reviewScore;
    data['ical_import_url'] = icalImportUrl;
    data['status'] = status;
    data['default_state'] = defaultState;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['enable_service_fee'] = enableServiceFee;
    data['service_fee'] = serviceFee;
    data['surrounding'] = surrounding;
    data['end_time'] = endTime;
    data['duration_unit'] = durationUnit;
    data['author_id'] = authorId;
    data['review_text'] = reviewText;
    data['review_count'] = reviewCount;
    data['is_in_wishlist'] = isInWishlist;
    data['banner_img_url'] = bannerImgUrl;
    data['location_name'] = locationName;
    data['discount'] = discount;
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

class TicketTypes {
  String? code;
  String? name;
  String? nameJa;
  dynamic nameEgy;
  String? price;
  String? number;

  TicketTypes(
      {this.code,
      this.name,
      this.nameJa,
      this.nameEgy,
      this.price,
      this.number});

  TicketTypes.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    nameJa = json['name_ja'];
    nameEgy = json['name_egy'];
    price = json['price'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = code;
    data['name'] = name;
    data['name_ja'] = nameJa;
    data['name_egy'] = nameEgy;
    data['price'] = price;
    data['number'] = number;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  String? address;
  int? createUser;
  dynamic updateUser;
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
      this.faqs,
      this.address,
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
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(new Faqs.fromJson(v));
      });
    }
    address = json['address'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    surrounding = json['surrounding'];
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
    data['surrounding'] = surrounding;
    return data;
  }
}

class Location {
  int? id;
  String? name;
  dynamic content;
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
  dynamic bannerImageId;
  dynamic tripIdeas;
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
      this.tripIdeas,
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
    tripIdeas = json['trip_ideas'];
    gallery = json['gallery'];
    translation = json['translation'];
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
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['origin_id'] = originId;
    data['lang'] = lang;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['banner_image_id'] = bannerImageId;
    data['trip_ideas'] = tripIdeas;
    data['gallery'] = gallery;
    data['translation'] = translation;
    return data;
  }
}
