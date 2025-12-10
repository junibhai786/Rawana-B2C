// ... existing code ...

class CouponResponse {
  String message;
  List<CouponManage> data;

  CouponResponse({
    required this.message,
    required this.data,
  });

  static CouponResponse fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      message: json['message'],
      data: (json['data'] as List)
          .map((coupon) => CouponManage.fromJson(coupon))
          .toList(),
    );
  }
}

class CouponManage {
  final int id;
  final String code;
  final String name;
  final int amount;
  final String discountType;
  final String endDate;
  final int? minTotal;
  final int? maxTotal;
  final List<String> services;
  final int? onlyForUser;
  final String status;
  final int quantityLimit;
  final int limitPerUser;
  final int? imageId;
  final int createUser;
  final int? updateUser;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final int authorId;
  final int isVendor;
  final String? couponImageUrl;

  CouponManage({
    required this.id,
    required this.code,
    required this.name,
    required this.amount,
    required this.discountType,
    required this.endDate,
    this.minTotal,
    this.maxTotal,
    required this.services,
    this.onlyForUser,
    required this.status,
    required this.quantityLimit,
    required this.limitPerUser,
    this.imageId,
    required this.createUser,
    this.updateUser,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.isVendor,
    this.couponImageUrl,
  });

  static CouponManage fromJson(Map<String, dynamic> json) {
    return CouponManage(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      amount: json['amount'],
      discountType: json['discount_type'],
      endDate: json['end_date'],
      minTotal: json['min_total'],
      maxTotal: json['max_total'],
      services: List<String>.from(json['services']),
      onlyForUser: json['only_for_user'],
      status: json['status'],
      quantityLimit: json['quantity_limit'],
      limitPerUser: json['limit_per_user'],
      imageId: json['image_id'],
      createUser: json['create_user'],
      updateUser: json['update_user'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      authorId: json['author_id'],
      isVendor: json['is_vendor'],
      couponImageUrl: json['coupon_image_url'],
    );
  }
}

// ... existing code ...