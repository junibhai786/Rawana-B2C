class ImageModal {
  final String path;
  final String name;
  final int size;
  final String fileType;
  final String fileExtension;
  final String downloadUrl;

  ImageModal({
    required this.path,
    required this.name,
    required this.size,
    required this.fileType,
    required this.fileExtension,
    required this.downloadUrl,
  });

  factory ImageModal.fromJson(Map<String, dynamic> json) {
    return ImageModal(
      path: json['path'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      fileType: json['file_type'] as String,
      fileExtension: json['file_extension'] as String,
      downloadUrl: json['download'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'file_type': fileType,
      'file_extension': fileExtension,
      'download': downloadUrl,
    };
  }
}
