// To parse this JSON data, do
//
//     final boatAmenitiesVendorModel = boatAmenitiesVendorModelFromJson(jsonString);

import 'dart:convert';

BoatAmenitiesVendorModel boatAmenitiesVendorModelFromJson(String str) =>
    BoatAmenitiesVendorModel.fromJson(json.decode(str));

String boatAmenitiesVendorModelToJson(BoatAmenitiesVendorModel data) =>
    json.encode(data.toJson());

class BoatAmenitiesVendorModel {
  String? message;
  List<BADatum>? data;

  BoatAmenitiesVendorModel({
    this.message,
    this.data,
  });

  factory BoatAmenitiesVendorModel.fromJson(Map<String, dynamic> json) =>
      BoatAmenitiesVendorModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<BADatum>.from(json["data"]!.map((x) => BADatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BADatum {
  int? id;
  String? name;
  String? slug;

  BADatum({
    this.id,
    this.name,
    this.slug,
  });

  factory BADatum.fromJson(Map<String, dynamic> json) => BADatum(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}
