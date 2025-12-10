class AllTransactionModel {
  String? message;
  List<Data>? data;

  AllTransactionModel({this.message, this.data});

  AllTransactionModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? paymentId;
  int? refId;
  String? type;
  String? amount;
  Meta? meta;
  String? status;
  dynamic deletedAt;
  int? createUser;
  int? updateUser;
  String? createdAt;
  String? updatedAt;
  Payment? payment;

  Data(
      {this.id,
      this.userId,
      this.paymentId,
      this.refId,
      this.type,
      this.amount,
      this.meta,
      this.status,
      this.deletedAt,
      this.createUser,
      this.updateUser,
      this.createdAt,
      this.updatedAt,
      this.payment});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    paymentId = json['payment_id'];
    refId = json['ref_id'];
    type = json['type'];
    amount = json['amount'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    status = json['status'];
    deletedAt = json['deleted_at'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['payment_id'] = this.paymentId;
    data['ref_id'] = this.refId;
    data['type'] = this.type;
    data['amount'] = this.amount;
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    data['status'] = this.status;
    data['deleted_at'] = this.deletedAt;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    return data;
  }
}

class Meta {
  int? walletTotalUsed;

  Meta({this.walletTotalUsed});

  Meta.fromJson(Map<String, dynamic> json) {
    walletTotalUsed = json['wallet_total_used'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wallet_total_used'] = this.walletTotalUsed;
    return data;
  }
}

class Payment {
  int? id;
  String? code;
  int? objectId;
  String? objectModel;
  dynamic meta;
  dynamic bookingId;
  String? paymentGateway;
  String? amount;
  dynamic currency;
  dynamic convertedAmount;
  dynamic convertedCurrency;
  dynamic exchangeRate;
  String? status;
  String? logs;
  int? createUser;
  int? updateUser;
  dynamic deletedAt;
  int? walletTransactionId;
  String? createdAt;
  String? updatedAt;
  dynamic userId;

  Payment(
      {this.id,
      this.code,
      this.objectId,
      this.objectModel,
      this.meta,
      this.bookingId,
      this.paymentGateway,
      this.amount,
      this.currency,
      this.convertedAmount,
      this.convertedCurrency,
      this.exchangeRate,
      this.status,
      this.logs,
      this.createUser,
      this.updateUser,
      this.deletedAt,
      this.walletTransactionId,
      this.createdAt,
      this.updatedAt,
      this.userId});

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    objectId = json['object_id'];
    objectModel = json['object_model'];
    meta = json['meta'];
    bookingId = json['booking_id'];
    paymentGateway = json['payment_gateway'];
    amount = json['amount'];
    currency = json['currency'];
    convertedAmount = json['converted_amount'];
    convertedCurrency = json['converted_currency'];
    exchangeRate = json['exchange_rate'];
    status = json['status'];
    logs = json['logs'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    deletedAt = json['deleted_at'];
    walletTransactionId = json['wallet_transaction_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['object_id'] = this.objectId;
    data['object_model'] = this.objectModel;
    data['meta'] = this.meta;
    data['booking_id'] = this.bookingId;
    data['payment_gateway'] = this.paymentGateway;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['converted_amount'] = this.convertedAmount;
    data['converted_currency'] = this.convertedCurrency;
    data['exchange_rate'] = this.exchangeRate;
    data['status'] = this.status;
    data['logs'] = this.logs;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['deleted_at'] = this.deletedAt;
    data['wallet_transaction_id'] = this.walletTransactionId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    return data;
  }
}
