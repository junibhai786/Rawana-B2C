// To parse this JSON data, do
//
//     final addTourLocationModel = addTourLocationModelFromJson(jsonString);

import 'dart:convert';

AddTourLocationModel addTourLocationModelFromJson(String str) =>
    AddTourLocationModel.fromJson(json.decode(str));

String addTourLocationModelToJson(AddTourLocationModel data) =>
    json.encode(data.toJson());

class AddTourLocationModel {
  List<Datum>? data;
  int? status;

  AddTourLocationModel({
    this.data,
    this.status,
  });

  factory AddTourLocationModel.fromJson(Map<String, dynamic> json) =>
      AddTourLocationModel(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
      };
}

class Datum {
  int? id;
  String? name;
  String? content;
  String? slug;
  int? imageId;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? status;
  int? lft;
  int? rgt;
  dynamic parentId;
  int? createUser;
  dynamic updateUser;
  dynamic deletedAt;
  dynamic originId;
  dynamic lang;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? bannerImageId;

  dynamic gallery;

  Datum({
    this.id,
    this.name,
    this.content,
    this.slug,
    this.imageId,
    this.mapLat,
    this.mapLng,
    this.mapZoom,
    this.status,
    this.lft,
    this.rgt,
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
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        content: json["content"],
        slug: json["slug"],
        imageId: json["image_id"],
        mapLat: json["map_lat"],
        mapLng: json["map_lng"],
        mapZoom: json["map_zoom"],
        status: json["status"],
        lft: json["_lft"],
        rgt: json["_rgt"],
        parentId: json["parent_id"],
        createUser: json["create_user"],
        updateUser: json["update_user"],
        deletedAt: json["deleted_at"],
        originId: json["origin_id"],
        lang: json["lang"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        bannerImageId: json["banner_image_id"],
        gallery: json["gallery"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "content": content,
        "slug": slug,
        "image_id": imageId,
        "map_lat": mapLat,
        "map_lng": mapLng,
        "map_zoom": mapZoom,
        "status": status,
        "_lft": lft,
        "_rgt": rgt,
        "parent_id": parentId,
        "create_user": createUser,
        "update_user": updateUser,
        "deleted_at": deletedAt,
        "origin_id": originId,
        "lang": lang,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "banner_image_id": bannerImageId,
        "gallery": gallery,
      };
}
