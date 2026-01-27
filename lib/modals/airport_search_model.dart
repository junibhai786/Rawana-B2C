import 'dart:convert';

AirportSearchResponse airportSearchResponseFromJson(String str) =>
    AirportSearchResponse.fromJson(json.decode(str));

String airportSearchResponseToJson(AirportSearchResponse data) =>
    json.encode(data.toJson());

class AirportSearchResponse {
  List<AirportResult>? results;
  int? total;
  String? keyword;

  AirportSearchResponse({
    this.results,
    this.total,
    this.keyword,
  });

  factory AirportSearchResponse.fromJson(Map<String, dynamic> json) =>
      AirportSearchResponse(
        results: json["results"] == null
            ? []
            : List<AirportResult>.from(
                json["results"]!.map((x) => AirportResult.fromJson(x))),
        total: json["total"],
        keyword: json["keyword"],
      );

  Map<String, dynamic> toJson() => {
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "total": total,
        "keyword": keyword,
      };
}

class AirportResult {
  String? type;
  String? subType;
  String? name;
  String? detailedName;
  String? id;
  String? iataCode;
  Address? address;

  AirportResult({
    this.type,
    this.subType,
    this.name,
    this.detailedName,
    this.id,
    this.iataCode,
    this.address,
  });

  factory AirportResult.fromJson(Map<String, dynamic> json) => AirportResult(
        type: json["type"],
        subType: json["subType"],
        name: json["name"],
        detailedName: json["detailedName"],
        id: json["id"],
        iataCode: json["iataCode"],
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "subType": subType,
        "name": name,
        "detailedName": detailedName,
        "id": id,
        "iataCode": iataCode,
        "address": address?.toJson(),
      };
}

class Address {
  String? cityName;
  String? cityCode;
  String? countryName;
  String? countryCode;
  String? regionCode;

  Address({
    this.cityName,
    this.cityCode,
    this.countryName,
    this.countryCode,
    this.regionCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        cityName: json["cityName"],
        cityCode: json["cityCode"],
        countryName: json["countryName"],
        countryCode: json["countryCode"],
        regionCode: json["regionCode"],
      );

  Map<String, dynamic> toJson() => {
        "cityName": cityName,
        "cityCode": cityCode,
        "countryName": countryName,
        "countryCode": countryCode,
        "regionCode": regionCode,
      };
}
