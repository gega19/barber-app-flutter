import 'package:flutter/material.dart';

/// Modelo de datos para las páginas del onboarding
class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final String? imageAsset;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    this.imageAsset,
  });
}

/// Datos de las páginas del onboarding
class OnboardingData {
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'Bienvenido a Bartop',
      description:
          'Encuentra el barbero perfecto para ti. Explora cientos de profesionales cerca de ti.',
      icon: Icons.content_cut,
    ),
    OnboardingPageData(
      title: 'Explora y Descubre',
      description:
          'Busca barberos por especialidad, ubicación o calificación. Filtra y encuentra exactamente lo que necesitas.',
      icon: Icons.explore,
    ),
    OnboardingPageData(
      title: 'Reserva Fácilmente',
      description:
          'Agenda tu cita en pocos pasos. Selecciona fecha, hora y servicio. Todo desde tu móvil.',
      icon: Icons.calendar_today,
    ),
    OnboardingPageData(
      title: '¡Todo Listo!',
      description:
          'Ya estás listo para comenzar. Encuentra tu estilo perfecto y reserva tu próxima cita.',
      icon: Icons.check_circle,
    ),
  ];
}
