// To parse this JSON data, do
//
//     final flightDetailVendorModel = flightDetailVendorModelFromJson(jsonString);

import 'dart:convert';

FlightDetailVendorModel flightDetailVendorModelFromJson(String str) => FlightDetailVendorModel.fromJson(json.decode(str));

String flightDetailVendorModelToJson(FlightDetailVendorModel data) => json.encode(data.toJson());

class FlightDetailVendorModel {
  String? message;
  List<FDDatum>? data;

  FlightDetailVendorModel({
    this.message,
    this.data,
  });

  factory FlightDetailVendorModel.fromJson(Map<String, dynamic> json) => FlightDetailVendorModel(
    message: json["message"],
    data: json["data"] == null ? [] : List<FDDatum>.from(json["data"]!.map((x) => FDDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class FDDatum {
  int? id;
  String? code;
  String? title;
  dynamic price;
  dynamic salePrice;
  dynamic discountPercent;
  String? image;
  dynamic content;
  dynamic location;
  dynamic isFeatured;
  Air? airportForm;
  Air? airportTo;
  Air? airline;
  DateTime? departureTime;
  DateTime? arrivalTime;
  String? duration;
  List<Term>? terms;
  DateTime? updatedAt;
  String? status;
  String? detailsUrl;

  FDDatum({
    this.id,
    this.code,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.image,
    this.content,
    this.location,
    this.isFeatured,
    this.airportForm,
    this.airportTo,
    this.airline,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.terms,
    this.updatedAt,
    this.status,
    this.detailsUrl,
  });

  factory FDDatum.fromJson(Map<String, dynamic> json) => FDDatum(
    id: json["id"],
    code: json["code"],
    title: json["title"],
    price: json["price"],
    salePrice: json["sale_price"],
    discountPercent: json["discount_percent"],
    image: json["image"],
    content: json["content"],
    location: json["location"],
    isFeatured: json["is_featured"],
    airportForm: json["airport_form"] == null ? null : Air.fromJson(json["airport_form"]),
    airportTo: json["airport_to"] == null ? null : Air.fromJson(json["airport_to"]),
    airline: json["airline"] == null ? null : Air.fromJson(json["airline"]),
    departureTime: json["departure_time"] == null ? null : DateTime.parse(json["departure_time"]),
    arrivalTime: json["arrival_time"] == null ? null : DateTime.parse(json["arrival_time"]),
    duration: json["duration"],
    terms: json["terms"] == null ? [] : List<Term>.from(json["terms"]!.map((x) => Term.fromJson(x))),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    status: json["status"],
    detailsUrl: json["details_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "title": title,
    "price": price,
    "sale_price": salePrice,
    "discount_percent": discountPercent,
    "image": image,
    "content": content,
    "location": location,
    "is_featured": isFeatured,
    "airport_form": airportForm?.toJson(),
    "airport_to": airportTo?.toJson(),
    "airline": airline?.toJson(),
    "departure_time": departureTime?.toIso8601String(),
    "arrival_time": arrivalTime?.toIso8601String(),
    "duration": duration,
    "terms": terms == null ? [] : List<dynamic>.from(terms!.map((x) => x.toJson())),
    "updated_at": updatedAt?.toIso8601String(),
    "status": status,
    "details_url": detailsUrl,
  };
}

class Air {
  int? id;
  String? name;

  Air({
    this.id,
    this.name,
  });

  factory Air.fromJson(Map<String, dynamic> json) => Air(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Term {
  Parent? parent;
  List<Child>? child;

  Term({
    this.parent,
    this.child,
  });

  factory Term.fromJson(Map<String, dynamic> json) => Term(
    parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
    child: json["child"] == null ? [] : List<Child>.from(json["child"]!.map((x) => Child.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "parent": parent?.toJson(),
    "child": child == null ? [] : List<dynamic>.from(child!.map((x) => x.toJson())),
  };
}

class Child {
  int? id;
  String? title;
  dynamic content;
  dynamic imageId;
  String? imageUrl;
  dynamic icon;
  int? attrId;
  String? slug;

  Child({
    this.id,
    this.title,
    this.content,
    this.imageId,
    this.imageUrl,
    this.icon,
    this.attrId,
    this.slug,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    imageId: json["image_id"],
    imageUrl: json["image_url"],
    icon: json["icon"],
    attrId: json["attr_id"],
    slug: json["slug"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "image_id": imageId,
    "image_url": imageUrl,
    "icon": icon,
    "attr_id": attrId,
    "slug": slug,
  };
}

class Parent {
  int? id;
  String? title;
  String? slug;
  String? service;
  dynamic displayType;
  dynamic hideInSingle;

  Parent({
    this.id,
    this.title,
    this.slug,
    this.service,
    this.displayType,
    this.hideInSingle,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    service: json["service"],
    displayType: json["display_type"],
    hideInSingle: json["hide_in_single"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "service": service,
    "display_type": displayType,
    "hide_in_single": hideInSingle,
  };
}
