class TourList {
  List<Tour>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? startId;
  int? endId;
  int? status;

  TourList(
      {this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.perPage,
      this.startId,
      this.endId,
      this.status});

  TourList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Tour>[];
      json['data'].forEach((v) {
        data!.add(Tour.fromJson(v));
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
    final Map<String, dynamic> data = <String, dynamic>{};
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

class Tour {
  int? id;
  String? title;
  String? slug;
  String? content;
  int? imageId;
  int? bannerImageId;
  String? shortDesc;
  int? categoryId;
  int? locationId;
  String? address;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  int? isFeatured;
  List<String>? gallery;
  String? video;
  String? price;
  String? salePrice;
  int? duration;
  int? minPeople;
  int? maxPeople;
  List<Faqs>? faqs;
  String? status;
  dynamic publishDate;
  int? createUser;
  dynamic updateUser;
  dynamic deletedAt;
  dynamic originId;
  dynamic lang;
  String? createdAt;
  String? updatedAt;
  int? defaultState;
  int? enableFixedDate;
  dynamic startDate;
  dynamic endDate;
  dynamic lastBookingDate;
  List<Include>? include;
  List<Exclude>? exclude;
  List<Itinerary>? itinerary;
  dynamic reviewScore;
  dynamic icalImportUrl;
  dynamic enableServiceFee;
  dynamic serviceFee;
  dynamic surrounding;
  int? authorId;
  dynamic bookingType;
  dynamic limitType;
  dynamic capacityType;
  dynamic capacity;
  dynamic passExprireType;
  dynamic passExprireAt;
  dynamic passValidFor;
  dynamic minDayBeforeBooking;
  String? reviewText;
  int? reviewCount;
  bool? isInWishlist;
  String? bannerImgUrl;
  String? categoryName;
  String? locationName;
  int? discount;
  dynamic translation;
  Location? location;
  CategoryTour? categoryTour;
  dynamic hasWishList;

  Tour(
      {this.id,
      this.title,
      this.slug,
      this.content,
      this.imageId,
      this.bannerImageId,
      this.shortDesc,
      this.categoryId,
      this.locationId,
      this.address,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.isFeatured,
      this.gallery,
      this.video,
      this.price,
      this.salePrice,
      this.duration,
      this.minPeople,
      this.maxPeople,
      this.faqs,
      this.status,
      this.publishDate,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.originId,
      this.lang,
      this.createdAt,
      this.updatedAt,
      this.defaultState,
      this.enableFixedDate,
      this.startDate,
      this.endDate,
      this.lastBookingDate,
      this.include,
      this.exclude,
      this.itinerary,
      this.reviewScore,
      this.icalImportUrl,
      this.enableServiceFee,
      this.serviceFee,
      this.surrounding,
      this.authorId,
      this.bookingType,
      this.limitType,
      this.capacityType,
      this.capacity,
      this.passExprireType,
      this.passExprireAt,
      this.passValidFor,
      this.minDayBeforeBooking,
      this.reviewText,
      this.reviewCount,
      this.isInWishlist,
      this.bannerImgUrl,
      this.categoryName,
      this.locationName,
      this.discount,
      this.translation,
      this.location,
      this.categoryTour,
      this.hasWishList});

  Tour.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    imageId = json['image_id'];
    bannerImageId = json['banner_image_id'];
    shortDesc = json['short_desc'];
    categoryId = json['category_id'];
    locationId = json['location_id'];
    address = json['address'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    isFeatured = json['is_featured'];
    gallery = json['gallery'] != null ? json['gallery'].cast<String>() : [];
    video = json['video'];
    price = json['price'];
    salePrice = json['sale_price'];
    duration = json['duration'];
    minPeople = json['min_people'];
    maxPeople = json['max_people'];
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faqs.fromJson(v));
      });
    }
    status = json['status'];
    publishDate = json['publish_date'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    originId = json['origin_id'];
    lang = json['lang'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    defaultState = json['default_state'];
    enableFixedDate = json['enable_fixed_date'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    lastBookingDate = json['last_booking_date'];
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
    reviewScore = json['review_score'];
    icalImportUrl = json['ical_import_url'];
    enableServiceFee = json['enable_service_fee'];
    serviceFee = json['service_fee'];
    surrounding = json['surrounding'];
    authorId = json['author_id'];
    bookingType = json['booking_type'];
    limitType = json['limit_type'];
    capacityType = json['capacity_type'];
    capacity = json['capacity'];
    passExprireType = json['pass_exprire_type'];
    passExprireAt = json['pass_exprire_at'];
    passValidFor = json['pass_valid_for'];
    minDayBeforeBooking = json['min_day_before_booking'];
    reviewText = json['review_text'];
    reviewCount = json['review_count'];
    isInWishlist = json['is_in_wishlist'] ?? false;
    bannerImgUrl = json['banner_img_url'];
    categoryName = json['category_name'];
    locationName = json['location_name'];
    discount = json['discount'];
    translation = json['translation'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    categoryTour = json['category_tour'] != null
        ? CategoryTour.fromJson(json['category_tour'])
        : null;
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
    data['short_desc'] = shortDesc;
    data['category_id'] = categoryId;
    data['location_id'] = locationId;
    data['address'] = address;
    data['map_lat'] = mapLat;
    data['map_lng'] = mapLng;
    data['map_zoom'] = mapZoom;
    data['is_featured'] = isFeatured;
    data['gallery'] = gallery;
    data['video'] = video;
    data['price'] = price;
    data['sale_price'] = salePrice;
    data['duration'] = duration;
    data['min_people'] = minPeople;
    data['max_people'] = maxPeople;
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['publish_date'] = publishDate;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['origin_id'] = originId;
    data['lang'] = lang;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['default_state'] = defaultState;
    data['enable_fixed_date'] = enableFixedDate;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['last_booking_date'] = lastBookingDate;
    if (include != null) {
      data['include'] = include!.map((v) => v.toJson()).toList();
    }
    if (exclude != null) {
      data['exclude'] = exclude!.map((v) => v.toJson()).toList();
    }
    if (itinerary != null) {
      data['itinerary'] = itinerary!.map((v) => v.toJson()).toList();
    }
    data['review_score'] = reviewScore;
    data['ical_import_url'] = icalImportUrl;
    data['enable_service_fee'] = enableServiceFee;
    data['service_fee'] = serviceFee;
    data['surrounding'] = surrounding;
    data['author_id'] = authorId;
    data['booking_type'] = bookingType;
    data['limit_type'] = limitType;
    data['capacity_type'] = capacityType;
    data['capacity'] = capacity;
    data['pass_exprire_type'] = passExprireType;
    data['pass_exprire_at'] = passExprireAt;
    data['pass_valid_for'] = passValidFor;
    data['min_day_before_booking'] = minDayBeforeBooking;
    data['review_text'] = reviewText;
    data['review_count'] = reviewCount;
    data['is_in_wishlist'] = isInWishlist;
    data['banner_img_url'] = bannerImgUrl;
    data['category_name'] = categoryName;
    data['location_name'] = locationName;
    data['discount'] = discount;
    data['translation'] = translation;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (categoryTour != null) {
      data['category_tour'] = categoryTour!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
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

  Itinerary({this.imageId, this.title, this.desc, this.content});

  Itinerary.fromJson(Map<String, dynamic> json) {
    imageId = json['image_id'];
    title = json['title'];
    desc = json['desc'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['image_id'] = imageId;
    data['title'] = title;
    data['desc'] = desc;
    data['content'] = content;
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

    data['gallery'] = gallery;
    data['translation'] = translation;
    return data;
  }
}

class CategoryTour {
  int? id;
  String? name;
  String? content;
  String? slug;
  String? status;
  int? iLft;
  int? iRgt;
  dynamic parentId;
  dynamic createUser;
  dynamic updateUser;
  dynamic deletedAt;
  dynamic originId;
  dynamic lang;
  String? createdAt;
  String? updatedAt;
  dynamic translation;

  CategoryTour(
      {this.id,
      this.name,
      this.content,
      this.slug,
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
      this.translation});

  CategoryTour.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    content = json['content'];
    slug = json['slug'];
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
    translation = json['translation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['content'] = content;
    data['slug'] = slug;
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
    data['translation'] = translation;
    return data;
  }
}
