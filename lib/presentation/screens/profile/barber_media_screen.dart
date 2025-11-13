import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/injection/injection.dart';
import '../../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../../data/datasources/remote/upload_remote_datasource.dart';
import '../../../data/models/barber_media_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/media/media_viewer_screen.dart';

class BarberMediaScreen extends StatefulWidget {
  const BarberMediaScreen({super.key});

  @override
  State<BarberMediaScreen> createState() => _BarberMediaScreenState();
}

class _BarberMediaScreenState extends State<BarberMediaScreen> {
  final BarberMediaRemoteDataSource _mediaDataSource = sl<BarberMediaRemoteDataSource>();
  final UploadRemoteDataSource _uploadDataSource = sl<UploadRemoteDataSource>();
  final ImagePicker _imagePicker = ImagePicker();
  List<BarberMediaModel> _media = [];
  bool _isLoading = false;
  String? _barberId;

  @override
  void initState() {
    super.initState();
    _loadBarberId();
  }

  Future<void> _loadBarberId() async {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is! AuthAuthenticated) return;

    try {
      final dio = sl<Dio>();
      final response = await dio.get('${AppConstants.baseUrl}/api/barbers');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final userEmail = currentState.user.email;
        final matchingBarbers = data.where(
          (b) => b['email'] == userEmail,
        ).toList();

        if (matchingBarbers.isNotEmpty && mounted) {
          setState(() {
            _barberId = matchingBarbers.first['id'] as String;
          });
          _loadMedia();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar información: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadMedia() async {
    if (_barberId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final media = await _mediaDataSource.getBarberMedia(_barberId!);
      if (mounted) {
        setState(() {
          _media = media;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar multimedia: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && _barberId != null) {
        await _uploadAndCreateMedia(File(pickedFile.path), 'IMAGE');
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

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (pickedFile != null && _barberId != null) {
        await _uploadAndCreateMedia(File(pickedFile.path), 'VIDEO');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar video: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadAndCreateMedia(File file, String type) async {
    if (_barberId == null) return;

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subiendo archivo...'),
            backgroundColor: AppColors.primaryGold,
          ),
        );
      }

      // Upload file
      final fileUrl = await _uploadDataSource.uploadFile(file);

      // Create media entry
      await _mediaDataSource.createMedia(
        _barberId!,
        type: type,
        url: fileUrl,
      );

      // Reload media list
      await _loadMedia();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Multimedia agregada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir multimedia: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showAddMediaOptions() async {
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
              'Agregar Multimedia',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryGold),
              title: const Text('Galería', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Seleccionar imagen o video', style: TextStyle(color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _showMediaSourceSelector();
              },
            ),
            Divider(color: AppColors.borderGold),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryGold),
              title: const Text('Cámara', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Tomar foto o grabar video', style: TextStyle(color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _showCameraOptions();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showMediaSourceSelector() async {
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
              'Seleccionar desde Galería',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryGold),
              title: const Text('Imagen', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            Divider(color: AppColors.borderGold),
            ListTile(
              leading: const Icon(Icons.video_library, color: AppColors.primaryGold),
              title: const Text('Video', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showCameraOptions() async {
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
              'Usar Cámara',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryGold),
              title: const Text('Tomar Foto', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            Divider(color: AppColors.borderGold),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.primaryGold),
              title: const Text('Grabar Video', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMedia(BarberMediaModel media) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Eliminar Multimedia',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este elemento?',
          style: TextStyle(color: AppColors.textSecondary),
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

    if (confirmed == true) {
      try {
        await _mediaDataSource.deleteMedia(media.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Multimedia eliminada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadMedia();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar multimedia: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditCaptionModal(BarberMediaModel media) async {
    final controller = TextEditingController(text: media.caption ?? '');
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editar Descripción',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: controller,
              label: 'Descripción (Opcional)',
              hint: 'Añade una descripción a esta imagen/video',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Guardar',
              onPressed: () async {
                final caption = controller.text.trim();
                
                try {
                  await _mediaDataSource.updateMedia(
                    media.id,
                    caption: caption.isEmpty ? null : caption,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    await _loadMedia();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Descripción actualizada exitosamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
          'Mi Multimedia',
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
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGold,
                ),
              )
            : _barberId == null
                ? const Center(
                    child: Text(
                      'No se pudo cargar la información del barbero',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : _media.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tienes multimedia registrada',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Agrega fotos y videos de tu trabajo',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMedia,
                        color: AppColors.primaryGold,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _media.length,
                          itemBuilder: (context, index) {
                            final media = _media[index];
                            return _buildMediaCard(media);
                          },
                        ),
                      ),
      ),
      floatingActionButton: _barberId != null
          ? FloatingActionButton.extended(
              onPressed: _showAddMediaOptions,
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.add, color: AppColors.textDark),
              label: const Text(
                'Agregar',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMediaCard(BarberMediaModel media) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaViewerScreen(
                mediaList: _media,
                initialIndex: _media.indexOf(media),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (media.type == 'IMAGE')
                    CachedNetworkImage(
                      imageUrl: AppConstants.buildImageUrl(media.url),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.backgroundCardDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.backgroundCardDark,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                      ),
                    )
                  else
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: AppConstants.buildImageUrl(media.thumbnail ?? media.url),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundCardDark,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundCardDark,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppColors.textSecondary,
                              size: 40,
                            ),
                          ),
                        ),
                                                 Container(
                           color: Colors.black.withValues(alpha: 0.3),
                           child: const Center(
                             child: Icon(
                               Icons.play_circle_filled,
                               color: Colors.white,
                               size: 48,
                             ),
                           ),
                         ),
                      ],
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      color: AppColors.backgroundCard,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCaptionModal(media);
                        } else if (value == 'delete') {
                          _deleteMedia(media);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppColors.textPrimary, size: 20),
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
                  ),
                ],
              ),
            ),
            if (media.caption != null && media.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  media.caption!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
