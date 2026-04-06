// ignore_for_file: unnecessary_question_mark

/// Top-level response from new flight search API
class FlightSearchResponse {
  bool? success;
  int? count;
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  List<FlightSearchItem>? data;
  String? message;

  FlightSearchResponse({
    this.success,
    this.count,
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.data,
    this.message,
  });

  FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    message = json['message'];
    // Pagination fields from API response
    total = json['total'] is int
        ? json['total']
        : int.tryParse(json['total']?.toString() ?? '');
    perPage = json['per_page'] is int
        ? json['per_page']
        : int.tryParse(json['per_page']?.toString() ?? '');
    currentPage = json['current_page'] is int
        ? json['current_page']
        : int.tryParse(json['current_page']?.toString() ?? '');
    lastPage = json['last_page'] is int
        ? json['last_page']
        : int.tryParse(json['last_page']?.toString() ?? '');
    if (json['data'] != null) {
      data = <FlightSearchItem>[];
      (json['data'] as List).forEach((v) {
        data!.add(FlightSearchItem.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {};
    res['success'] = success;
    res['count'] = count;
    res['total'] = total;
    res['per_page'] = perPage;
    res['current_page'] = currentPage;
    res['last_page'] = lastPage;
    res['message'] = message;
    if (data != null) {
      res['data'] = data!.map((v) => v.toJson()).toList();
    }
    return res;
  }
}

/// Individual flight item in the response
class FlightSearchItem {
  String? id;
  String? provider;
  String? origin;
  String? destination;
  String? departureAt;
  String? arrivalAt;
  String? duration;
  int? stops;
  String? stopsLabel;
  bool? isNextDay;
  String? airlineName;
  String? airlineCode;
  String? airlineLogo;
  String? flightNumber;
  dynamic totalAmount;
  String? currency;
  String? cabinClass;
  List<FlightSegmentNew>? segments;
  List<FlightDetailsNew>? flightDetails;

  // Return flight fields (for round trip)
  String? returnDepartureAt;
  String? returnArrivalAt;
  String? returnDuration;
  int? returnStops;
  String? returnStopsLabel;

  String? badge;

  FlightSearchItem({
    this.id,
    this.provider,
    this.origin,
    this.destination,
    this.departureAt,
    this.arrivalAt,
    this.duration,
    this.stops,
    this.stopsLabel,
    this.isNextDay,
    this.airlineName,
    this.airlineCode,
    this.airlineLogo,
    this.flightNumber,
    this.totalAmount,
    this.currency,
    this.cabinClass,
    this.segments,
    this.flightDetails,
    this.returnDepartureAt,
    this.returnArrivalAt,
    this.returnDuration,
    this.returnStops,
    this.returnStopsLabel,
    this.badge,
  });

  FlightSearchItem.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    provider = json['provider'];
    origin = json['origin'];
    destination = json['destination'];
    departureAt = json['departure_at'];
    arrivalAt = json['arrival_at'];
    duration = json['duration'];
    stops = json['stops'];
    stopsLabel = json['stops_label'];
    isNextDay = json['is_next_day'];
    airlineName = json['airline_name'];
    airlineCode = json['airline_code'];
    airlineLogo = json['airline_logo'];
    flightNumber = json['flight_number'];
    totalAmount = json['total_amount'];
    currency = json['currency'];
    cabinClass = json['cabin_class'];
    returnDepartureAt = json['return_departure_at'];
    returnArrivalAt = json['return_arrival_at'];
    returnDuration = json['return_duration'];
    returnStops = json['return_stops'];
    returnStopsLabel = json['return_stops_label'];
    badge = json['badge'];

    if (json['segments'] != null) {
      segments = <FlightSegmentNew>[];
      (json['segments'] as List).forEach((v) {
        segments!.add(FlightSegmentNew.fromJson(v as Map<String, dynamic>));
      });
    }

    if (json['flight_details'] != null) {
      flightDetails = <FlightDetailsNew>[];
      (json['flight_details'] as List).forEach((v) {
        flightDetails!
            .add(FlightDetailsNew.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'origin': origin,
      'destination': destination,
      'departure_at': departureAt,
      'arrival_at': arrivalAt,
      'duration': duration,
      'stops': stops,
      'stops_label': stopsLabel,
      'is_next_day': isNextDay,
      'airline_name': airlineName,
      'airline_code': airlineCode,
      'airline_logo': airlineLogo,
      'flight_number': flightNumber,
      'total_amount': totalAmount,
      'currency': currency,
      'cabin_class': cabinClass,
      'return_departure_at': returnDepartureAt,
      'return_arrival_at': returnArrivalAt,
      'return_duration': returnDuration,
      'return_stops': returnStops,
      'return_stops_label': returnStopsLabel,
      'badge': badge,
      if (segments != null)
        'segments': segments!.map((v) => v.toJson()).toList(),
      if (flightDetails != null)
        'flight_details': flightDetails!.map((v) => v.toJson()).toList(),
    };
  }
}

/// Flight segment details
class FlightSegmentNew {
  String? id;
  String? segmentNumber;
  String? airlineCode;
  String? flightNumber;
  String? from;
  String? to;
  String? depDatetime;
  String? arrDatetime;
  String? baggage;
  String? cabinClass;
  String? airlineName;

  FlightSegmentNew({
    this.id,
    this.segmentNumber,
    this.airlineCode,
    this.flightNumber,
    this.from,
    this.to,
    this.depDatetime,
    this.arrDatetime,
    this.baggage,
    this.cabinClass,
    this.airlineName,
  });

  FlightSegmentNew.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    segmentNumber = json['segment_number'];
    airlineCode = json['airline_code'];
    flightNumber = json['flight_number'];
    from = json['from'];
    to = json['to'];
    depDatetime = json['dep_datetime'];
    arrDatetime = json['arr_datetime'];
    baggage = json['baggage']?.toString();
    cabinClass = json['cabin_class'];
    airlineName = json['airline_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'segment_number': segmentNumber,
      'airline_code': airlineCode,
      'flight_number': flightNumber,
      'from': from,
      'to': to,
      'dep_datetime': depDatetime,
      'arr_datetime': arrDatetime,
      'baggage': baggage,
      'cabin_class': cabinClass,
      'airline_name': airlineName,
    };
  }
}

/// Flight details node (departure or return information)
class FlightDetailsNew {
  String? direction; // "departure" or "return"
  String? airlineCode;
  String? flightNumber;
  String? airlineName;
  String? airlineLogo;
  String? origin;
  String? destination;
  String? departureAt;
  String? arrivalAt;

  // Formatted fields from API (pre-formatted times and dates)
  String? depIata; // e.g., "OCA"
  String? depTime; // e.g., "13:56"
  String? depDate; // e.g., "19 Mar, 2026"
  String? arrIata; // e.g., "FWL"
  String? arrTime; // e.g., "19:26"
  String? arrDate; // e.g., "19 Mar, 2026"

  String? duration;
  int? stops;
  String? stopsLabel;
  bool? isNextDay;
  List<FlightSegmentNew>? segments;

  FlightDetailsNew({
    this.direction,
    this.airlineCode,
    this.flightNumber,
    this.airlineName,
    this.airlineLogo,
    this.origin,
    this.destination,
    this.departureAt,
    this.arrivalAt,
    this.depIata,
    this.depTime,
    this.depDate,
    this.arrIata,
    this.arrTime,
    this.arrDate,
    this.duration,
    this.stops,
    this.stopsLabel,
    this.isNextDay,
    this.segments,
  });

  FlightDetailsNew.fromJson(Map<String, dynamic> json) {
    direction = json['direction'];
    airlineCode = json['airline_code'];
    flightNumber = json['flight_number'];
    airlineName = json['airline_name'];
    airlineLogo = json['airline_logo'];
    origin = json['origin'];
    destination = json['destination'];
    departureAt = json['departure_at'];
    arrivalAt = json['arrival_at'];

    // Capture pre-formatted fields from API
    depIata = json['dep_iata'];
    depTime = json['dep_time'];
    depDate = json['dep_date'];
    arrIata = json['arr_iata'];
    arrTime = json['arr_time'];
    arrDate = json['arr_date'];

    duration = json['duration'];
    stops = json['stops'];
    stopsLabel = json['stops_label'];
    isNextDay = json['is_next_day'];

    if (json['segments'] != null) {
      segments = <FlightSegmentNew>[];
      (json['segments'] as List).forEach((v) {
        segments!.add(FlightSegmentNew.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'airline_code': airlineCode,
      'flight_number': flightNumber,
      'airline_name': airlineName,
      'airline_logo': airlineLogo,
      'origin': origin,
      'destination': destination,
      'departure_at': departureAt,
      'arrival_at': arrivalAt,
      'dep_iata': depIata,
      'dep_time': depTime,
      'dep_date': depDate,
      'arr_iata': arrIata,
      'arr_time': arrTime,
      'arr_date': arrDate,
      'duration': duration,
      'stops': stops,
      'stops_label': stopsLabel,
      'is_next_day': isNextDay,
      if (segments != null)
        'segments': segments!.map((v) => v.toJson()).toList(),
    };
  }
}
