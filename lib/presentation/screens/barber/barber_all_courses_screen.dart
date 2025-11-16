import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/entities/barber_course_entity.dart';
import '../../../data/datasources/remote/barber_course_remote_datasource.dart';
import '../../widgets/common/app_card.dart';

class BarberAllCoursesScreen extends StatefulWidget {
  final String barberId;
  final String? barberName;

  const BarberAllCoursesScreen({
    super.key,
    required this.barberId,
    this.barberName,
  });

  @override
  State<BarberAllCoursesScreen> createState() => _BarberAllCoursesScreenState();
}

class _BarberAllCoursesScreenState extends State<BarberAllCoursesScreen> {
  final BarberCourseRemoteDataSource _courseDataSource =
      sl<BarberCourseRemoteDataSource>();
  List<BarberCourseEntity> _courses = [];
  bool _loading = true;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_loading &&
        _hasMore) {
      _loadMoreCourses();
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _loading = true;
    });

    try {
      final courses = await _courseDataSource.getBarberCourses(widget.barberId);
      setState(() {
        _courses = courses;
        _hasMore = courses.length >= _pageSize;
        _currentPage = 1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cursos: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreCourses() async {
    if (_loading || !_hasMore) return;

    setState(() {
      _loading = true;
    });

    try {
      // Since we're loading all courses at once, we'll simulate pagination
      // In a real scenario, you'd implement server-side pagination
      final allCourses = await _courseDataSource.getBarberCourses(widget.barberId);
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allCourses.length);
      
      if (startIndex < allCourses.length) {
        setState(() {
          _courses = allCourses;
          _hasMore = endIndex < allCourses.length;
          _currentPage++;
          _loading = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          widget.barberName != null
              ? 'Estudios y Cursos - ${widget.barberName}'
              : 'Estudios y Cursos',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: _loading && _courses.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            )
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay cursos disponibles',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCourses,
                  color: AppColors.primaryGold,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _courses.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _courses.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGold,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCourseCard(_courses[index])
                            .animate()
                            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 300.ms,
                              delay: (index * 50).ms,
                            ),
                      );
                    },
                  ),
                ),
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

