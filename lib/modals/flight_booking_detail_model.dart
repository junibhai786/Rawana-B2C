class FlightBookingResponse {
  Data? data;
  int? status;

  FlightBookingResponse({
    this.data,
    this.status,
  });

  factory FlightBookingResponse.fromJson(Map<String, dynamic> json) {
    return FlightBookingResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      status: json['status'],
    );
  }
}

class Data {
  Booking? booking;

  Data({
    this.booking,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
    );
  }
}

class Booking {
  int? id;
  String? code;
  dynamic vendorId;
  int? customerId;
  dynamic paymentId;
  dynamic gateway;
  int? objectId;
  String? objectModel;
  DateTime? startDate;
  DateTime? endDate;
  String? total;
  int? totalGuests;
  dynamic currency;
  String? status;
  dynamic deposit;
  dynamic depositType;
  int? commission;
  String? commissionType;
  dynamic email;
  dynamic firstName;
  dynamic lastName;
  dynamic phone;
  dynamic address;
  dynamic address2;
  dynamic city;
  dynamic state;
  dynamic zipCode;
  dynamic country;
  dynamic customerNotes;
  String? vendorServiceFeeAmount;
  String? vendorServiceFee;
  int? createUser;
  dynamic updateUser;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic buyerFees;
  String? totalBeforeFees;
  dynamic paidVendor;
  dynamic objectChildId;
  dynamic number;
  dynamic paid;
  dynamic payNow;
  dynamic walletCreditUsed;
  dynamic walletTotalUsed;
  dynamic walletTransactionId;
  dynamic isRefundWallet;
  dynamic isPaid;
  String? totalBeforeDiscount;
  String? couponAmount;
  List<dynamic>? extraPrice;
  List<SeatDetail>? seatDetails;
  Service? service;
  String? shareUrl;

