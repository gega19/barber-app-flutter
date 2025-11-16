import 'package:equatable/equatable.dart';

/// Entidad de media de curso de barbero del dominio
class BarberCourseMediaEntity extends Equatable {
  final String id;
  final String courseId;
  final String type; // "image", "document", "pdf", etc.
  final String url;
  final String? thumbnail;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BarberCourseMediaEntity({
    required this.id,
    required this.courseId,
    required this.type,
    required this.url,
    this.thumbnail,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        type,
        url,
        thumbnail,
        caption,
        createdAt,
        updatedAt,
      ];
}

