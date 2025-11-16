import '../../domain/entities/barber_course_entity.dart';
import 'barber_course_media_model.dart';

/// Modelo de curso de barbero para la capa de datos
class BarberCourseModel extends BarberCourseEntity {
  const BarberCourseModel({
    required super.id,
    required super.barberId,
    required super.title,
    super.institution,
    super.description,
    super.completedAt,
    super.duration,
    required super.createdAt,
    required super.updatedAt,
    super.media,
  });

  factory BarberCourseModel.fromJson(Map<String, dynamic> json) {
    return BarberCourseModel(
      id: json['id'] as String,
      barberId: json['barberId'] as String,
      title: json['title'] as String,
      institution: json['institution'] as String?,
      description: json['description'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      duration: json['duration'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      media: json['media'] != null
          ? (json['media'] as List<dynamic>)
              .map((m) => BarberCourseMediaModel.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barberId': barberId,
      'title': title,
      if (institution != null) 'institution': institution,
      if (description != null) 'description': description,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (duration != null) 'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (media.isNotEmpty) 'media': media.map((m) => (m as BarberCourseMediaModel).toJson()).toList(),
    };
  }

  factory BarberCourseModel.fromEntity(BarberCourseEntity entity) {
    return BarberCourseModel(
      id: entity.id,
      barberId: entity.barberId,
      title: entity.title,
      institution: entity.institution,
      description: entity.description,
      completedAt: entity.completedAt,
      duration: entity.duration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      media: entity.media,
    );
  }
}

