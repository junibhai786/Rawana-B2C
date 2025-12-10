class PendingCreditModel {
  String? message;
  List<Data>? data;
  int? totalPendingAmount;

  PendingCreditModel({this.message, this.data, this.totalPendingAmount});

  PendingCreditModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add( Data.fromJson(v));
      });
    }
    totalPendingAmount = json['total_pending_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // ignore: unnecessary_this
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    // ignore: unnecessary_this
    data['total_pending_amount'] = this.totalPendingAmount;
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? paymentId;
  Null? refId;
  String? type;
  String? amount;
  Null? meta;
  String? status;
  Null? deletedAt;
  int? createUser;
  Null? updateUser;
  String? createdAt;
  String? updatedAt;

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
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    paymentId = json['payment_id'];
    refId = json['ref_id'];
    type = json['type'];
    amount = json['amount'];
    meta = json['meta'];
    status = json['status'];
    deletedAt = json['deleted_at'];
    createUser = json['create_user'];
    updateUser = json['update_user'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['payment_id'] = this.paymentId;
    data['ref_id'] = this.refId;
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['meta'] = this.meta;
    data['status'] = this.status;
    data['deleted_at'] = this.deletedAt;
    data['create_user'] = this.createUser;
    data['update_user'] = this.updateUser;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
