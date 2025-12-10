// To parse this JSON data, do
//
//     final tourTravelModel = tourTravelModelFromJson(jsonString);

import 'dart:convert';

TourTravelModel tourTravelModelFromJson(String str) =>
    TourTravelModel.fromJson(json.decode(str));

String tourTravelModelToJson(TourTravelModel data) =>
    json.encode(data.toJson());

class TourTravelModel {
  String? message;
  List<TourTravelDatum>? data;

  TourTravelModel({
    this.message,
    this.data,
  });

  factory TourTravelModel.fromJson(Map<String, dynamic> json) =>
      TourTravelModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<TourTravelDatum>.from(json["data"]!.map((x) => TourTravelDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TourTravelDatum {
  int? id;
  String? name;
  String? slug;
  bool? value;

  TourTravelDatum({this.id, this.name, this.slug, this.value = false});

  TourTravelDatum.fromJson(Map<String, dynamic> json) {
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
