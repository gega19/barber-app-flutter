import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_course_entity.dart';
import '../common/app_card.dart';
import '../../screens/barber/barber_all_courses_screen.dart';

/// Widget para mostrar la lista de cursos de un barbero
class BarberCoursesListWidget extends StatelessWidget {
  final List<BarberCourseEntity> courses;
  final bool loading;
  final int? maxItems;
  final String? barberId;
  final String? barberName;

  const BarberCoursesListWidget({
    super.key,
    required this.courses,
    this.loading = false,
    this.maxItems,
    this.barberId,
    this.barberName,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(
            color: AppColors.primaryGold,
          ),
        ),
      );
    }

    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxItemsValue = maxItems ?? courses.length;
    final displayCourses = courses.length > maxItemsValue
        ? courses.take(maxItemsValue).toList()
        : courses;
    final hasMore = courses.length > maxItemsValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: const Text(
                'Estudios y Cursos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasMore && barberId != null)
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BarberAllCoursesScreen(
                        barberId: barberId!,
                        barberName: barberName,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Ver más cursos',
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...displayCourses.map((course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCourseCard(course),
            )),
      ],
    );
  }

  Widget _buildCourseCard(BarberCourseEntity course) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (course.institution != null &&
                        course.institution!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        course.institution!,
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (course.description != null && course.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              course.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (course.completedAt != null)
                _buildInfoChip(
                  Icons.calendar_today,
                  DateFormat('MMM yyyy', 'es').format(course.completedAt!),
                ),
              if (course.duration != null && course.duration!.isNotEmpty)
                _buildInfoChip(
                  Icons.access_time,
                  course.duration!,
                ),
              if (course.media.isNotEmpty)
                _buildInfoChip(
                  Icons.image,
                  '${course.media.length} ${course.media.length == 1 ? 'imagen' : 'imágenes'}',
                ),
            ],
          ),
          // Course Media Preview
          if (course.media.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: course.media.length,
                itemBuilder: (context, index) {
                  final media = course.media[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            backgroundColor: Colors.black,
                            appBar: AppBar(
                              backgroundColor: Colors.transparent,
                              iconTheme: const IconThemeData(color: Colors.white),
                            ),
                            body: Center(
                              child: CachedNetworkImage(
                                imageUrl: media.url,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: media.thumbnail != null
                            ? CachedNetworkImage(
                                imageUrl: media.thumbnail!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGold,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) => CachedNetworkImage(
                                  imageUrl: media.url,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.broken_image,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: media.url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGold,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.broken_image,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGold),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

