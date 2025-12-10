class AddCarLocationModel {
  List<Data>? data;
  int? status;

  AddCarLocationModel({this.data, this.status});

  AddCarLocationModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    // ignore: unnecessary_this
    data['status'] = this.status;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? content;
  String? slug;
  int? imageId;
  String? mapLat;
  String? mapLng;
  int? mapZoom;
  String? status;
  int? iLft;
  int? iRgt;

  int? createUser;

  String? createdAt;
  String? updatedAt;
  int? bannerImageId;

  Null? gallery;

  Data(
      {this.id,
      this.name,
      this.content,
      this.slug,
      this.imageId,
      this.mapLat,
      this.mapLng,
      this.mapZoom,
      this.status,
      this.iLft,
      this.iRgt,
      this.createUser,
      this.createdAt,
      this.updatedAt,
      this.bannerImageId,
      this.gallery});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    content = json['content'];
    slug = json['slug'];
    imageId = json['image_id'];
    mapLat = json['map_lat'];
    mapLng = json['map_lng'];
    mapZoom = json['map_zoom'];
    status = json['status'];
    iLft = json['_lft'];
    iRgt = json['_rgt'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bannerImageId = json['banner_image_id'];

    gallery = json['gallery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['content'] = this.content;
    data['slug'] = this.slug;
    data['image_id'] = this.imageId;
    data['map_lat'] = this.mapLat;
    data['map_lng'] = this.mapLng;
    data['map_zoom'] = this.mapZoom;
    data['status'] = this.status;
    data['_lft'] = this.iLft;
    data['_rgt'] = this.iRgt;

    data['create_user'] = this.createUser;

    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['banner_image_id'] = this.bannerImageId;

    data['gallery'] = this.gallery;
    return data;
  }
}
