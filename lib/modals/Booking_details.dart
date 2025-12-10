class BookingResponse {
  Data? data;
  int? status;

  BookingResponse({this.data, this.status});

  BookingResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    return data;
  }
}

class Data {
  Booking? booking;

  Data({this.booking});

  Data.fromJson(Map<String, dynamic> json) {
    booking =
        json['booking'] != null ? new Booking.fromJson(json['booking']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.booking != null) {
      data['booking'] = this.booking!.toJson();
    }
    return data;
  }
}

class Booking {
  int? id;
  String? code;
  int? vendorId;
  int? customerId;
  dynamic paymentId;
  dynamic gateway;
  int? objectId;
  String? objectModel;
  String? startDate;
  String? endDate;
  String? total;
  int? totalGuests;
  dynamic currency;
  String? status;
  dynamic deposit;
  dynamic depositType;
  dynamic commission;
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
  String? createdAt;
  String? updatedAt;
  List<BuyerFees>? buyerFees;
  List<ExtraPrice>? extraPrice;
  List<PersonTypes>? personTypes;
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
  Service? service;

  dynamic startTime;
  dynamic days;
  dynamic hours;

  String? shareUrl;

  Booking(
      {this.id,
      this.code,
      this.vendorId,
      this.customerId,
      this.paymentId,
      this.startTime,
      this.days,
      this.hours,
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
      this.extraPrice,
      this.personTypes,
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
      this.service,
      this.shareUrl});

  Booking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    vendorId = json['vendor_id'];
    customerId = json['customer_id'];
    paymentId = json['payment_id'];
    gateway = json['gateway'];
    objectId = json['object_id'];
    objectModel = json['object_model'];

    startTime = json['start_time'];
    days = json['days'];
    hours = json['hours'];

    startDate = json['start_date'];
    endDate = json['end_date'];
    total = json['total'];
    totalGuests = json['total_guests'];
    currency = json['currency'];
    status = json['status'];
    deposit = json['deposit'];
    depositType = json['deposit_type'];
    commission = json['commission'];
    commissionType = json['commission_type'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'];
    address = json['address'];
    address2 = json['address2'];
    city = json['city'];
    state = json['state'];
    zipCode = json['zip_code'];
    country = json['country'];
    customerNotes = json['customer_notes'];
    vendorServiceFeeAmount = json['vendor_service_fee_amount'];
    vendorServiceFee = json['vendor_service_fee'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['buyer_fees'] != null) {
      buyerFees = <BuyerFees>[];
      json['buyer_fees'].forEach((v) {
        buyerFees!.add(new BuyerFees.fromJson(v));
      });
    }
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(new ExtraPrice.fromJson(v));
      });
    }

    if (json['person_types'] != null) {
      personTypes = <PersonTypes>[];
      json['person_types'].forEach((v) {
        personTypes!.add(new PersonTypes.fromJson(v));
      });
    }

    totalBeforeFees = json['total_before_fees'];
    paidVendor = json['paid_vendor'];
    objectChildId = json['object_child_id'];
    number = json['number'];
    paid = json['paid'];
    payNow = json['pay_now'];
    walletCreditUsed = json['wallet_credit_used'];
    walletTotalUsed = json['wallet_total_used'];
    walletTransactionId = json['wallet_transaction_id'];
    isRefundWallet = json['is_refund_wallet'];
    isPaid = json['is_paid'];
    totalBeforeDiscount = json['total_before_discount'];
    couponAmount = json['coupon_amount'];

    service =
        json['service'] != null ? new Service.fromJson(json['service']) : null;
    shareUrl = json['share_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['vendor_id'] = this.vendorId;
    data['customer_id'] = this.customerId;
    data['payment_id'] = this.paymentId;
    data['gateway'] = this.gateway;

    data['start_time'] = this.startTime;
    data['days'] = this.days;
    data['hours'] = this.hours;

    data['object_id'] = this.objectId;
    data['object_model'] = this.objectModel;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['total'] = this.total;
    data['total_guests'] = this.totalGuests;
    data['currency'] = this.currency;
    data['status'] = this.status;
    data['deposit'] = this.deposit;
    data['deposit_type'] = this.depositType;
    data['commission'] = this.commission;
    data['commission_type'] = this.commissionType;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['address2'] = this.address2;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip_code'] = this.zipCode;
    data['country'] = this.country;
    data['customer_notes'] = this.customerNotes;
    data['vendor_service_fee_amount'] = this.vendorServiceFeeAmount;
    data['vendor_service_fee'] = this.vendorServiceFee;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.buyerFees != null) {
      data['buyer_fees'] = this.buyerFees!.map((v) => v.toJson()).toList();
    }
    if (this.extraPrice != null) {
      data['extra_price'] = this.extraPrice!.map((v) => v.toJson()).toList();
    }
    if (this.personTypes != null) {
      data['person_types'] = this.personTypes!.map((v) => v.toJson()).toList();
    }
    data['total_before_fees'] = this.totalBeforeFees;
    data['paid_vendor'] = this.paidVendor;
    data['object_child_id'] = this.objectChildId;
    data['number'] = this.number;
    data['paid'] = this.paid;
    data['pay_now'] = this.payNow;
    data['wallet_credit_used'] = this.walletCreditUsed;
    data['wallet_total_used'] = this.walletTotalUsed;
    data['wallet_transaction_id'] = this.walletTransactionId;
    data['is_refund_wallet'] = this.isRefundWallet;
    data['is_paid'] = this.isPaid;
    data['total_before_discount'] = this.totalBeforeDiscount;
    data['coupon_amount'] = this.couponAmount;
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    data['share_url'] = this.shareUrl;
    return data;
  }
}

