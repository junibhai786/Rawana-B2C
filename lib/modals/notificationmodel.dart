class NotificationModel {
  String? message;
  List<Data>? data;

  NotificationModel({this.message, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
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
  String? type;
  String? notifiableType;
  int? notifiableId;
  Datas? datas;
  int? forAdmin;
  String? readAt;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.type,
      this.notifiableType,
      this.notifiableId,
      this.datas,
      this.forAdmin,
      this.readAt,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    notifiableType = json['notifiable_type'];
    notifiableId = json['notifiable_id'];
    datas = json['data'] != null ? new Datas.fromJson(json['data']) : null;
    forAdmin = json['for_admin'];
    readAt = json['read_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['notifiable_type'] = this.notifiableType;
    data['notifiable_id'] = this.notifiableId;
    if (this.datas != null) {
      data['data'] = this.datas!.toJson();
    }
    data['for_admin'] = this.forAdmin;
    data['read_at'] = this.readAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Datas {
  String? id;
  int? forAdmin;
  Notification? notification;

  Datas({this.id, this.forAdmin, this.notification});

  Datas.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    forAdmin = json['for_admin'];
    notification = json['notification'] != null
        ? new Notification.fromJson(json['notification'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['for_admin'] = this.forAdmin;
    if (this.notification != null) {
      data['notification'] = this.notification!.toJson();
    }
    return data;
  }
}

class Notification {
  int? id;
  String? event;
  String? to;
  String? name;
  String? avatar;
  String? link;
  String? type;
  String? message;

  Notification(
      {this.id,
      this.event,
      this.to,
      this.name,
      this.avatar,
      this.link,
      this.type,
      this.message});

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    event = json['event'];
    to = json['to'];
    name = json['name'];
    avatar = json['avatar'];
    link = json['link'];
    type = json['type'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['event'] = this.event;
    data['to'] = this.to;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['link'] = this.link;
    data['type'] = this.type;
    data['message'] = this.message;
    return data;
  }
}
