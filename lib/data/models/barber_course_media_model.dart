import '../../domain/entities/barber_course_media_entity.dart';

/// Modelo de media de curso de barbero para la capa de datos
class BarberCourseMediaModel extends BarberCourseMediaEntity {
  const BarberCourseMediaModel({
    required super.id,
    required super.courseId,
    required super.type,
    required super.url,
    super.thumbnail,
    super.caption,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BarberCourseMediaModel.fromJson(Map<String, dynamic> json) {
    return BarberCourseMediaModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
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
      'courseId': courseId,
      'type': type,
      'url': url,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (caption != null) 'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BarberCourseMediaModel.fromEntity(BarberCourseMediaEntity entity) {
    return BarberCourseMediaModel(
      id: entity.id,
      courseId: entity.courseId,
      type: entity.type,
      url: entity.url,
      thumbnail: entity.thumbnail,
      caption: entity.caption,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

