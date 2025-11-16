import 'package:equatable/equatable.dart';
import 'barber_course_media_entity.dart';

/// Entidad de curso de barbero del dominio
class BarberCourseEntity extends Equatable {
  final String id;
  final String barberId;
  final String title;
  final String? institution;
  final String? description;
  final DateTime? completedAt;
  final String? duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BarberCourseMediaEntity> media;

  const BarberCourseEntity({
    required this.id,
    required this.barberId,
    required this.title,
    this.institution,
    this.description,
    this.completedAt,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.media = const [],
  });

  @override
  List<Object?> get props => [
        id,
        barberId,
        title,
        institution,
        description,
        completedAt,
        duration,
        createdAt,
        updatedAt,
        media,
      ];
}

