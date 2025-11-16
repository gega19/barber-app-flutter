import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/entities/barber_course_entity.dart';
import '../../../data/datasources/remote/barber_course_remote_datasource.dart';
import '../../../presentation/cubit/barber_course/barber_course_cubit.dart';
import '../../../presentation/cubit/auth/auth_cubit.dart';
import '../../../data/datasources/remote/upload_remote_datasource.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/course/course_document_item_widget.dart';
import 'package:intl/intl.dart';

class BarberCoursesScreen extends StatefulWidget {
  const BarberCoursesScreen({super.key});

  @override
  State<BarberCoursesScreen> createState() => _BarberCoursesScreenState();
}

class _BarberCoursesScreenState extends State<BarberCoursesScreen> {
  String? _barberId;

  @override
  void initState() {
    super.initState();
    _loadBarberId();
  }

  void _loadBarberId() {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is AuthAuthenticated &&
        currentState.user.barberId != null) {
      setState(() {
        _barberId = currentState.user.barberId;
      });
      context.read<BarberCourseCubit>().loadCourses(_barberId!);
    }
  }

  Future<void> _showCourseForm({BarberCourseEntity? course}) async {
    final cubit = context.read<BarberCourseCubit>();

    // Si estamos editando, cargar el curso completo desde el servidor para tener los datos actualizados (incluyendo media)
    BarberCourseEntity? courseToEdit = course;
    if (course != null) {
      try {
        final courseDataSource = sl<BarberCourseRemoteDataSource>();
        final updatedCourse = await courseDataSource.getCourseById(course.id);
        courseToEdit = updatedCourse;
      } catch (e) {
        // Si falla, usar el curso que tenemos
        courseToEdit = course;
      }
    }

    final result = await showModalBottomSheet<BarberCourseEntity>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: _CourseFormModal(course: courseToEdit, barberId: _barberId!),
      ),
    );

    if (result != null && mounted && _barberId != null) {
      context.read<BarberCourseCubit>().loadCourses(_barberId!);
    }
  }

  Future<void> _deleteCourse(BarberCourseEntity course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Eliminar Curso',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${course.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && _barberId != null) {
      final success = await context.read<BarberCourseCubit>().deleteCourse(
        course.id,
        _barberId!,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso eliminado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar curso'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mis Cursos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: _barberId == null
            ? const Center(
                child: Text(
                  'No se pudo cargar la información del barbero',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : BlocBuilder<BarberCourseCubit, BarberCourseState>(
                builder: (context, state) {
                  if (state is BarberCourseLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    );
                  }

                  if (state is BarberCourseError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: 'Reintentar',
                            onPressed: () {
                              context.read<BarberCourseCubit>().loadCourses(
                                _barberId!,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BarberCourseLoaded) {
                    final courses = state.courses;

                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tienes cursos registrados',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Agrega tu primer curso',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<BarberCourseCubit>().loadCourses(
                          _barberId!,
                        );
                      },
                      color: AppColors.primaryGold,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return _buildCourseCard(course)
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                delay: (index * 50).ms,
                              );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'Cargando cursos...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: _barberId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCourseForm(),
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.add, color: AppColors.textDark),
              label: const Text(
                'Agregar Curso',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCourseCard(BarberCourseEntity course) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
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
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                color: AppColors.backgroundCard,
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCourseForm(course: course);
                  } else if (value == 'delete') {
                    _deleteCourse(course);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Editar',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
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
                _buildInfoChip(Icons.access_time, course.duration!),
              if (course.media.isNotEmpty)
                _buildInfoChip(
                  Icons.attach_file,
                  '${course.media.length} ${course.media.length == 1 ? 'documento' : 'documentos'}',
                ),
            ],
          ),
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
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGold),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CourseFormModal extends StatefulWidget {
  final BarberCourseEntity? course;
  final String barberId;

  const _CourseFormModal({this.course, required this.barberId});

  @override
  State<_CourseFormModal> createState() => _CourseFormModalState();
}

class _CourseFormModalState extends State<_CourseFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _institutionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime? _completedAt;
  bool _isLoading = false;
  List<CourseDocumentItem> _documents = [];
  final UploadRemoteDataSource _uploadDataSource = sl<UploadRemoteDataSource>();
  final BarberCourseRemoteDataSource _courseDataSource =
      sl<BarberCourseRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _institutionController.text = widget.course!.institution ?? '';
      _descriptionController.text = widget.course!.description ?? '';
      _durationController.text = widget.course!.duration ?? '';
      _completedAt = widget.course!.completedAt;
      // Load existing documents
      _documents = widget.course!.media
          .map(
            (m) => CourseDocumentItem(
              id: m.id,
              url: m.url,
              thumbnail: m.thumbnail,
              caption: m.caption,
              type: m.type,
            ),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _institutionController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.textDark,
              surface: AppColors.backgroundCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _completedAt = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _documents.add(
            CourseDocumentItem(
              url: pickedFile.name,
              type: 'image',
              localFile: File(pickedFile.path),
              caption: pickedFile.name,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showAddDocumentOptions() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agregar Imagen',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryGold,
              ),
              title: const Text(
                'Galería',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Seleccionar imagen desde galería',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            Divider(color: AppColors.borderGold),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryGold,
              ),
              title: const Text(
                'Cámara',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Tomar una foto',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _documents.add(
            CourseDocumentItem(
              url: pickedFile.name,
              type: 'image',
              localFile: File(pickedFile.path),
              caption: pickedFile.name,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadDocuments(String courseId) async {
    final documentsToUpload = _documents
        .where((d) => d.isLocal && !d.isUploading)
        .toList();

    if (documentsToUpload.isEmpty) return;

    for (var i = 0; i < documentsToUpload.length; i++) {
      final doc = documentsToUpload[i];
      if (doc.localFile == null) continue;

      setState(() {
        final index = _documents.indexOf(doc);
        _documents[index] = CourseDocumentItem(
          url: doc.url,
          type: doc.type,
          localFile: doc.localFile,
          caption: doc.caption,
          isUploading: true,
        );
      });

      try {
        final uploadResult = await _uploadDataSource.uploadFileWithDetails(
          doc.localFile!,
        );

        await _courseDataSource.createCourseMedia(
          courseId,
          type: doc.type,
          url: uploadResult.url,
          thumbnail: uploadResult.thumbnail,
          caption: doc.caption,
        );

        setState(() {
          final index = _documents.indexOf(
            _documents.firstWhere((d) => d.localFile == doc.localFile),
          );
          _documents[index] = CourseDocumentItem(
            url: uploadResult.url,
            type: doc.type,
            thumbnail: uploadResult.thumbnail,
            caption: doc.caption,
            isUploading: false,
          );
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            final index = _documents.indexOf(
              _documents.firstWhere((d) => d.localFile == doc.localFile),
            );
            _documents.removeAt(index);
          });

          // Mostrar mensaje de error más amigable
          String errorMessage = 'Error al subir documento';
          if (e.toString().contains('File size too large') ||
              e.toString().contains('tamaño')) {
            errorMessage = 'El archivo es demasiado grande. Máximo 10 MB';
          } else if (e.toString().contains('network') ||
              e.toString().contains('Network')) {
            errorMessage = 'Error de conexión. Verifica tu internet';
          } else if (e.toString().contains('timeout')) {
            errorMessage = 'Tiempo de espera agotado. Intenta de nuevo';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<BarberCourseCubit>();
    String? courseId;

    if (widget.course == null) {
      // Para nuevos cursos, escuchar el stream para capturar el curso creado
      BarberCourseEntity? capturedCourse;

      try {
        // Esperar el estado BarberCourseCreated en paralelo con la creación
        final stateFuture = cubit.stream
            .where((state) => state is BarberCourseCreated)
            .first
            .timeout(const Duration(seconds: 5))
            .then((state) => state is BarberCourseCreated ? state.course : null)
            .catchError((e) => null);

        // Iniciar la creación del curso
        final success = await cubit.createCourse(
          widget.barberId,
          title: _titleController.text.trim(),
          institution: _institutionController.text.trim().isEmpty
              ? null
              : _institutionController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          completedAt: _completedAt,
          duration: _durationController.text.trim().isEmpty
              ? null
              : _durationController.text.trim(),
        );

        // Obtener el curso capturado del stream
        capturedCourse = await stateFuture;

        if (mounted) {
          if (success && capturedCourse != null) {
            courseId = capturedCourse.id;

            // Upload documents if there are any local files
            if (_documents.any((d) => d.isLocal)) {
              await _uploadDocuments(courseId);
              // Recargar el curso después de subir las imágenes para tener los datos actualizados
              if (mounted) {
                await cubit.loadCourses(widget.barberId);
              }
            }

            if (mounted) {
              Navigator.of(context).pop();
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al guardar curso'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar curso: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      // Para cursos existentes, actualizar
      final success = await cubit.updateCourse(
        widget.course!.id,
        widget.barberId,
        title: _titleController.text.trim(),
        institution: _institutionController.text.trim().isEmpty
            ? null
            : _institutionController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        completedAt: _completedAt,
        duration: _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
      );

      if (mounted) {
        if (success) {
          courseId = widget.course!.id;

          // Upload documents if there are any local files
          if (_documents.any((d) => d.isLocal)) {
            await _uploadDocuments(courseId);
            // Recargar el curso después de subir las imágenes para tener los datos actualizados
            if (mounted) {
              await cubit.loadCourses(widget.barberId);
            }
          }

          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar curso'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.course == null ? 'Nuevo Curso' : 'Editar Curso',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _titleController,
                label: 'Título del Curso *',
                hint: 'Ej: Técnicas de Corte Avanzado',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es requerido';
                  }
                  if (value.trim().length < 3) {
                    return 'El título debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _institutionController,
                label: 'Institución (Opcional)',
                hint: 'Ej: Academia de Barbería XYZ',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Descripción (Opcional)',
                hint: 'Describe el curso y lo que aprendiste',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: AppTextField(
                  controller: TextEditingController(
                    text: _completedAt != null
                        ? DateFormat('dd/MM/yyyy', 'es').format(_completedAt!)
                        : '',
                  ),
                  label: 'Fecha de Finalización (Opcional)',
                  hint: 'Selecciona la fecha',
                  enabled: false,
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _durationController,
                label: 'Duración (Opcional)',
                hint: 'Ej: 40 horas, 3 meses',
              ),
              const SizedBox(height: 24),
              // Documents Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Imágenes (Opcional)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddDocumentOptions,
                    icon: const Icon(
                      Icons.add_photo_alternate,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                    label: const Text(
                      'Agregar',
                      style: TextStyle(color: AppColors.primaryGold),
                    ),
                  ),
                ],
              ),
              if (_documents.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._documents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  return CourseDocumentItemWidget(
                        key: ValueKey('doc_${doc.id ?? index}_${doc.url}'),
                        document: doc,
                        onRemove: () {
                          setState(() {
                            _documents.removeAt(index);
                          });
                        },
                        showRemoveButton: true,
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.1, end: 0, duration: 300.ms);
                }),
              ],
              const SizedBox(height: 24),
              AppButton(
                text: widget.course == null ? 'Crear Curso' : 'Guardar Cambios',
                onPressed: _isLoading ? null : _saveCourse,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
