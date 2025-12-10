// To parse this JSON data, do
//
//     final hotelFacilitiesTypeModel = hotelFacilitiesTypeModelFromJson(jsonString);

import 'dart:convert';

HotelFacilitiesTypeModel hotelFacilitiesTypeModelFromJson(String str) => HotelFacilitiesTypeModel.fromJson(json.decode(str));

String hotelFacilitiesTypeModelToJson(HotelFacilitiesTypeModel data) => json.encode(data.toJson());

class HotelFacilitiesTypeModel {
  String? message;
  List<FTDatum>? data;

  HotelFacilitiesTypeModel({
    this.message,
    this.data,
  });

  factory HotelFacilitiesTypeModel.fromJson(Map<String, dynamic> json) => HotelFacilitiesTypeModel(
    message: json["message"],
    data: json["data"] == null ? [] : List<FTDatum>.from(json["data"]!.map((x) => FTDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class FTDatum {
  int? id;
  String? name;
  String? slug;

  FTDatum({
    this.id,
    this.name,
    this.slug,
  });

  factory FTDatum.fromJson(Map<String, dynamic> json) => FTDatum(
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
