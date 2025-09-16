class MediaFile {
  final int id;
  final String fileType;
  final String originalFilename;
  final String contentType;
  final int size;
  final DateTime createdAt;
  final String url;

  MediaFile({
    required this.id,
    required this.fileType,
    required this.originalFilename,
    required this.contentType,
    required this.size,
    required this.createdAt,
    required this.url,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] as int,
      fileType: json['file_type'] as String,
      originalFilename: json['original_filename'] as String,
      contentType: json['content_type'] as String,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_type': fileType,
      'original_filename': originalFilename,
      'content_type': contentType,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'url': url,
    };
  }

  bool get isImage => fileType == 'image';
  bool get isAudio => fileType == 'audio';

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
