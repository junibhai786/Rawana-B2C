class SpaceList {
  List<Space>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? startId;
  int? endId;
  int? status;
  String? text;

  SpaceList(
      {this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.perPage,
      this.startId,
      this.endId,
      this.status,
      this.text});

  SpaceList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Space>[];
      json['data'].forEach((v) {
        data!.add(new Space.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    startId = json['start_id'];
    endId = json['end_id'];
    status = json['status'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['per_page'] = this.perPage;
    data['start_id'] = this.startId;
    data['end_id'] = this.endId;
    data['status'] = this.status;
    data['text'] = this.text;
    return data;
  }
}

class Space {
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
  String? price;
  String? salePrice;
  int? isInstant;
  int? allowChildren;
  int? allowInfant;
  int? maxGuests;
  int? bed;
  int? bathroom;
  int? square;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  dynamic discountByDays;
  String? status;
  int? defaultState;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic reviewScore;
  dynamic icalImportUrl;
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
  int? discount;
  Translation? translation;
  Location? location;
  dynamic hasWishList;

  Space(
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
      this.price,
      this.salePrice,
      this.isInstant,
      this.allowChildren,
      this.allowInfant,
      this.maxGuests,
      this.bed,
      this.bathroom,
      this.square,
      this.enableExtraPrice,
      this.extraPrice,
      this.discountByDays,
      this.status,
      this.defaultState,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.reviewScore,
      this.icalImportUrl,
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
      this.discount,
      this.translation,
      this.location,
      this.hasWishList});

  Space.fromJson(Map<String, dynamic> json) {
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
        faqs!.add(new Faqs.fromJson(v));
      });
    }
    price = json['price'];
    salePrice = json['sale_price'];
    isInstant = json['is_instant'];
    allowChildren = json['allow_children'];
    allowInfant = json['allow_infant'];
    maxGuests = json['max_guests'];
    bed = json['bed'];
    bathroom = json['bathroom'];
    square = json['square'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(new ExtraPrice.fromJson(v));
      });
    }
    discountByDays = json['discount_by_days'];
    status = json['status'];
    defaultState = json['default_state'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reviewScore = (json['review_score'] ?? 0).toString();
    icalImportUrl = json['ical_import_url'];
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
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['content'] = this.content;
    data['image_id'] = this.imageId;
    data['banner_image_id'] = this.bannerImageId;
    data['location_id'] = this.locationId;
    data['address'] = this.address;
    data['map_lat'] = this.mapLat;
    data['map_lng'] = this.mapLng;
    data['map_zoom'] = this.mapZoom;
    data['is_featured'] = this.isFeatured;
    data['gallery'] = this.gallery;
    data['video'] = this.video;
    if (this.faqs != null) {
      data['faqs'] = this.faqs!.map((v) => v.toJson()).toList();
    }
    data['price'] = this.price;
    data['sale_price'] = this.salePrice;
    data['is_instant'] = this.isInstant;
    data['allow_children'] = this.allowChildren;
    data['allow_infant'] = this.allowInfant;
    data['max_guests'] = this.maxGuests;
    data['bed'] = this.bed;
    data['bathroom'] = this.bathroom;
    data['square'] = this.square;
    data['enable_extra_price'] = this.enableExtraPrice;
    if (this.extraPrice != null) {
      data['extra_price'] = this.extraPrice!.map((v) => v.toJson()).toList();
    }
    data['discount_by_days'] = this.discountByDays;
    data['status'] = this.status;
    data['default_state'] = this.defaultState;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['review_score'] = this.reviewScore;
    data['ical_import_url'] = this.icalImportUrl;
    data['enable_service_fee'] = this.enableServiceFee;
    data['service_fee'] = this.serviceFee;
    data['surrounding'] = this.surrounding;
    data['author_id'] = this.authorId;
    data['min_day_before_booking'] = this.minDayBeforeBooking;
    data['min_day_stays'] = this.minDayStays;
    data['review_text'] = this.reviewText;
    data['review_count'] = this.reviewCount;
    data['is_in_wishlist'] = this.isInWishlist;
    data['banner_img_url'] = this.bannerImgUrl;
    data['discount'] = this.discount;
    if (this.translation != null) {
      data['translation'] = this.translation!.toJson();
    }
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['has_wish_list'] = this.hasWishList;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['type'] = this.type;
    data['name_ja'] = this.nameJa;
    data['name_egy'] = this.nameEgy;
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
    data['id'] = this.id;
    data['origin_id'] = this.originId;
    data['locale'] = this.locale;
    data['title'] = this.title;
    data['content'] = this.content;
    if (this.faqs != null) {
      data['faqs'] = this.faqs!.map((v) => v.toJson()).toList();
    }
    data['address'] = this.address;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['surrounding'] = this.surrounding;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['content'] = this.content;
    data['slug'] = this.slug;
    data['image_id'] = this.imageId;
    data['map_lat'] = this.mapLat;
    data['map_lng'] = this.mapLng;
    data['map_zoom'] = this.mapZoom;
    data['status'] = this.status;
    data['_lft'] = this.iLft;
    data['_rgt'] = this.iRgt;
    data['parent_id'] = this.parentId;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['origin_id'] = this.originId;
    data['lang'] = this.lang;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['banner_image_id'] = this.bannerImageId;
    // data['trip_ideas'] = this.tripIdeas;
    data['gallery'] = this.gallery;
    data['translation'] = this.translation;
    return data;
  }
}
