// To parse this JSON data, do
//
//     final hotelCloneModel = hotelCloneModelFromJson(jsonString);

import 'dart:convert';

HotelCloneModel hotelCloneModelFromJson(String str) => HotelCloneModel.fromJson(json.decode(str));

String hotelCloneModelToJson(HotelCloneModel data) => json.encode(data.toJson());

class HotelCloneModel {
  String? message;

  HotelCloneModel({
    this.message,
  });

  factory HotelCloneModel.fromJson(Map<String, dynamic> json) => HotelCloneModel(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
