class EventDetailsForVendor {
  String message;
  List<EventDataVendor> data;

  EventDetailsForVendor({required this.message, required this.data});

  factory EventDetailsForVendor.fromJson(Map<String, dynamic> json) {
    return EventDetailsForVendor(
      message: json['message'],
      data: List<EventDataVendor>.from(
          json['data'].map((item) => EventDataVendor.fromJson(item))),
    );
  }
}

class EventDataVendor {
  int id;
  String objectModel;
  String title;
  int price;
  int salePrice;
  String? discountPercent;
  String image;
  String content;
  Location location;
  bool? isFeatured;
  String address;
  String mapLat;
  String mapLng;
  int mapZoom;
  String bannerImage;
  List<String> gallery;
  String video;
  int enableExtraPrice;
  List<ExtraPrice> extraPrice;
  String duration;
  String startTime;
  String detailsUrl;
  String updatedAt;
  String status;
  Vendor vendor;
  String shareUrl;
  bool isInWishlist;
  ReviewScore reviewScore;
  List<String> reviewStats;
  ReviewLists reviewLists;
  List<Faq> faqs;
  List<TicketType> ticketTypes;

  int defaultState;
  List<BookingFee> bookingFee;
  Map<String, List<SurroundingItem>> surrounding;
  List<Related> related;
  List<Terms> terms;

  EventDataVendor({
    required this.id,
    required this.objectModel,
    required this.title,
    required this.price,
    required this.salePrice,
    this.discountPercent,
    required this.image,
    required this.content,
    required this.location,
    this.isFeatured,
    required this.address,
    required this.mapLat,
    required this.mapLng,
    required this.mapZoom,
    required this.bannerImage,
    required this.gallery,
    required this.video,
    required this.enableExtraPrice,
    required this.extraPrice,
    required this.duration,
    required this.startTime,
    required this.detailsUrl,
    required this.updatedAt,
    required this.status,
    required this.vendor,
    required this.shareUrl,
    required this.isInWishlist,
    required this.reviewScore,
    required this.reviewStats,
    required this.reviewLists,
    required this.faqs,
    required this.ticketTypes,
    required this.defaultState,
    required this.bookingFee,
    required this.surrounding,
    required this.related,
    required this.terms,
  });

  factory EventDataVendor.fromJson(Map<String, dynamic> json) {
    return EventDataVendor(
      id: json['id'],
      objectModel: json['object_model'],
      title: json['title'],
      price: json['price'],
      salePrice: json['sale_price'],
      discountPercent: json['discount_percent'],
      image: json['image'],
      content: json['content'],
      location: Location.fromJson(json['location']),
      isFeatured: false,
      address: json['address'],
      mapLat: json['map_lat'],
      mapLng: json['map_lng'],
      mapZoom: json['map_zoom'],
      bannerImage: json['banner_image'],
      gallery: List<String>.from(json['gallery']),
      video: json['video'] ?? "",
      enableExtraPrice: json['enable_extra_price'],
      extraPrice: json['extra_price'] != null
          ? List<ExtraPrice>.from(
              json['extra_price'].map((item) => ExtraPrice.fromJson(item)))
          : [],
      duration: json['duration'],
      startTime: json['start_time'],
      detailsUrl: json['details_url'],
      updatedAt: json['updated_at'],
      status: json['status'],
      vendor: Vendor.fromJson(json['vendor']),
      shareUrl: json['share_url'],
      isInWishlist: json['is_in_wishlist'],
      reviewScore: ReviewScore.fromJson(json['review_score']),
      reviewStats: List<String>.from(json['review_stats']),
      reviewLists: ReviewLists.fromJson(json['review_lists']),
      faqs: json['faqs'] != null
          ? List<Faq>.from(json['faqs'].map((item) => Faq.fromJson(item)))
          : [],
      ticketTypes: json['ticket_types'] != null
          ? List<TicketType>.from(
              json['ticket_types'].map((item) => TicketType.fromJson(item)))
          : [],
      defaultState: json['default_state'],
      bookingFee: json['booking_fee'] != null
          ? List<BookingFee>.from(
              json['booking_fee'].map((item) => BookingFee.fromJson(item)))
          : [],
      surrounding: (json['surrounding'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          List<SurroundingItem>.from(
              (value as List).map((item) => SurroundingItem.fromJson(item))),
        ),
      ),
      related: json['related'] != null || json['related'].toString().isNotEmpty
          ? List<Related>.from(
              json['related'].map((item) => Related.fromJson(item)))
          : [],
      terms:
          List<Terms>.from(json['terms'].map((item) => Terms.fromJson(item))),
    );
  }
}

class Location {
  int? id;
  String? name;

