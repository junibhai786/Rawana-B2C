class OfferModel {
  final bool active;
  final String title;
  final String desc;
  final int backgroundImage;
  final String linkTitle;
  final String linkMore;
  final String? featuredText;
  final String? featuredIcon;
  final String backgroundImageUrl;

  OfferModel({
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

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      active: json['_active'] ?? false,
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      backgroundImage: json['background_image'] ?? 0,
      linkTitle: json['link_title'] ?? '',
      linkMore: json['link_more'] ?? '',
      featuredText: json['featured_text'],
      featuredIcon: json['featured_icon'],
      backgroundImageUrl: json['background_image_url'] ?? '',
    );
  }
}
