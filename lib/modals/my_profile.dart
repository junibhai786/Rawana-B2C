class MyProfile {
  bool? success;
  Data? data;
  int? status;

  MyProfile({this.success, this.data, this.status});

  MyProfile.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? firstName;
  String? lastName;
  String? businessName;
  String? email;
  String? emailVerifiedAt;
  String? emailOtp;
  String? otpExpireAt;
  int? emailVerified;
  String? twoFactorSecret;
  String? twoFactorRecoveryCodes;
  String? address;
  String? address2;
  String? phone;
  String? birthday;
  String? city;
  String? state;
  String? country;
  int? zipCode;
  String? lastLoginAt;
  int? avatarId;
  String? bio;
  String? status;
  String? reviewScore;
  String? createUser;
  String? updateUser;
  String? vendorCommissionAmount;
  String? vendorCommissionType;
  int? needUpdatePw;
  int? roleId;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  String? paymentGateway;
  String? totalGuests;
  String? locale;
  String? userName;
  String? verifySubmitStatus;
  int? isVerified;
  int? activeStatus;
  int? darkMode;
  String? messengerColor;
  String? stripeCustomerId;
  String? totalBeforeFees;
  String? creditBalance;
  String? avatarUrl;

  Data(
      {this.id,
      this.name,
      this.firstName,
      this.avatarUrl,
      this.lastName,
      this.businessName,
      this.email,
      this.emailVerifiedAt,
      this.emailOtp,
      this.otpExpireAt,
      this.emailVerified,
      this.twoFactorSecret,
      this.twoFactorRecoveryCodes,
      this.address,
      this.address2,
      this.phone,
      this.birthday,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.lastLoginAt,
      this.avatarId,
      this.bio,
      this.status,
      this.reviewScore,
      this.createUser,
      this.updateUser,
      this.vendorCommissionAmount,
      this.vendorCommissionType,
      this.needUpdatePw,
      this.roleId,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.paymentGateway,
      this.totalGuests,
      this.locale,
      this.userName,
      this.verifySubmitStatus,
      this.isVerified,
      this.activeStatus,
      this.darkMode,
      this.messengerColor,
      this.stripeCustomerId,
      this.totalBeforeFees,
      creditBalance});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? "";
    firstName = json['first_name'] ?? "";
    avatarUrl = json['avatar_url'] ?? "";
    lastName = json['last_name'] ?? "";
    businessName = json['business_name'] ?? "";
    email = json['email'] ?? "";
    emailVerifiedAt = json['email_verified_at'] ?? "";
    emailOtp = json['email_otp'] ?? "";
    otpExpireAt = json['otp_expire_at'] ?? "";
    emailVerified = json['email_verified'] is int
        ? json['email_verified']
        : (json['email_verified'] != null
            ? int.tryParse(json['email_verified'].toString())
            : null);
    twoFactorSecret = json['two_factor_secret'] ?? "";
    twoFactorRecoveryCodes = json['two_factor_recovery_codes'] ?? "";
    address = json['address'] ?? "";
    address2 = json['address2'] ?? "";
    phone = json['phone'] ?? "";
    birthday = json['birthday'] ?? "";
    city = json['city'] ?? "";
    state = json['state'] ?? "";
    country = json['country'] ?? "";
    zipCode = json['zip_code'] is int
        ? json['zip_code']
        : (json['zip_code'] != null
            ? int.tryParse(json['zip_code'].toString())
            : null);
    lastLoginAt = json['last_login_at'] ?? "";
    avatarId = json['avatar_id'] is int
        ? json['avatar_id']
        : (json['avatar_id'] != null
            ? int.tryParse(json['avatar_id'].toString())
            : null);
    bio = json['bio'] ?? "";
    status = json['status'] ?? "";
    reviewScore = json['review_score'] ?? "";
    createUser = json['create_user'] ?? "";
    updateUser = json['update_user'] ?? "";
    vendorCommissionAmount = json['vendor_commission_amount'] ?? "";
    vendorCommissionType = json['vendor_commission_type'] ?? "";
    needUpdatePw = json['need_update_pw'] is int
        ? json['need_update_pw']
        : (json['need_update_pw'] != null
            ? int.tryParse(json['need_update_pw'].toString())
            : null);
    roleId = json['role_id'] is int
        ? json['role_id']
        : (json['role_id'] != null
            ? int.tryParse(json['role_id'].toString())
            : null);
    deletedAt = json['deleted_at'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    paymentGateway = json['payment_gateway'] ?? "";
    totalGuests = json['total_guests'] ?? "";
    locale = json['locale'] ?? "";
    userName = json['user_name'] ?? "";
    verifySubmitStatus = json['verify_submit_status'] ?? "";
    isVerified = json['is_verified'] is int
        ? json['is_verified']
        : (json['is_verified'] != null
            ? int.tryParse(json['is_verified'].toString())
            : null);
    activeStatus = json['active_status'] is int
        ? json['active_status']
        : (json['active_status'] != null
            ? int.tryParse(json['active_status'].toString())
            : null);
    darkMode = json['dark_mode'] is int
        ? json['dark_mode']
        : (json['dark_mode'] != null
            ? int.tryParse(json['dark_mode'].toString())
            : null);
    messengerColor = json['messenger_color'] ?? "";
    stripeCustomerId = json['stripe_customer_id'] ?? "";
    totalBeforeFees = json['total_before_fees'] ?? "";
    creditBalance = json['credit_balance'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar_url'] = avatarUrl;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['business_name'] = businessName;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['email_otp'] = emailOtp;
    data['otp_expire_at'] = otpExpireAt;
    data['email_verified'] = emailVerified;
    data['two_factor_secret'] = twoFactorSecret;
    data['two_factor_recovery_codes'] = twoFactorRecoveryCodes;
    data['address'] = address;
    data['address2'] = address2;
    data['phone'] = phone;
    data['birthday'] = birthday;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['zip_code'] = zipCode;
    data['last_login_at'] = lastLoginAt;
    data['avatar_id'] = avatarId;
    data['bio'] = bio;
    data['status'] = status;
    data['review_score'] = reviewScore;
    data['create_user'] = createUser;
    data['update_user'] = updateUser;
    data['vendor_commission_amount'] = vendorCommissionAmount;
    data['vendor_commission_type'] = vendorCommissionType;
    data['need_update_pw'] = needUpdatePw;
    data['role_id'] = roleId;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['payment_gateway'] = paymentGateway;
    data['total_guests'] = totalGuests;
    data['locale'] = locale;
    data['user_name'] = userName;
    data['verify_submit_status'] = verifySubmitStatus;
    data['is_verified'] = isVerified;
    data['active_status'] = activeStatus;
    data['dark_mode'] = darkMode;
    data['messenger_color'] = messengerColor;
    data['stripe_customer_id'] = stripeCustomerId;
    data['total_before_fees'] = totalBeforeFees;
    data['credit_balance'] = creditBalance;
    return data;
  }
}
