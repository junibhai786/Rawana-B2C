class ManageService {
  String? message;
  List<ServiceModal>? data;

  ManageService({this.message, this.data});

  ManageService.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <ServiceModal>[];
      json['data'].forEach((v) {
        data!.add(ServiceModal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceModal {
  int? id;
  String? title;
  int? objectId;
  String? objectModel;

  ServiceModal({this.id, this.title, this.objectId, this.objectModel});

  ServiceModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    objectId = json['object_id'];
    objectModel = json['object_model'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['object_id'] = objectId;
    data['object_model'] = objectModel;
    return data;
  }
}
