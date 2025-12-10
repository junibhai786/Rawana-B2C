// ignore_for_file: unnecessary_question_mark

class FlightList {
  List<Flight>? data;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? startId;
  int? endId;
  int? status;

  FlightList(
      {this.data,
      this.total,
      this.currentPage,
      this.lastPage,
      this.perPage,
      this.startId,
      this.endId,
      this.status});

  FlightList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Flight>[];
      json['data'].forEach((v) {
        data!.add(Flight.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    startId = json['start_id'];
    endId = json['end_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['start_id'] = startId;
    data['end_id'] = endId;
    data['status'] = status;
    return data;
  }
}

class Flight {
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
  String? airlineImageUrl;
  bool? canBook;
  Airline? airline;
  List<BookingPassenger>? bookingPassengers;
  List<FlightSeat>? flightSeat;

  Flight(
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
      this.airlineImageUrl,
      this.canBook,
      this.airline,
      this.bookingPassengers,
      this.flightSeat});

  Flight.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    reviewScore = json['review_score'];
    departureTime = json['departure_time'];
    arrivalTime = json['arrival_time'];
    duration = json['duration'];
    minPrice = json['min_price'];
    airportTo = json['airport_to'] != null && json['airport_to'] is Map
        ? AirportTo.fromJson(json['airport_to'])
        : null;
    airportFrom = json['airport_from'] != null && json['airport_from'] is Map
        ? AirportTo.fromJson(json['airport_from'])
        : null;
    airlineId = json['airline_id'];
    status = json['status'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    authorId = json['author_id'];
    airlineImageUrl = json['airline_image_url'];
    canBook = json['can_book'];
    airline =
        json['airline'] != null ? Airline.fromJson(json['airline']) : null;
    if (json['booking_passengers'] != null) {
      bookingPassengers = <BookingPassenger>[];
      json['booking_passengers'].forEach((v) {
        bookingPassengers!.add(BookingPassenger.fromJson(v));
      });
    }
    if (json['flight_seat'] != null) {
      flightSeat = <FlightSeat>[];
      json['flight_seat'].forEach((v) {
        flightSeat!.add(FlightSeat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['code'] = code;
    data['review_score'] = reviewScore;
    data['departure_time'] = departureTime;
    data['arrival_time'] = arrivalTime;
    data['duration'] = duration;
    data['min_price'] = minPrice;
    if (airportTo != null) {
      data['airport_to'] = airportTo!.toJson();
    }
    if (airportFrom != null) {
      data['airport_from'] = airportFrom!.toJson();
    }
    data['airline_id'] = airlineId;
    data['status'] = status;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['author_id'] = authorId;
    data['airline_image_url'] = airlineImageUrl;
    data['can_book'] = canBook;
    if (airline != null) {
      data['airline'] = airline!.toJson();
    }
    if (bookingPassengers != null) {
      data['booking_passengers'] =
          bookingPassengers!.map((v) => v.toJson()).toList();
    }
    if (flightSeat != null) {
      data['flight_seat'] = flightSeat!.map((v) => v.toJson()).toList();
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
  dynamic createUser;
  dynamic updateUser;
  String? status;
  String? createdAt;
  String? updatedAt;
  dynamic authorId;

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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['address'] = address;
    data['country'] = country;
    data['location_id'] = locationId;
    data['description'] = description;
    data['map_lat'] = mapLat;
    data['map_lng'] = mapLng;
    data['map_zoom'] = mapZoom;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['author_id'] = authorId;
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

  Airline(
      {this.id,
      this.name,
      this.imageId,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.authorId});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['image_id'] = imageId;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['author_id'] = authorId;
    return data;
  }
}

class FlightSeat {
  int? id;
  String? price;
  int? maxPassengers;
  int? flightId;
  String? seatType;
  String? person;
  int? baggageCheckIn;
  int? baggageCabin;
  dynamic? createUser;
  dynamic? updateUser;
  String? createdAt;
  String? updatedAt;
  dynamic? deletedAt;
  dynamic? authorId;

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
      this.authorId});

  FlightSeat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = json['price'];
    maxPassengers = json['max_passengers'];
    flightId = json['flight_id'];
    seatType = json['seat_type'];
    person = json['person'];
    baggageCheckIn = json['baggage_check_in'];
    baggageCabin = json['baggage_cabin'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    authorId = json['author_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['price'] = price;
    data['max_passengers'] = maxPassengers;
    data['flight_id'] = flightId;
    data['seat_type'] = seatType;
    data['person'] = person;
    data['baggage_check_in'] = baggageCheckIn;
    data['baggage_cabin'] = baggageCabin;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['author_id'] = authorId;
    return data;
  }
}

class BookingPassenger {
  String? name;
  int? age;

  BookingPassenger({this.name, this.age});

  factory BookingPassenger.fromJson(Map<String, dynamic> json) {
    return BookingPassenger(
      name: json['name'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}
