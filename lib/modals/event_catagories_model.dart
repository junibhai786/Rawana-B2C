class EventCatagoriesVendorModel {
  String? message;
  List<EventCatagories>? data;

  EventCatagoriesVendorModel({this.message, this.data});

  EventCatagoriesVendorModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <EventCatagories>[];
      json['data'].forEach((v) {
        data!.add(EventCatagories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventCatagories {
  int? id;
  String? name;
  String? slug;
  bool? value;

  EventCatagories({this.id, this.name, this.slug, this.value = false});

  EventCatagories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    value = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;

    return data;
  }
}
// ... existing code ...