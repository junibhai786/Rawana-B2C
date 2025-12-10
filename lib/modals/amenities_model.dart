// ... existing code ...
class AmenitiesModal {
  String? message;
  List<Amenity>? data;

  AmenitiesModal({this.message, this.data});

  AmenitiesModal.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Amenity>[];
      json['data'].forEach((v) {
        data!.add(Amenity.fromJson(v));
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

class Amenity {
  int? id;
  String? name;
  String? slug;
  bool? value;

  Amenity({this.id, this.name, this.slug, this.value = false});

  Amenity.fromJson(Map<String, dynamic> json) {
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