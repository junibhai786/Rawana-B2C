// To parse this JSON data, do
//
//     final hotelPropertyTypeModel = hotelPropertyTypeModelFromJson(jsonString);

import 'dart:convert';

HotelPropertyTypeModel hotelPropertyTypeModelFromJson(String str) => HotelPropertyTypeModel.fromJson(json.decode(str));

String hotelPropertyTypeModelToJson(HotelPropertyTypeModel data) => json.encode(data.toJson());

class HotelPropertyTypeModel {
  String? message;
  List<PTDatum>? data;

  HotelPropertyTypeModel({
    this.message,
    this.data,
  });

  factory HotelPropertyTypeModel.fromJson(Map<String, dynamic> json) => HotelPropertyTypeModel(
    message: json["message"],
    data: json["data"] == null ? [] : List<PTDatum>.from(json["data"]!.map((x) => PTDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}
class PTDatum {
  int? id;
  String? name;
  String? slug;
  bool? value;

  PTDatum({this.id, this.name, this.slug, this.value = false});

  PTDatum.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    value = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;

    return data;
  }
}
