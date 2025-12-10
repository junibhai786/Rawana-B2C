enum ItemType { hotel, car, event, tour, space, boat, flight, location, offer }

class HomeItem {
  final ItemType type;
  final dynamic item;

  HomeItem({required this.type, required this.item});
}

class HomeList {
  final List<HomeItem> items;

  HomeList({required this.items});
}

class Location {
  final int id;
  final String name;
  final String? content;
  final String slug;
  final int imageId;
  final String mapLat;
  final String mapLng;
  final int mapZoom;
  final String status;
  final int lft;
  final int rgt;
  final int? parentId;
  final int createUser;
  final int? updateUser;
  final DateTime? deletedAt;
  final int? originId;
  final String? lang;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? bannerImageId;
  // final String? tripIdeas;

  final String? bannerImgUrl;
  final String imgUrl;
  final String hotelCount;
  final String spaceCount;
  final String tourCount;
  final dynamic translation;

  Location({
    required this.id,
    required this.name,
    this.content,
    required this.slug,
    required this.imageId,
    required this.mapLat,
    required this.mapLng,
    required this.mapZoom,
    required this.status,
    required this.lft,
    required this.rgt,
    this.parentId,
    required this.createUser,
    this.updateUser,
    this.deletedAt,
    this.originId,
    this.lang,
    required this.createdAt,
    required this.updatedAt,
    this.bannerImageId,
    // this.tripIdeas,
    this.bannerImgUrl,
    required this.imgUrl,
    required this.hotelCount,
    required this.spaceCount,
    required this.tourCount,
    this.translation,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      content: json['content'],
      slug: json['slug'],
      imageId: json['image_id'] ?? 0,
      mapLat: json['map_lat'] ?? "",
      mapLng: json['map_lng'] ?? "",
      mapZoom: json['map_zoom'],
      status: json['status'],
      lft: json['_lft'],
      rgt: json['_rgt'],
      parentId: json['parent_id'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      originId: json['origin_id'],
      lang: json['lang'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      bannerImageId: json['banner_image_id'],
      // tripIdeas: json['trip_ideas'],
      bannerImgUrl: json['banner_img_url'],
      imgUrl: json['img_url'] ?? "",
      hotelCount: json['hotel_count'],
      spaceCount: json['space_count'],
      tourCount: json['tour_count'],
      translation: json['translation'],
    );
  }

  map(HomeItem Function(dynamic item) param0) {}
}

class Offer {
  final bool active;
  final String title;
  final String desc;
  final int backgroundImage;
  final String linkTitle;
  final String linkMore;
  final String? featuredText;
  final String? featuredIcon;
  final String backgroundImageUrl;

  Offer({
    required this.active,
    required this.title,
    required this.desc,
    required this.backgroundImage,
    required this.linkTitle,
    required this.linkMore,
    this.featuredText,
    this.featuredIcon,
    required this.backgroundImageUrl,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      active: json['_active'] ?? false,
      title: json['title'],
      desc: json['desc'],
      backgroundImage: json['background_image'],
      linkTitle: json['link_title'],
      linkMore: json['link_more'],
      featuredText: json['featured_text'],
      featuredIcon: json['featured_icon'],
      backgroundImageUrl: json['background_image_url'],
    );
  }
}
