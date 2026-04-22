// ignore_for_file: unnecessary_question_mark

class FlightList {
  List<Flight>? data;
  int? lastPage;
  int? total;

  FlightList({this.data, this.lastPage, this.total});

  FlightList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null && json['data']['flights'] != null) {
      data = <Flight>[];
      (json['data']['flights'] as List).forEach((v) {
        data!.add(Flight.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (data != null) {
      jsonData['data'] = {'flights': data!.map((v) => v.toJson()).toList()};
    }
    return jsonData;
  }
}

class Flight {
  String? id;
  String? totalPrice;
  String? currency;
  List<FlightDetail>? flightDetails;
  String? rawData; // Store raw JSON for price revalidation

  // New fields from updated API //pre also
  String? airlineName;
  String? airlineCode;
  String? airlineLogo;
  String? stopsLabel;
  String? badge;
  String? provider; // duffel or rawana_b2b_xml_agency
  String? cabinClass;
  String? flightNumber;

  // Top-level fields from API response
  String? origin;
  String? destination;
  String? departureAt;
  String? arrivalAt;
  String? duration;
  int? stops;
  bool? isNextDay;
  List<Segment>? segments;

  // Round-trip fields
  String? returnDepartureAt;
  String? returnArrivalAt;
  String? returnDuration;
  int? returnStops;

  Flight({
    this.id,
    this.totalPrice,
    this.currency,
    this.flightDetails,
    this.rawData,
    this.airlineName,
    this.airlineCode,
    this.airlineLogo,
    this.stopsLabel,
    this.badge,
    this.provider,
    this.cabinClass,
    this.flightNumber,
    this.origin,
    this.destination,
    this.departureAt,
    this.arrivalAt,
    this.duration,
    this.stops,
    this.isNextDay,
    this.segments,
    this.returnDepartureAt,
    this.returnArrivalAt,
    this.returnDuration,
    this.returnStops,
  });

  Flight.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    totalPrice =
        json['total_price']?.toString() ?? json['total_amount']?.toString();
    currency = json['currency']?.toString();
    airlineName = json['airline_name'];
    airlineCode = json['airline_code'];
    airlineLogo = json['airline_logo'];
    stopsLabel = json['stops_label'];
    badge = json['badge'];
    provider = json['provider'];
    cabinClass = json['cabin_class'];
    flightNumber = json['flight_number'];

    // Capture top-level fields
    origin = json['origin'];
    destination = json['destination'];
    departureAt = json['departure_at'];
    arrivalAt = json['arrival_at'];
    duration = json['duration'];
    stops = json['stops'];
    isNextDay = json['is_next_day'];

    // Capture round-trip fields
    returnDepartureAt = json['return_departure_at'];
    returnArrivalAt = json['return_arrival_at'];
    returnDuration = json['return_duration'];
    returnStops = json['return_stops'];

    if (json['flight_details'] != null) {
      flightDetails = <FlightDetail>[];
      (json['flight_details'] as List).forEach((v) {
        flightDetails!.add(FlightDetail.fromJson(v));
      });
    }

    if (json['segments'] != null) {
      segments = <Segment>[];
      (json['segments'] as List).forEach((v) {
        segments!.add(Segment.fromJson(v));
      });
    }

    // Store raw JSON for future use (price revalidation)
    rawData = json.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_price': totalPrice,
      'currency': currency,
      'airline_name': airlineName,
      'airline_code': airlineCode,
      'airline_logo': airlineLogo,
      'stops_label': stopsLabel,
      'badge': badge,
      'provider': provider,
      'cabin_class': cabinClass,
      'flight_number': flightNumber,
      'origin': origin,
      'destination': destination,
      'departure_at': departureAt,
      'arrival_at': arrivalAt,
      'duration': duration,
      'stops': stops,
      'is_next_day': isNextDay,
      'return_departure_at': returnDepartureAt,
      'return_arrival_at': returnArrivalAt,
      'return_duration': returnDuration,
      'return_stops': returnStops,
      if (flightDetails != null)
        'flight_details': flightDetails!.map((v) => v.toJson()).toList(),
      if (segments != null)
        'segments': segments!.map((v) => v.toJson()).toList(),
      'raw_data': rawData,
    };
  }

  /// Get departure flight detail (direction == "Departure")
  FlightDetail? getDepartureDetail() {
    return flightDetails?.firstWhere(
      (detail) => detail.direction?.toLowerCase() == 'departure',
      orElse: () => flightDetails!.first,
    );
  }

  /// Get return flight detail (direction == "Return")
  FlightDetail? getReturnDetail() {
    if (flightDetails == null || flightDetails!.isEmpty) return null;
    return flightDetails!.cast<FlightDetail?>().firstWhere(
          (detail) => detail?.direction?.toLowerCase() == 'return',
          orElse: () => null,
        );
  }

  /// Check if this is a round-trip flight
  bool get isRoundTrip => getReturnDetail() != null;

  /// Check if this is a one-way flight
  bool get isOneWay => !isRoundTrip;
}