class BuyerFees {
  String? name;
  String? desc;
  String? nameJa;
  String? descJa;
  String? price;
  String? type;

  BuyerFees(
      {this.name, this.desc, this.nameJa, this.descJa, this.price, this.type});

  BuyerFees.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    desc = json['desc'];
    nameJa = json['name_ja'];
    descJa = json['desc_ja'];
    price = json['price'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['name_ja'] = this.nameJa;
    data['desc_ja'] = this.descJa;
    data['price'] = this.price;
    data['type'] = this.type;
    return data;
  }
}

class Service {
  int? id;
  String? title;
  String? slug;
  String? content;
  int? imageId;
  int? bannerImageId;
  int? locationId;
  String? address;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  int? isFeatured;
  List<String>? gallery;
  String? video;
  List<Policy>? policy;
  int? starRate;
  dynamic price;
  String? checkInTime;
  String? checkOutTime;
  dynamic allowFullDay;
  dynamic salePrice;
  dynamic relatedIds;
  String? status;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? pricePerDay;
  String? pricePerHour;
  String? updatedAt;
  String? reviewScore;
  dynamic icalImportUrl;
  int? enableExtraPrice;
  List<ExtraPrice>? extraPrice;
  List<PersonTypes>? personTypes;
  dynamic enableServiceFee;
  dynamic serviceFee;
  dynamic surrounding;
  int? authorId;
  dynamic minDayBeforeBooking;
  dynamic minDayStays;
  List<RoomDetails>? roomDetails;
  VendorDetails? vendorDetails;

