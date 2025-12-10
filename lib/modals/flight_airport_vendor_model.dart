// To parse this JSON data, do
//
//     final flightAirportVendorModel = flightAirportVendorModelFromJson(jsonString);

import 'dart:convert';

FlightAirportVendorModel flightAirportVendorModelFromJson(String str) => FlightAirportVendorModel.fromJson(json.decode(str));

String flightAirportVendorModelToJson(FlightAirportVendorModel data) => json.encode(data.toJson());

class FlightAirportVendorModel {
  String? message;
  List<FAADatum>? data;

  FlightAirportVendorModel({
    this.message,
    this.data,
  });

  factory FlightAirportVendorModel.fromJson(Map<String, dynamic> json) => FlightAirportVendorModel(
    message: json["message"],
    data: json["data"] == null ? [] : List<FAADatum>.from(json["data"]!.map((x) => FAADatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class FAADatum {
  int? id;
  String? name;
  String? code;
  String? address;
  dynamic country;
  int? locationId;
  String? description;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  dynamic createdUser;
  dynamic updateUser;
  Status? status;
  DateTime? createdAt;
  dynamic updatedAt;
  dynamic authorId;

  FAADatum({
    this.id,
    this.name,
    this.code,
    this.address,
    this.country,
    this.locationId,
    this.description,
    this.mapLat,
    this.mapLng,
    this.mapZoom,
    this.createdUser,
    this.updateUser,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.authorId,
  });

  factory FAADatum.fromJson(Map<String, dynamic> json) => FAADatum(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    address: json["address"],
    country: json["country"],
    locationId: json["location_id"],
    description: json["description"],
    mapLat: json["map_lat"],
    mapLng: json["map_lng"],
    mapZoom: json["map_zoom"],
    createdUser: json["created_user"],
    updateUser: json["update_user"],
    status: statusValues.map[json["status"]]!,
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
    authorId: json["author_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "address": address,
    "country": country,
    "location_id": locationId,
    "description": description,
    "map_lat": mapLat,
    "map_lng": mapLng,
    "map_zoom": mapZoom,
    "created_user": createdUser,
    "update_user": updateUser,
    "status": statusValues.reverse[status],
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt,
    "author_id": authorId,
  };
}

enum Status {
  PUBLISH
}

final statusValues = EnumValues({
  "publish": Status.PUBLISH
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