class FlightDetail {
  String? direction; // "Departure" or "Return"
  String? airlineName;
  String? airlineLogo;
  String? airlineCode;
  String? flightNumber;
  String? depIata;
  String? depTime;
  String? depDate;
  String? arrIata;
  String? arrTime;
  String? arrDate;
  bool? isNextDay;
  String? duration;
  int? stops;
  List<FlightSegment>? segments;

  FlightDetail({
    this.direction,
    this.airlineName,
    this.airlineLogo,
    this.airlineCode,
    this.flightNumber,
    this.depIata,
    this.depTime,
    this.depDate,
    this.arrIata,
    this.arrTime,
    this.arrDate,
    this.isNextDay,
    this.duration,
    this.stops,
    this.segments,
  });

  FlightDetail.fromJson(Map<String, dynamic> json) {
    direction = json['direction']?.toString();
    airlineName = json['airline_name'];
    airlineLogo = json['airline_logo']?.toString();
    airlineCode = json['airline_code']?.toString();
    flightNumber = json['flight_number']?.toString();
    depIata = json['dep_iata']?.toString();
    depTime = json['dep_time']?.toString();
    depDate = json['dep_date']?.toString();
    arrIata = json['arr_iata']?.toString();
    arrTime = json['arr_time']?.toString();
    arrDate = json['arr_date']?.toString();
    isNextDay = json['is_next_day'];
    duration = json['duration']?.toString();
    stops = json['stops'];

    if (json['segments'] != null) {
      segments = <FlightSegment>[];
      (json['segments'] as List).forEach((v) {
        segments!.add(FlightSegment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'airline_name': airlineName,
      'airline_logo': airlineLogo,
      'airline_code': airlineCode,
      'flight_number': flightNumber,
      'dep_iata': depIata,
      'dep_time': depTime,
      'dep_date': depDate,
      'arr_iata': arrIata,
      'arr_time': arrTime,
      'arr_date': arrDate,
      'is_next_day': isNextDay,
      'duration': duration,
      'stops': stops,
      if (segments != null)
        'segments': segments!.map((v) => v.toJson()).toList(),
    };
  }
}

class FlightSegment {
  SegmentLocation? departure;
  SegmentLocation? arrival;
  String? carrierCode;
  String? number;
  String? aircraft;
  String? operating;
  String? duration;
  String? id;
  int? numberOfStops;
  bool? blacklistedInEU;

  FlightSegment({
    this.departure,
    this.arrival,
    this.carrierCode,
    this.number,
    this.aircraft,
    this.operating,
    this.duration,
    this.id,
    this.numberOfStops,
    this.blacklistedInEU,
  });

  FlightSegment.fromJson(Map<String, dynamic> json) {
    departure = json['departure'] != null
        ? SegmentLocation.fromJson(json['departure'])
        : null;
    arrival = json['arrival'] != null
        ? SegmentLocation.fromJson(json['arrival'])
        : null;
    carrierCode = json['carrierCode']?.toString();
    number = json['number']?.toString();
    aircraft = json['aircraft']?.toString();
    operating = json['operating']?.toString();
    duration = json['duration']?.toString();
    id = json['id']?.toString();
    numberOfStops = json['numberOfStops'];
    blacklistedInEU = json['blacklistedInEU'];
  }

  Map<String, dynamic> toJson() {
    return {
      if (departure != null) 'departure': departure!.toJson(),
      if (arrival != null) 'arrival': arrival!.toJson(),
      'carrierCode': carrierCode,
      'number': number,
      'aircraft': aircraft,
      'operating': operating,
      'duration': duration,
      'id': id,
      'numberOfStops': numberOfStops,
      'blacklistedInEU': blacklistedInEU,
    };
  }
}

/// Simple Segment model for top-level segments in Flight
class Segment {
  String? from;
  String? to;
  String? depDatetime;
  String? arrDatetime;
  String? flightNumber;
  String? airlineCode;
  String? airlineName;
  String? baggage;
  String? cabinClass;

  Segment({
    this.from,
    this.to,
    this.depDatetime,
    this.arrDatetime,
    this.flightNumber,
    this.airlineCode,
    this.airlineName,
    this.baggage,
    this.cabinClass,
  });

  Segment.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    depDatetime = json['dep_datetime'];
    arrDatetime = json['arr_datetime'];
    flightNumber = json['flight_number'];
    airlineCode = json['airline_code'];
    airlineName = json['airline_name'];
    baggage = json['baggage']?.toString();
    cabinClass = json['cabin_class'];
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'dep_datetime': depDatetime,
      'arr_datetime': arrDatetime,
      'flight_number': flightNumber,
      'airline_code': airlineCode,
      'airline_name': airlineName,
      'baggage': baggage,
      'cabin_class': cabinClass,
    };
  }
}

class SegmentLocation {
  String? iataCode;
  String? at; // ISO datetime string

  SegmentLocation({this.iataCode, this.at});

  SegmentLocation.fromJson(Map<String, dynamic> json) {
    iataCode = json['iataCode']?.toString();
    at = json['at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'iataCode': iataCode,
      'at': at,
    };
  }
}

// Old API classes (used by flight_details_model.dart for details endpoint)
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
