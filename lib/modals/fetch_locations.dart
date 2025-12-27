class LocationResponse {
  final int? total;
  final int? totalPages;
  final int? status;
  final List<LocationItem> data;

  LocationResponse({
    this.total,
    this.totalPages,
    this.status,
    required this.data,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      total: json['total'] as int?,
      totalPages: json['total_pages'] as int?,
      status: json['status'] as int?,
      data: (json['data'] as List?)
          ?.map((e) => LocationItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'total_pages': totalPages,
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}


class LocationItem {
  final int? id;
  final String? title;
  final String? image;
  final String? content;

  LocationItem({
    this.id,
    this.title,
    this.image,
    this.content,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'] as int?,
      title: json['title']?.toString(),
      image: json['image']?.toString(),
      content: json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'content': content,
    };
  }
}
