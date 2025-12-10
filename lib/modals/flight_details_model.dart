// ignore_for_file: unnecessary_question_mark

import 'package:moonbnd/modals/flight_list_model.dart';

class FlightDetailModal {
  Data? data;
  int? status;
  String? message;

  FlightDetailModal({this.data, this.status, this.message});

  FlightDetailModal.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? code;
  String? reviewScore;
  String? departureTime;
  String? arrivalTime;
  String? duration;
  String? minPrice;
  AirportTo? airportTo;
  AirportTo? airportFrom;
  int? airlineId;
  String? status;
  dynamic createUser;
  dynamic? updateUser;
  String? createdAt;
  String? updatedAt;
  dynamic? deletedAt;
  dynamic? authorId;
  String? departureTimeHtml;
  String? departureDateHtml;
  String? arrivalTimeHtml;
  String? arrivalDateHtml;
  bool? canBook;
  List<FlightSeat>? flightSeat;
  Airline? airline;
  List<dynamic>? bookingPassengers;

  Data(
      {this.id,
      this.title,
      this.code,
      this.reviewScore,
      this.departureTime,
      this.arrivalTime,
      this.duration,
      this.minPrice,
      this.airportTo,
      this.airportFrom,
      this.airlineId,
      this.status,
      this.createUser,
      this.updateUser,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.authorId,
      this.departureTimeHtml,
      this.departureDateHtml,
      this.arrivalTimeHtml,
      this.arrivalDateHtml,
      this.canBook,
      this.flightSeat,
      this.airline,
      this.bookingPassengers});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    reviewScore = json['review_score'];
    departureTime = json['departure_time'];
    arrivalTime = json['arrival_time'];
    duration = json['duration'];
    minPrice = json['min_price'];
    airportTo = json['airport_to'] != null
        ? new AirportTo.fromJson(json['airport_to'])
        : null;
    airportFrom = json['airport_from'] != null
        ? new AirportTo.fromJson(json['airport_from'])
        : null;
    airlineId = json['airline_id'];
    status = json['status'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    authorId = json['author_id'];
    departureTimeHtml = json['departure_time_html'];
    departureDateHtml = json['departure_date_html'];
    arrivalTimeHtml = json['arrival_time_html'];
    arrivalDateHtml = json['arrival_date_html'];
    canBook = json['can_book'];
    if (json['flight_seat'] != null) {
      flightSeat = <FlightSeat>[];
      json['flight_seat'].forEach((v) {
        flightSeat!.add(new FlightSeat.fromJson(v));
      });
    }
    airline =
        json['airline'] != null ? new Airline.fromJson(json['airline']) : null;
    if (json['booking_passengers'] != null) {
      bookingPassengers = <dynamic>[];
      json['booking_passengers'].forEach((v) {
        bookingPassengers!.add(BookingPassenger.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['code'] = this.code;
    data['review_score'] = this.reviewScore;
    data['departure_time'] = this.departureTime;
    data['arrival_time'] = this.arrivalTime;
    data['duration'] = this.duration;
    data['min_price'] = this.minPrice;
    if (this.airportTo != null) {
      data['airport_to'] = this.airportTo!.toJson();
    }
    if (this.airportFrom != null) {
      data['airport_from'] = this.airportFrom!.toJson();
    }
    data['airline_id'] = this.airlineId;
    data['status'] = this.status;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['author_id'] = this.authorId;
    data['departure_time_html'] = this.departureTimeHtml;
    data['departure_date_html'] = this.departureDateHtml;
    data['arrival_time_html'] = this.arrivalTimeHtml;
    data['arrival_date_html'] = this.arrivalDateHtml;
    data['can_book'] = this.canBook;
    if (this.flightSeat != null) {
      data['flight_seat'] = this.flightSeat!.map((v) => v.toJson()).toList();
    }
    if (this.airline != null) {
      data['airline'] = this.airline!.toJson();
    }
    if (this.bookingPassengers != null) {
      data['booking_passengers'] =
          this.bookingPassengers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AirportTo {
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
  dynamic? createUser;
  dynamic? updateUser;
  String? status;
  String? createdAt;
  String? updatedAt;
  dynamic? authorId;

  AirportTo(
      {this.id,
      this.name,
      this.code,
      this.address,
      this.country,
      this.locationId,
      this.description,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.createUser,
      this.updateUser,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.authorId});

  AirportTo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    address = json['address'];
    country = json['country'];
    locationId = json['location_id'];
    description = json['description'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    authorId = json['author_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['address'] = this.address;
    data['country'] = this.country;
    data['location_id'] = this.locationId;
    data['description'] = this.description;
    data['map_lat'] = this.mapLat;
    data['map_lng'] = this.mapLng;
    data['map_zoom'] = this.mapZoom;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['author_id'] = this.authorId;
    return data;
  }
}

class FlightSeat {
  int? id;
  String? price;
  int? maxPassengers;
  int? flightId;
  SeatType? seatType;
  String? person;
  int? baggageCheckIn;
  int? baggageCabin;
  dynamic? createUser;
  dynamic? updateUser;
  String? createdAt;
  String? updatedAt;
  dynamic? deletedAt;
  dynamic? authorId;
  String? priceHtml;
  int? number;

  FlightSeat(
      {this.id,
      this.price,
      this.maxPassengers,
      this.flightId,
      this.seatType,
      this.person,
      this.baggageCheckIn,
      this.baggageCabin,
      this.createUser,
      this.updateUser,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.authorId,
      this.priceHtml,
      this.number});

  FlightSeat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = json['price'];
    maxPassengers = json['max_passengers'];
    flightId = json['flight_id'];
    seatType = json['seat_type'] != null
        ? new SeatType.fromJson(json['seat_type'])
        : null;
    person = json['person'];
    baggageCheckIn = json['baggage_check_in'];
    baggageCabin = json['baggage_cabin'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    authorId = json['author_id'];
    priceHtml = json['price_html'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['price'] = this.price;
    data['max_passengers'] = this.maxPassengers;
    data['flight_id'] = this.flightId;
    if (this.seatType != null) {
      data['seat_type'] = this.seatType!.toJson();
    }
    data['person'] = this.person;
    data['baggage_check_in'] = this.baggageCheckIn;
    data['baggage_cabin'] = this.baggageCabin;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['author_id'] = this.authorId;
    data['price_html'] = this.priceHtml;
    data['number'] = this.number;
    return data;
  }
}

class SeatType {
  int? id;
  String? code;
  String? name;
  dynamic? createUser;
  dynamic? updateUser;
  dynamic? deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic? authorId;

  SeatType(
      {this.id,
      this.code,
      this.name,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.authorId});

  SeatType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    authorId = json['author_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['author_id'] = this.authorId;
    return data;
  }
}

class Airline {
  int? id;
  String? name;
  int? imageId;
  dynamic? createUser;
  dynamic? updateUser;
  dynamic? deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic? authorId;
  String? imageUrl;

  Airline(
      {this.id,
      this.name,
      this.imageId,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.authorId,
      this.imageUrl});

  Airline.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageId = json['image_id'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    authorId = json['author_id'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image_id'] = this.imageId;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['author_id'] = this.authorId;
    data['image_url'] = this.imageUrl;
    return data;
  }
}