  Booking({
    this.id,
    this.code,
    this.vendorId,
    this.customerId,
    this.paymentId,
    this.gateway,
    this.objectId,
    this.objectModel,
    this.startDate,
    this.endDate,
    this.total,
    this.totalGuests,
    this.currency,
    this.status,
    this.deposit,
    this.depositType,
    this.commission,
    this.commissionType,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.address2,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.customerNotes,
    this.vendorServiceFeeAmount,
    this.vendorServiceFee,
    this.createUser,
    this.updateUser,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.buyerFees,
    this.totalBeforeFees,
    this.paidVendor,
    this.objectChildId,
    this.number,
    this.paid,
    this.payNow,
    this.walletCreditUsed,
    this.walletTotalUsed,
    this.walletTransactionId,
    this.isRefundWallet,
    this.isPaid,
    this.totalBeforeDiscount,
    this.couponAmount,
    this.extraPrice,
    this.seatDetails,
    this.service,
    this.shareUrl,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      code: json['code'],
      vendorId: json['vendor_id'],
      customerId: json['customer_id'],
      paymentId: json['payment_id'],
      gateway: json['gateway'],
      objectId: json['object_id'],
      objectModel: json['object_model'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      total: json['total'],
      totalGuests: json['total_guests'],
      currency: json['currency'],
      status: json['status'],
      deposit: json['deposit'],
      depositType: json['deposit_type'],
      commission: json['commission'],
      commissionType: json['commission_type'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      address: json['address'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      country: json['country'],
      customerNotes: json['customer_notes'],
      vendorServiceFeeAmount: json['vendor_service_fee_amount'],
      vendorServiceFee: json['vendor_service_fee'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      buyerFees: json['buyer_fees'],
      totalBeforeFees: json['total_before_fees'],
      paidVendor: json['paid_vendor'],
      objectChildId: json['object_child_id'],
      number: json['number'],
      paid: json['paid'],
      payNow: json['pay_now'],
      walletCreditUsed: json['wallet_credit_used'],
      walletTotalUsed: json['wallet_total_used'],
      walletTransactionId: json['wallet_transaction_id'],
      isRefundWallet: json['is_refund_wallet'],
      isPaid: json['is_paid'],
      totalBeforeDiscount: json['total_before_discount'],
      couponAmount: json['coupon_amount'],
      extraPrice: json["extra_price"] == null
          ? []
          : List<dynamic>.from(json["extra_price"]!.map((x) => x)),
      seatDetails: json['seat_details'] != null
          ? List<SeatDetail>.from(
              json['seat_details'].map((x) => SeatDetail.fromJson(x)))
          : null,
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
      shareUrl: json['share_url'],
    );
  }
}


class SeatDetail {
  String? id;
  String? price;
  SeatType? seatType;
  String? number;

  SeatDetail({
    this.id,
    this.price,
    this.seatType,
    this.number,
  });

  factory SeatDetail.fromJson(Map<String, dynamic> json) {
    return SeatDetail(
      id: json['id'],
      price: json['price'],
      seatType: json['seat_type'] != null
          ? SeatType.fromJson(json['seat_type'])
          : null,
      number: json['number'],
    );
  }
}

class SeatType {
  String? id;
  String? code;

  SeatType({
    this.id,
    this.code,
  });
  
  static fromJson(json) {
    return SeatType(
      id: json['id'],
      code: json['code'],
    );
  }
}

class Service {
  int? id;
  String? title;
  String? code;
  String? reviewScore;
  DateTime? departureTime;
  DateTime? arrivalTime;
  String? duration;
  String? minPrice;
  Airport? airportTo;
  Airport? airportFrom;
  int? airlineId;
  String? status;
  dynamic createUser;
  dynamic updateUser;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  dynamic authorId;
  List<dynamic>? gallery;
  VendorDetails? vendorDetails;
  String? airportImageUrl;
  bool? canBook;
  Airline? airline;
  List<dynamic>? bookingPassengers;
  List<FlightSeat>? flightSeat;

  Service({
    this.id,
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
    this.gallery,
    this.vendorDetails,
    this.airportImageUrl,
    this.canBook,
    this.airline,
    this.bookingPassengers,
    this.flightSeat,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      code: json['code'],
      reviewScore: json['review_score'],
      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'])
          : null,
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'])
          : null,
      duration: json['duration'],
      minPrice: json['min_price'],
      airportTo: json['airport_to'] != null
          ? Airport.fromJson(json['airport_to'])
          : null,
      airportFrom: json['airport_from'] != null
          ? Airport.fromJson(json['airport_from'])
          : null,
      airlineId: json['airline_id'],
      status: json['status'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'],
      authorId: json['author_id'],
      gallery: json['gallery'],
      vendorDetails: json['vendor_details'] != null
          ? VendorDetails.fromJson(json['vendor_details'])
          : null,
      airportImageUrl: json['airport_image_url'],
      canBook: json['can_book'],
      airline: json['airline'] != null
          ? Airline.fromJson(json['airline'])
          : null,
      bookingPassengers: json['booking_passengers'],
      flightSeat: json['flight_seat'] != null
          ? List<FlightSeat>.from(
              json['flight_seat'].map((x) => FlightSeat.fromJson(x)))
          : null,
    );
  }
}

class Airline {
  int? id;
  String? name;
  int? imageId;
  dynamic createUser;
  dynamic updateUser;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic authorId;

  Airline({
    this.id,
    this.name,
    this.imageId,
    this.createUser,
    this.updateUser,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.authorId,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      id: json['id'],
      name: json['name'],
      imageId: json['image_id'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      authorId: json['author_id'],
    );
  }
}

class Airport {
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
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic authorId;

  Airport({
    this.id,
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
    this.authorId,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      country: json['country'],
      locationId: json['location_id'],
      description: json['description'],
      mapLat: json['map_lat'],
      mapLng: json['map_lng'],
      mapZoom: json['map_zoom'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      authorId: json['author_id'],
    );
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
  dynamic createUser;
  dynamic updateUser;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  dynamic authorId;

  FlightSeat({
    this.id,
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
  });

  factory FlightSeat.fromJson(Map<String, dynamic> json) {
    return FlightSeat(
      id: json['id'],
      price: json['price'],
      maxPassengers: json['max_passengers'],
      flightId: json['flight_id'],
      seatType: json['seat_type'],
      person: json['person'],
      baggageCheckIn: json['baggage_check_in'],
      baggageCabin: json['baggage_cabin'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'],
      authorId: json['author_id'],
    );
  }
}

class VendorDetails {
  String? status;

  VendorDetails({
    this.status,
  });

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    return VendorDetails(
      status: json['status'],
    );
  }
}