  Location({this.id, this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ExtraPrice {
  String? name;
  String? nameJa;
  String? nameEgy;
  String? price;
  String? type;
  String? perPerson;

  ExtraPrice(
      {this.name,
      this.nameJa,
      this.nameEgy,
      this.price,
      this.type,
      this.perPerson});

  factory ExtraPrice.fromJson(Map<String, dynamic> json) {
    return ExtraPrice(
      name: json['name'],
      nameJa: json['name_ja'],
      nameEgy: json['name_egy'],
      price: json['price'],
      type: json['type'],
      perPerson: json['per_person'],
    );
  }
}

class Vendor {
  int? id;
  String? name;
  String? email;
  String? createdAt;
  String? avatarUrl;

  Vendor({this.id, this.name, this.email, this.createdAt, this.avatarUrl});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class ReviewScore {
  dynamic scoreTotal;
  String? scoreText;
  int? totalReview;
  List<RateScore>? rateScore;

  ReviewScore(
      {this.scoreTotal, this.scoreText, this.totalReview, this.rateScore});

  factory ReviewScore.fromJson(Map<String, dynamic> json) {
    return ReviewScore(
      scoreTotal: json['score_total'],
      scoreText: json['score_text'],
      totalReview: json['total_review'],
      rateScore: json['rate_score'] != null
          ? (json['rate_score'] as List)
              .map((item) => RateScore.fromJson(item))
              .toList()
          : [],
    );
  }
}

class RateScore {
  String? title;
  int? total;
  int? percent;

  RateScore({this.title, this.total, this.percent});

  factory RateScore.fromJson(Map<String, dynamic> json) {
    return RateScore(
      title: json['title'],
      total: json['total'],
      percent: json['percent'],
    );
  }
}

class ReviewLists {
  int? currentPage;
  List<ReviewData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  ReviewLists({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ReviewLists.fromJson(Map<String, dynamic> json) {
    return ReviewLists(
      currentPage: json['current_page'],
      data: (json['data'] as List)
          .map((item) => ReviewData.fromJson(item))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links:
          (json['links'] as List).map((item) => Links.fromJson(item)).toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class ReviewData {
  int? id;
  String? title;
  String? content;
  int? rateNumber;
  String? authorIp;
  String? status;
  String? createdAt;
  int? vendorId;
  int? authorId;
  Author? author;

  ReviewData({
    this.id,
    this.title,
    this.content,
    this.rateNumber,
    this.authorIp,
    this.status,
    this.createdAt,
    this.vendorId,
    this.authorId,
    this.author,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      rateNumber: json['rate_number'],
      authorIp: json['author_ip'],
      status: json['status'],
      createdAt: json['created_at'],
      vendorId: json['vendor_id'],
      authorId: json['author_id'],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
    );
  }
}

class Author {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  dynamic avatarId;
  String? avatarUrl;

  Author(
      {this.id,
      this.name,
      this.firstName,
      this.lastName,
      this.avatarId,
      this.avatarUrl});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarId: json['avatar_id'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}

class Faq {
  String? title;
  String? content;

  Faq({this.title, this.content});

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      title: json['title'],
      content: json['content'],
    );
  }
}

class TicketType {
  String? code;
  String? name;
  String? nameJa;
  String? nameEgy;
  String? price;
  String? number;

  TicketType(
      {this.code,
      this.name,
      this.nameJa,
      this.nameEgy,
      this.price,
      this.number});

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      code: json['code'],
      name: json['name'],
      nameJa: json['name_ja'],
      nameEgy: json['name_egy'],
      price: json['price'],
      number: json['number'],
    );
  }
}

class BookingFee {
  String? name;
  String? desc;
  String? nameJa;
  String? descJa;
  String? price;
  String? type;

  BookingFee(
      {this.name, this.desc, this.nameJa, this.descJa, this.price, this.type});

  factory BookingFee.fromJson(Map<String, dynamic> json) {
    return BookingFee(
      name: json['name'],
      desc: json['desc'],
      nameJa: json['name_ja'],
      descJa: json['desc_ja'],
      price: json['price'],
      type: json['type'],
    );
  }
}

class SurroundingItem {
  String name;
  String content;
  String value;
  String type;

  SurroundingItem(
      {required this.name,
      required this.content,
      required this.value,
      required this.type});

  factory SurroundingItem.fromJson(Map<String, dynamic> json) {
    return SurroundingItem(
      name: json['name'],
      content: json['content'],
      value: json['value'],
      type: json['type'],
    );
  }
}

class Related {
  int? id;
  String? objectModel;
  String? title;
  dynamic price;
  dynamic salePrice;
  dynamic discountPercent;
  String? image;
  String? content;
  Location? location;
  int? isFeatured;
  int? maxGuests;
  int? bed;
  int? bathroom;
  int? square;
  ReviewScore? reviewScore;

  Related({
    this.id,
    this.objectModel,
    this.title,
    this.price,
    this.salePrice,
    this.discountPercent,
    this.image,
    this.content,
    this.location,
    this.isFeatured,
    this.maxGuests,
    this.bed,
    this.bathroom,
    this.square,
    this.reviewScore,
  });

  factory Related.fromJson(Map<String, dynamic> json) {
    return Related(
      id: json['id'],
      objectModel: json['object_model'],
      title: json['title'],
      price: json['price'],
      salePrice: json['sale_price'],
      discountPercent: json['discount_percent'],
      image: json['image'],
      content: json['content'],
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      isFeatured: json['is_featured'],
      maxGuests: json['max_guests'],
      bed: json['bed'],
      bathroom: json['bathroom'],
      square: json['square'],
      reviewScore: json['review_score'] != null
          ? ReviewScore.fromJson(json['review_score'])
          : null,
    );
  }
}

class Terms {
  Parent? parent;
  List<Child>? child;

  Terms({this.parent, this.child});

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
      child:
          (json['child'] as List).map((item) => Child.fromJson(item)).toList(),
    );
  }
}

class Parent {
  int? id;
  String? title;
  String? slug;
  String? service;
  dynamic displayType;
  dynamic hideInSingle;

  Parent(
      {this.id,
      this.title,
      this.slug,
      this.service,
      this.displayType,
      this.hideInSingle});

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      service: json['service'],
      displayType: json['display_type'],
      hideInSingle: json['hide_in_single'],
    );
  }
}

class Child {
  int? id;
  String? title;
  dynamic content;
  int? imageId;
  String? imageUrl;
  dynamic icon;
  int? attrId;
  String? slug;

  Child(
      {this.id,
      this.title,
      this.content,
      this.imageId,
      this.imageUrl,
      this.icon,
      this.attrId,
      this.slug});

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageId: json['image_id'],
      imageUrl: json['image_url'],
      icon: json['icon'],
      attrId: json['attr_id'],
      slug: json['slug'],
    );
  }
}
