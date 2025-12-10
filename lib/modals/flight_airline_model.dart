// To parse this JSON data, do
//
//     final flightAirLineVendorModel = flightAirLineVendorModelFromJson(jsonString);

import 'dart:convert';

FlightAirLineVendorModel flightAirLineVendorModelFromJson(String str) => FlightAirLineVendorModel.fromJson(json.decode(str));

String flightAirLineVendorModelToJson(FlightAirLineVendorModel data) => json.encode(data.toJson());

class FlightAirLineVendorModel {
  String? message;
  List<FADatum>? data;

  FlightAirLineVendorModel({
    this.message,
    this.data,
  });

  factory FlightAirLineVendorModel.fromJson(Map<String, dynamic> json) => FlightAirLineVendorModel(
    message: json["message"],
    data: json["data"] == null ? [] : List<FADatum>.from(json["data"]!.map((x) => FADatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class FADatum {
  int? id;
  String? name;
  int? imageId;
  dynamic createdUser;
  DateTime? createdAt;
  dynamic updatedAt;
  dynamic authorId;
  dynamic deletedAt;

  FADatum({
    this.id,
    this.name,
    this.imageId,
    this.createdUser,
    this.createdAt,
    this.updatedAt,
    this.authorId,
    this.deletedAt,
  });

  factory FADatum.fromJson(Map<String, dynamic> json) => FADatum(
    id: json["id"],
    name: json["name"],
    imageId: json["image_id"],
    createdUser: json["created_user"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
    authorId: json["author_id"],
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image_id": imageId,
    "created_user": createdUser,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt,
    "author_id": authorId,
    "deleted_at": deletedAt,
  };
}
