class BarberMediaModel {
  final String id;
  final String barberId;
  final String type;
  final String url;
  final String? thumbnail;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BarberMediaModel({
    required this.id,
    required this.barberId,
    required this.type,
    required this.url,
    this.thumbnail,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BarberMediaModel.fromJson(Map<String, dynamic> json) {
    return BarberMediaModel(
      id: json['id'] as String,
      barberId: json['barberId'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barberId': barberId,
      'type': type,
      'url': url,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (caption != null) 'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
