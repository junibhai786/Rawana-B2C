// lib/modals/activity_model.dart

class ActivityModel {
  final String id;
  final String provider;
  final int? dbActivityId;
  final String title;
  final String? slug;
  final String? category;
  final String? city;
  final String? country;
  final String? address;
  final String? description;
  final double? pricePerPerson;
  final String? currency;
  final double? convertedPricePerPerson;
  final String? convertedCurrency;
  final int? maxParticipants;
  final String? duration;
  final bool instantConfirmation;
  final String? imageUrl;
  final List<String> galleryUrls;
  final String? authorName;

  const ActivityModel({
    required this.id,
    required this.provider,
    this.dbActivityId,
    required this.title,
    this.slug,
    this.category,
    this.city,
    this.country,
    this.address,
    this.description,
    this.pricePerPerson,
    this.currency,
    this.convertedPricePerPerson,
    this.convertedCurrency,
    this.maxParticipants,
    this.duration,
    required this.instantConfirmation,
    this.imageUrl,
    required this.galleryUrls,
    this.authorName,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      dbActivityId: json['db_activity_id'] as int?,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      category: json['category']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      pricePerPerson: (json['price_per_person'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      convertedPricePerPerson:
          (json['converted_price_per_person'] as num?)?.toDouble(),
      convertedCurrency: json['converted_currency']?.toString(),
      maxParticipants: json['max_participants'] as int?,
      duration: json['duration']?.toString(),
      instantConfirmation: json['instant_confirmation'] == true,
      imageUrl: json['image_url']?.toString(),
      galleryUrls: (json['gallery_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      authorName: json['author_name']?.toString(),
    );
  }
}

class ActivitySearchResponse {
  final bool success;
  final int count;
  final List<ActivityModel> data;
  final ActivityPagination? pagination;

  const ActivitySearchResponse({
    required this.success,
    required this.count,
    required this.data,
    this.pagination,
  });

  factory ActivitySearchResponse.fromJson(Map<String, dynamic> json) {
    return ActivitySearchResponse(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? ActivityPagination.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ActivityPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ActivityPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ActivityPagination.fromJson(Map<String, dynamic> json) {
    return ActivityPagination(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
