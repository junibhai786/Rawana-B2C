class BuyCreditModel {
  String? message;
  List<Data>? data;

  BuyCreditModel({this.message, this.data});

  BuyCreditModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  int? amount;
  int? credit;

  Data({this. name, this.amount, this.credit});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    amount = json['amount'];
    credit = json['credit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['amount'] = this.amount;
    data['credit'] = this.credit;
    return data;
  }
}
