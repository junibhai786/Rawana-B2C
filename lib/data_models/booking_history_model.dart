class Bookinghistory {
  List<Data>? data;
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;
  int? status;

  Bookinghistory(
      {this.data,
      this.total,
      this.perPage,
      this.currentPage,
      this.lastPage,
      this.from,
      this.to,
      this.status});

  Bookinghistory.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    from = json['from'];
    to = json['to'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['per_page'] = perPage;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['from'] = from;
    data['to'] = to;
    data['status'] = status;
    return data;
  }
}

class Data {
  int? id;
  String? code;
  int? vendorId;
  int? customerId;
  dynamic paymentId;
  String? gateway;
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
  CommissionType? commissionType;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;
  String? address;
  String? address2;
  String? city;
  String? state;
  String? zipCode;
  String? country;
  String? customerNotes;
  String? vendorServiceFeeAmount;
  String? vendorServiceFee;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  List<BuyerFees>? buyerFees;
  String? totalBeforeFees;
  dynamic paidVendor;
  dynamic objectChildId;
  dynamic number;
  String? paid;
  String? payNow;
  int? walletCreditUsed;
  int? walletTotalUsed;
  dynamic walletTransactionId;
  dynamic isRefundWallet;
  dynamic isPaid;
  String? totalBeforeDiscount;
  String? couponAmount;
  Service? service;
  BookingMeta? bookingMeta;
  String? serviceIcon;

  Data(
      {this.id,
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
      this.service,
      this.bookingMeta,
      this.serviceIcon});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    vendorId = json['vendor_id'];
    customerId = json['customer_id'];
    paymentId = json['payment_id'];
    gateway = json['gateway'];
    objectId = json['object_id'];
    objectModel = json['object_model'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    total = json['total'];
    totalGuests = json['total_guests'];
    currency = json['currency'];
    status = json['status'];
    deposit = json['deposit'];
    depositType = json['deposit_type'];
    commission = json['commission'];
    commissionType = json['commission_type'] != null
        ? CommissionType.fromJson(json['commission_type'])
        : null;
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
        buyerFees!.add(BuyerFees.fromJson(v));
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
        json['service'] != null ? Service.fromJson(json['service']) : null;
    bookingMeta = json['booking_meta'] != null
        ? BookingMeta.fromJson(json['booking_meta'])
        : null;
    serviceIcon = json['service_icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['code'] = code;
    data['vendor_id'] = vendorId;
    data['customer_id'] = customerId;
    data['payment_id'] = paymentId;
    data['gateway'] = gateway;
    data['object_id'] = objectId;
    data['object_model'] = objectModel;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['total'] = total;
    data['total_guests'] = totalGuests;
    data['currency'] = currency;
    data['status'] = status;
    data['deposit'] = deposit;
    data['deposit_type'] = depositType;
    data['commission'] = commission;
    if (commissionType != null) {
      data['commission_type'] = commissionType!.toJson();
    }
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone'] = phone;
    data['address'] = address;
    data['address2'] = address2;
    data['city'] = city;
    data['state'] = state;
    data['zip_code'] = zipCode;
    data['country'] = country;
    data['customer_notes'] = customerNotes;
    data['vendor_service_fee_amount'] = vendorServiceFeeAmount;
    data['vendor_service_fee'] = vendorServiceFee;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (buyerFees != null) {
      data['buyer_fees'] = buyerFees!.map((v) => v.toJson()).toList();
    }
    data['total_before_fees'] = totalBeforeFees;
    data['paid_vendor'] = paidVendor;
    data['object_child_id'] = objectChildId;
    data['number'] = number;
    data['paid'] = paid;
    data['pay_now'] = payNow;
    data['wallet_credit_used'] = walletCreditUsed;
    data['wallet_total_used'] = walletTotalUsed;
    data['wallet_transaction_id'] = walletTransactionId;
    data['is_refund_wallet'] = isRefundWallet;
    data['is_paid'] = isPaid;
    data['total_before_discount'] = totalBeforeDiscount;
    data['coupon_amount'] = couponAmount;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (bookingMeta != null) {
      data['booking_meta'] = bookingMeta!.toJson();
    }
    data['service_icon'] = serviceIcon;
    return data;
  }
}

class CommissionType {
  String? amount;
  String? type;

  CommissionType({this.amount, this.type});

  CommissionType.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['amount'] = amount;
    data['type'] = type;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['desc'] = desc;
    data['name_ja'] = nameJa;
    data['desc_ja'] = descJa;
    data['price'] = price;
    data['type'] = type;
    return data;
  }
}

class Service {
  String? title;

  Service({this.title});

  Service.fromJson(Map<String, dynamic> json) {
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    return data;
  }
}

class BookingMeta {
  dynamic duration;
  int? basePrice;
  dynamic salePrice;
  int? guests;
  int? adults;
  dynamic children;
  List<ExtraPrice>? extraPrice;
  String? locale;
  String? howToPay;

  BookingMeta(
      {this.duration,
      this.basePrice,
      this.salePrice,
      this.guests,
      this.adults,
      this.children,
      this.extraPrice,
      this.locale,
      this.howToPay});

  BookingMeta.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    basePrice = json['base_price'];
    salePrice = json['sale_price'];
    guests = json['guests'];
    adults = json['adults'];
    children = json['children'];
    if (json['extra_price'] != null) {
      extraPrice = <ExtraPrice>[];
      json['extra_price'].forEach((v) {
        extraPrice!.add(ExtraPrice.fromJson(v));
      });
    }
    locale = json['locale'];
    howToPay = json['how_to_pay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['duration'] = duration;
    data['base_price'] = basePrice;
    data['sale_price'] = salePrice;
    data['guests'] = guests;
    data['adults'] = adults;
    data['children'] = children;
    if (extraPrice != null) {
      data['extra_price'] = extraPrice!.map((v) => v.toJson()).toList();
    }
    data['locale'] = locale;
    data['how_to_pay'] = howToPay;
    return data;
  }
}

class ExtraPrice {
  String? name;
  String? price;
  String? type;
  dynamic total;
  dynamic nameJa;
  dynamic nameEgy;

  ExtraPrice(
      {this.name,
      this.price,
      this.type,
      this.total,
      this.nameJa,
      this.nameEgy});

  ExtraPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    type = json['type'];
    total = json['total'];
    nameJa = json['name_ja'];
    nameEgy = json['name_egy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['price'] = price;
    data['type'] = type;
    data['total'] = total;
    data['name_ja'] = nameJa;
    data['name_egy'] = nameEgy;
    return data;
  }
}