  Service(
      {this.id,
      this.title,
      this.slug,
      this.content,
      this.imageId,
      this.bannerImageId,
      this.locationId,
      this.address,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.isFeatured,
      this.gallery,
      this.video,
      this.policy,
      this.starRate,
      this.price,
      this.checkInTime,
      this.checkOutTime,
      this.allowFullDay,
      this.salePrice,
      this.relatedIds,
      this.status,
      this.pricePerDay,
      this.pricePerHour,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.reviewScore,
      this.icalImportUrl,
      this.enableExtraPrice,
      this.extraPrice,
      this.enableServiceFee,
      this.serviceFee,
      this.surrounding,
      this.authorId,
      this.minDayBeforeBooking,
      this.minDayStays,
      this.roomDetails,
      this.vendorDetails});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    imageId = json['image_id'];
    bannerImageId = json['banner_image_id'];
    locationId = json['location_id'];
    address = json['address'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    isFeatured = json['is_featured'];
    gallery = json['gallery'].cast<String>();
    video = json['video'];
    if (json['policy'] != null) {
      policy = <Policy>[];
      json['policy'].forEach((v) {
        policy!.add(new Policy.fromJson(v));
      });
    }
    starRate = json['star_rate'];
    price = json['price'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    allowFullDay = json['allow_full_day'];
    salePrice = json['sale_price'];
    relatedIds = json['related_ids'];
    status = json['status'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    reviewScore = json['review_score'];

    pricePerDay = json['price_per_day'] ?? "0";
    pricePerHour = json['price_per_hour'] ?? "0";

    icalImportUrl = json['ical_import_url'];
    enableExtraPrice = json['enable_extra_price'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(new ExtraPrice.fromJson(v));
      });
    }
    enableServiceFee = json['enable_service_fee'];
    serviceFee = json['service_fee'];
    surrounding = json['surrounding'];
    authorId = json['author_id'];
    minDayBeforeBooking = json['min_day_before_booking'];
    minDayStays = json['min_day_stays'];
    if (json['room_details'] != null) {
      roomDetails = <RoomDetails>[];
      json['room_details'].forEach((v) {
        roomDetails!.add(new RoomDetails.fromJson(v));
      });
    }
    vendorDetails = json['vendor_details'] != null
        ? new VendorDetails.fromJson(json['vendor_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['content'] = this.content;
    data['image_id'] = this.imageId;
    data['banner_image_id'] = this.bannerImageId;
    data['location_id'] = this.locationId;
    data['address'] = this.address;
    data['map_lat'] = this.mapLat;
    data['map_lng'] = this.mapLng;
    data['map_zoom'] = this.mapZoom;
    data['is_featured'] = this.isFeatured;

    data['price_per_day'] = this.pricePerDay;
    data['price_per_hour'] = this.pricePerHour;

    data['gallery'] = this.gallery;
    data['video'] = this.video;
    if (this.policy != null) {
      data['policy'] = this.policy!.map((v) => v.toJson()).toList();
    }
    data['star_rate'] = this.starRate;
    data['price'] = this.price;
    data['check_in_time'] = this.checkInTime;
    data['check_out_time'] = this.checkOutTime;
    data['allow_full_day'] = this.allowFullDay;
    data['sale_price'] = this.salePrice;
    data['related_ids'] = this.relatedIds;
    data['status'] = this.status;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['review_score'] = this.reviewScore;
    data['ical_import_url'] = this.icalImportUrl;
    data['enable_extra_price'] = this.enableExtraPrice;
    if (this.extraPrice != null) {
      data['extra_price'] = this.extraPrice!.map((v) => v.toJson()).toList();
    }
    if (this.personTypes != null) {
      data['person_types'] = this.personTypes!.map((v) => v.toJson()).toList();
    }
    data['enable_service_fee'] = this.enableServiceFee;
    data['service_fee'] = this.serviceFee;
    data['surrounding'] = this.surrounding;
    data['author_id'] = this.authorId;
    data['min_day_before_booking'] = this.minDayBeforeBooking;
    data['min_day_stays'] = this.minDayStays;
    if (this.roomDetails != null) {
      data['room_details'] = this.roomDetails!.map((v) => v.toJson()).toList();
    }
    if (this.vendorDetails != null) {
      data['vendor_details'] = this.vendorDetails!.toJson();
    }
    return data;
  }
}

class Policy {
  String? title;
  String? content;

  Policy({this.title, this.content});

  Policy.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['content'] = this.content;
    return data;
  }
}

class ExtraPrice {
  String? name;
  String? price;
  String? type;

  ExtraPrice({this.name, this.price, this.type});

  ExtraPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['type'] = this.type;
    return data;
  }
}

class PersonTypes {
  String? name;
  String? price;
  String? number;
  String? id;
  String? type;
  String? description;
  String? min;
  String? max;


  PersonTypes({this.name, this.price, this.number, this.id, this.type, this.description, this.min, this.max});

  PersonTypes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    number = json['number'];
    id = json['id'];
    type = json['type'];
    description = json['desc'];
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['number'] = this.number;
    data['id'] = this.id;
    data['type'] = this.type;
    data['desc'] = this.description;
    data['min'] = this.min;
    data['max'] = this.max;
    return data;
  }
}

class RoomDetails {
  int? id;
  int? roomId;
  int? parentId;
  int? bookingId;
  String? startDate;
  String? endDate;
  int? number;
  String? price;
  int? createUser;
  dynamic updateUser;
  String? createdAt;
  String? updatedAt;
  String? roomTitle;

  RoomDetails(
      {this.id,
      this.roomId,
      this.parentId,
      this.bookingId,
      this.startDate,
      this.endDate,
      this.number,
      this.price,
      this.createUser,
      this.updateUser,
      this.createdAt,
      this.updatedAt,
      this.roomTitle});

  RoomDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['room_id'];
    parentId = json['parent_id'];
    bookingId = json['booking_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    number = json['number'];
    price = json['price'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    roomTitle = json['room_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['room_id'] = this.roomId;
    data['parent_id'] = this.parentId;
    data['booking_id'] = this.bookingId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['number'] = this.number;
    data['price'] = this.price;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['room_title'] = this.roomTitle;
    return data;
  }
}

class VendorDetails {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  dynamic businessName;
  String? email;
  String? emailVerifiedAt;
  dynamic emailOtp;
  dynamic otpExpireAt;
  int? emailVerified;
  dynamic twoFactorSecret;
  dynamic twoFactorRecoveryCodes;
  dynamic address;
  dynamic address2;
  String? phone;
  dynamic birthday;
  String? city;
  dynamic state;
  String? country;
  dynamic zipCode;
  dynamic lastLoginAt;
  dynamic avatarId;
  String? bio;
  String? status;
  dynamic reviewScore;
  dynamic createUser;
  dynamic updateUser;
  dynamic vendorCommissionAmount;
  dynamic vendorCommissionType;
  int? needUpdatePw;
  int? roleId;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  dynamic paymentGateway;
  dynamic totalGuests;
  dynamic locale;
  dynamic userName;
  dynamic verifySubmitStatus;
  dynamic isVerified;
  int? activeStatus;
  int? darkMode;
  String? messengerColor;
  dynamic stripeCustomerId;
  dynamic totalBeforeFees;
  dynamic creditBalance;

  VendorDetails(
      {this.id,
      this.name,
      this.firstName,
      this.lastName,
      this.businessName,
      this.email,
      this.emailVerifiedAt,
      this.emailOtp,
      this.otpExpireAt,
      this.emailVerified,
      this.twoFactorSecret,
      this.twoFactorRecoveryCodes,
      this.address,
      this.address2,
      this.phone,
      this.birthday,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.lastLoginAt,
      this.avatarId,
      this.bio,
      this.status,
      this.reviewScore,
      this.createUser,
      this.updateUser,
      this.vendorCommissionAmount,
      this.vendorCommissionType,
      this.needUpdatePw,
      this.roleId,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.paymentGateway,
      this.totalGuests,
      this.locale,
      this.userName,
      this.verifySubmitStatus,
      this.isVerified,
      this.activeStatus,
      this.darkMode,
      this.messengerColor,
      this.stripeCustomerId,
      this.totalBeforeFees,
      this.creditBalance});

  VendorDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    businessName = json['business_name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    emailOtp = json['email_otp'];
    otpExpireAt = json['otp_expire_at'];
    emailVerified = json['email_verified'];
    twoFactorSecret = json['two_factor_secret'];
    twoFactorRecoveryCodes = json['two_factor_recovery_codes'];
    address = json['address'];
    address2 = json['address2'];
    phone = json['phone'];
    birthday = json['birthday'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipCode = json['zip_code'];
    lastLoginAt = json['last_login_at'];
    avatarId = json['avatar_id'];
    bio = json['bio'];
    status = json['status'];
    reviewScore = json['review_score'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    vendorCommissionAmount = json['vendor_commission_amount'];
    vendorCommissionType = json['vendor_commission_type'];
    needUpdatePw = json['need_update_pw'];
    roleId = json['role_id'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    paymentGateway = json['payment_gateway'];
    totalGuests = json['total_guests'];
    locale = json['locale'];
    userName = json['user_name'];
    verifySubmitStatus = json['verify_submit_status'];
    isVerified = json['is_verified'];
    activeStatus = json['active_status'];
    darkMode = json['dark_mode'];
    messengerColor = json['messenger_color'];
    stripeCustomerId = json['stripe_customer_id'];
    totalBeforeFees = json['total_before_fees'];
    creditBalance = json['credit_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['business_name'] = this.businessName;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['email_otp'] = this.emailOtp;
    data['otp_expire_at'] = this.otpExpireAt;
    data['email_verified'] = this.emailVerified;
    data['two_factor_secret'] = this.twoFactorSecret;
    data['two_factor_recovery_codes'] = this.twoFactorRecoveryCodes;
    data['address'] = this.address;
    data['address2'] = this.address2;
    data['phone'] = this.phone;
    data['birthday'] = this.birthday;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    data['last_login_at'] = this.lastLoginAt;
    data['avatar_id'] = this.avatarId;
    data['bio'] = this.bio;
    data['status'] = this.status;
    data['review_score'] = this.reviewScore;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['vendor_commission_amount'] = this.vendorCommissionAmount;
    data['vendor_commission_type'] = this.vendorCommissionType;
    data['need_update_pw'] = this.needUpdatePw;
    data['role_id'] = this.roleId;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['payment_gateway'] = this.paymentGateway;
    data['total_guests'] = this.totalGuests;
    data['locale'] = this.locale;
    data['user_name'] = this.userName;
    data['verify_submit_status'] = this.verifySubmitStatus;
    data['is_verified'] = this.isVerified;
    data['active_status'] = this.activeStatus;
    data['dark_mode'] = this.darkMode;
    data['messenger_color'] = this.messengerColor;
    data['stripe_customer_id'] = this.stripeCustomerId;
    data['total_before_fees'] = this.totalBeforeFees;
    data['credit_balance'] = this.creditBalance;
    return data;
  }
}
