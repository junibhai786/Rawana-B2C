// To parse this JSON data, do
//
//     final addHotelModel = addHotelModelFromJson(jsonString);

import 'dart:convert';

AddHotelModel addHotelModelFromJson(String str) => AddHotelModel.fromJson(json.decode(str));

String addHotelModelToJson(AddHotelModel data) => json.encode(data.toJson());

class AddHotelModel {
  String? message;
  Data? data;

  AddHotelModel({
    this.message,
    this.data,
  });

  factory AddHotelModel.fromJson(Map<String, dynamic> json) => AddHotelModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? title;
  String? content;
  String? status;
  dynamic video;
  String? starRate;
  dynamic relatedIds;
  String? locationId;
  String? price;
  dynamic address;
  dynamic mapLat;
  dynamic mapLng;
  String? mapZoom;
  String? checkInTime;
  dynamic checkOutTime;
  dynamic minDayBeforeBooking;
  dynamic minDayStays;
  String? salePrice;
  int? authorId;
  int? createUser;
  String? slug;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;
  List<Policy>? policy;
  int? updateUser;
  int? imageId;
  int? bannerImageId;
  String? gallery;
  List<ExtraPrice>? extraPrice;
  List<List<Surrounding>>? surrounding;

  Data({
    this.title,
    this.content,
    this.status,
    this.video,
    this.starRate,
    this.relatedIds,
    this.locationId,
    this.price,
    this.address,
    this.mapLat,
    this.mapLng,
    this.mapZoom,
    this.checkInTime,
    this.checkOutTime,
    this.minDayBeforeBooking,
    this.minDayStays,
    this.salePrice,
    this.authorId,
    this.createUser,
    this.slug,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.policy,
    this.updateUser,
    this.imageId,
    this.bannerImageId,
    this.gallery,
    this.extraPrice,
    this.surrounding,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    title: json["title"],
    content: json["content"],
    status: json["status"],
    video: json["video"],
    starRate: json["star_rate"],
    relatedIds: json["related_ids"],
    locationId: json["location_id"],
    price: json["price"],
    address: json["address"],
    mapLat: json["map_lat"],
    mapLng: json["map_lng"],
    mapZoom: json["map_zoom"],
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    minDayBeforeBooking: json["min_day_before_booking"],
    minDayStays: json["min_day_stays"],
    salePrice: json["sale_price"],
    authorId: json["author_id"],
    createUser: json["create_user"],
    slug: json["slug"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
    policy: json["policy"] == null ? [] : List<Policy>.from(json["policy"]!.map((x) => Policy.fromJson(x))),
    updateUser: json["update_user"],
    imageId: json["image_id"],
    bannerImageId: json["banner_image_id"],
    gallery: json["gallery"],
    extraPrice: json["extra_price"] == null ? [] : List<ExtraPrice>.from(json["extra_price"]!.map((x) => ExtraPrice.fromJson(x))),
    surrounding: json["surrounding"] == null ? [] : List<List<Surrounding>>.from(json["surrounding"]!.map((x) => List<Surrounding>.from(x.map((x) => Surrounding.fromJson(x))))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
    "status": status,
    "video": video,
    "star_rate": starRate,
    "related_ids": relatedIds,
    "location_id": locationId,
    "price": price,
    "address": address,
    "map_lat": mapLat,
    "map_lng": mapLng,
    "map_zoom": mapZoom,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "min_day_before_booking": minDayBeforeBooking,
    "min_day_stays": minDayStays,
    "sale_price": salePrice,
    "author_id": authorId,
    "create_user": createUser,
    "slug": slug,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
    "policy": policy == null ? [] : List<dynamic>.from(policy!.map((x) => x.toJson())),
    "update_user": updateUser,
    "image_id": imageId,
    "banner_image_id": bannerImageId,
    "gallery": gallery,
    "extra_price": extraPrice == null ? [] : List<dynamic>.from(extraPrice!.map((x) => x.toJson())),
    "surrounding": surrounding == null ? [] : List<dynamic>.from(surrounding!.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
  };
}

class ExtraPrice {
  String? name;
  dynamic nameJa;
  dynamic nameEgy;
  String? price;
  String? type;

  ExtraPrice({
    this.name,
    this.nameJa,
    this.nameEgy,
    this.price,
    this.type,
  });

  factory ExtraPrice.fromJson(Map<String, dynamic> json) => ExtraPrice(
    name: json["name"],
    nameJa: json["name_ja"],
    nameEgy: json["name_egy"],
    price: json["price"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "name_ja": nameJa,
    "name_egy": nameEgy,
    "price": price,
    "type": type,
  };
}

class Policy {
  String? title;
  String? content;

  Policy({
    this.title,
    this.content,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    title: json["title"],
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
  };
}

class Surrounding {
  String? name;
  String? content;
  String? value;
  String? type;

  Surrounding({
    this.name,
    this.content,
    this.value,
    this.type,
  });

  factory Surrounding.fromJson(Map<String, dynamic> json) => Surrounding(
    name: json["name"],
    content: json["content"],
    value: json["value"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "content": content,
    "value": value,
    "type": type,
  };
}
