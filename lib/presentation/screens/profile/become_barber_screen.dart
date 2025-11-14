import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../../data/datasources/remote/specialty_remote_datasource.dart';
import '../../../data/models/specialty_model.dart';
import '../../../data/datasources/remote/workplace_remote_datasource.dart';
import '../../../data/models/workplace_model.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../data/datasources/remote/barber_media_remote_datasource.dart';
import '../../../data/datasources/remote/upload_remote_datasource.dart';
import '../../../data/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/datasources/local/local_storage.dart';
import '../../../core/utils/logger.dart';
import 'dart:convert';

class BecomeBarberScreen extends StatefulWidget {
  const BecomeBarberScreen({super.key});

  @override
  State<BecomeBarberScreen> createState() => _BecomeBarberScreenState();
}

class _BecomeBarberScreenState extends State<BecomeBarberScreen> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  int _currentStep = 1;

  // Step 1 fields
  SpecialtyModel? _selectedSpecialty;
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();

  List<SpecialtyModel> _specialties = [];
  bool _loadingSpecialties = true;
  String? _specialtiesError;

  // Step 2 fields
  WorkplaceModel? _selectedWorkplace;
  String? _selectedServiceType;
  List<WorkplaceModel> _workplaces = [];
  bool _loadingWorkplaces = true;
  String? _workplacesError;

  // Services management
  final List<Map<String, dynamic>> _services = [];
  final _serviceNameController = TextEditingController();
  final _servicePriceController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _serviceIncludesController = TextEditingController();

  String? _barberId;

  // Step 3 fields
  final List<Map<String, dynamic>> _portfolioMedia = [];
  final _mediaCaptionController = TextEditingController();
  String? _selectedMediaType;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedFile;
  String? _selectedFileUrl;
  bool _uploadingFile = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
    _loadWorkplaces();
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _locationController.dispose();
    _serviceNameController.dispose();
    _servicePriceController.dispose();
    _serviceDescriptionController.dispose();
    _serviceIncludesController.dispose();
    _mediaCaptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    try {
      setState(() {
        _loadingSpecialties = true;
        _specialtiesError = null;
      });

      final specialties = await sl<SpecialtyRemoteDataSource>()
          .getSpecialties();

      setState(() {
        _specialties = specialties;
        _loadingSpecialties = false;
      });
    } catch (e) {
      setState(() {
        _specialtiesError = e.toString();
        _loadingSpecialties = false;
      });
    }
  }

  Future<void> _loadWorkplaces() async {
    try {
      setState(() {
        _loadingWorkplaces = true;
        _workplacesError = null;
      });

      final workplaces = await sl<WorkplaceRemoteDataSource>().getWorkplaces();

      setState(() {
        _workplaces = workplaces;
        _loadingWorkplaces = false;
      });
    } catch (e) {
      setState(() {
        _workplacesError = e.toString();
        _loadingWorkplaces = false;
      });
    }
  }

  void _handleNextStep1() {
    if (_formKeyStep1.currentState!.validate()) {
      if (_selectedSpecialty == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una especialidad'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _handleSubmitStep1();
    }
  }

  Future<void> _handleSubmitStep1() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    if (_selectedSpecialty == null) return;

    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is! AuthAuthenticated) return;

    final experienceYears = int.tryParse(_experienceController.text.trim());
    if (experienceYears == null || experienceYears < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor ingresa un número válido de años de experiencia',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final authDataSource = sl<AuthRemoteDataSource>();
      final result = await authDataSource.becomeBarber(
        specialtyId: _selectedSpecialty!.id,
        specialty: _selectedSpecialty!.name,
        experienceYears: experienceYears,
        location: _locationController.text.trim(),
        latitude: null,
        longitude: null,
        image: currentState.user.avatar,
      );

      final updatedUser = result['user'] as UserModel;
      final barberId = result['barberId'] as String;

      // Save updated user to cache
      final localStorage = sl<LocalStorage>();
      await localStorage.saveUserData(jsonEncode(updatedUser.toJson()));

      // Update user in cubit by reloading from cache
      await authCubit.init();

      setState(() {
        _barberId = barberId;
        _currentStep = 2;
      });
      // Removed success message - no message when moving to step 2
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _addService() {
    if (_serviceNameController.text.trim().isEmpty ||
        _servicePriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y precio son requeridos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = double.tryParse(_servicePriceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio debe ser un número válido mayor a 0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _services.add({
        'name': _serviceNameController.text.trim(),
        'price': price,
        'description': _serviceDescriptionController.text.trim().isEmpty
            ? null
            : _serviceDescriptionController.text.trim(),
        'includes': _serviceIncludesController.text.trim().isEmpty
            ? null
            : _serviceIncludesController.text.trim(),
      });

      _serviceNameController.clear();
      _servicePriceController.clear();
      _serviceDescriptionController.clear();
      _serviceIncludesController.clear();
    });
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedMediaType = 'IMAGE';
          _selectedFileUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedMediaType = 'VIDEO';
          _selectedFileUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar video: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un archivo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _uploadingFile = true;
    });

    try {
      final uploadDataSource = sl<UploadRemoteDataSource>();
      final fileUrl = await uploadDataSource.uploadFile(_selectedFile!);

      setState(() {
        _selectedFileUrl = fileUrl;
        _uploadingFile = false;
      });
    } catch (e) {
      setState(() {
        _uploadingFile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir archivo: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _addMedia() {
    if (_selectedFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor sube el archivo primero'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMediaType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de medio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _portfolioMedia.add({
        'type': _selectedMediaType,
        'url': _selectedFileUrl,
        'caption': _mediaCaptionController.text.trim().isEmpty
            ? null
            : _mediaCaptionController.text.trim(),
      });

      _selectedFile = null;
      _selectedFileUrl = null;
      _selectedMediaType = null;
      _mediaCaptionController.clear();
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _portfolioMedia.removeAt(index);
    });
  }

  Future<void> _handleSubmitStep2() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos un servicio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_barberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de barbero no encontrado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final authDataSource = sl<AuthRemoteDataSource>();
      final serviceDataSource = sl<ServiceRemoteDataSource>();

      await authDataSource.updateBarberStep2(
        workplaceId: _selectedWorkplace?.id,
        serviceType: _selectedServiceType,
      );

      await serviceDataSource.createMultipleServices(_barberId!, _services);

      setState(() {
        _currentStep = 3;
      });
      // Removed success message - no message when moving to step 3
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Convertirse en Barbero',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: _currentStep == 1
                    ? _buildStep1()
                    : _currentStep == 2
                    ? _buildStep2()
                    : _buildStep3(),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 1
                    ? AppColors.primaryGold
                    : AppColors.borderGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 2
                    ? AppColors.primaryGold
                    : AppColors.borderGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 3
                    ? AppColors.primaryGold
                    : AppColors.borderGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    if (_loadingSpecialties) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (_specialtiesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar especialidades',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Reintentar',
              onPressed: _loadSpecialties,
              type: ButtonType.secondary,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paso 1: Información Básica',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completa la información básica de tu perfil como barbero',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            AppDropdown<SpecialtyModel>(
              label: 'Especialidad',
              hint: 'Selecciona tu especialidad',
              value: _selectedSpecialty,
              items: _specialties.map((specialty) {
                return DropdownMenuItem<SpecialtyModel>(
                  value: specialty,
                  child: Text(
                    specialty.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecialty = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'La especialidad es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _experienceController,
              label: 'Años de Experiencia',
              hint: 'Ej: 5',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los años de experiencia son requeridos';
                }
                final years = int.tryParse(value.trim());
                if (years == null || years < 0) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              label: 'Ubicación',
              hint: 'Ej: Caracas, Distrito Capital',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La ubicación es requerida';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    if (_loadingWorkplaces) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paso 2: Lugar de Trabajo y Servicios',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configura tu lugar de trabajo y los servicios que ofreces',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            AppDropdown<WorkplaceModel>(
              label: 'Lugar de Trabajo (Opcional)',
              hint: 'Selecciona un lugar de trabajo',
              value: _selectedWorkplace,
              items: [
                const DropdownMenuItem<WorkplaceModel>(
                  value: null,
                  child: Text(
                    'Ninguno',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                ..._workplaces.map((workplace) {
                  return DropdownMenuItem<WorkplaceModel>(
                    value: workplace,
                    child: Text(
                      workplace.city != null
                          ? '${workplace.name} - ${workplace.city}'
                          : workplace.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWorkplace = value;
                });
              },
            ),
            const SizedBox(height: 16),
            AppDropdown<String>(
              label: 'Tipo de Servicio',
              hint: 'Selecciona el tipo de servicio',
              value: _selectedServiceType,
              items: const [
                DropdownMenuItem<String>(
                  value: 'LOCAL_ONLY',
                  child: Text(
                    'Solo en local',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'HOME_SERVICE',
                  child: Text(
                    'Servicio a domicilio',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'BOTH',
                  child: Text(
                    'Ambos',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedServiceType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'El tipo de servicio es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Servicios',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _serviceNameController,
              label: 'Nombre del Servicio',
              hint: 'Ej: Corte Clásico',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _servicePriceController,
              label: 'Precio',
              hint: 'Ej: 25.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _serviceDescriptionController,
              label: 'Descripción (Opcional)',
              hint: 'Describe el servicio',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _serviceIncludesController,
              label: 'Qué incluye (Opcional)',
              hint: 'Ej: Corte, afeitado, peinado',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Agregar',
              onPressed: _addService,
              type: ButtonType.secondary,
            ),
            const SizedBox(height: 24),
            if (_services.isNotEmpty) ...[
              const Text(
                'Servicios Agregados',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_services.length, (index) {
                final service = _services[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r'$' + service['price'].toStringAsFixed(2),
                              style: const TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 14,
                              ),
                            ),
                            if (service['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                service['description'],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _removeService(index),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paso 3: Portfolio',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comparte fotos, videos y gifs de tu trabajo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '📷 Galería',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.backgroundCardDark,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.photo_library,
                                  color: AppColors.primaryGold,
                                ),
                                title: const Text(
                                  'Seleccionar Imagen',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.video_library,
                                  color: AppColors.primaryGold,
                                ),
                                title: const Text(
                                  'Seleccionar Video',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickVideo(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: '📸 Cámara',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.backgroundCardDark,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primaryGold,
                                ),
                                title: const Text(
                                  'Tomar Foto',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.videocam,
                                  color: AppColors.primaryGold,
                                ),
                                title: const Text(
                                  'Grabar Video',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickVideo(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    type: ButtonType.secondary,
                  ),
                ),
              ],
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 24),
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedMediaType == 'IMAGE'
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _selectedFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.backgroundCardDark,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: AppColors.textSecondary,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: AppColors.backgroundCardDark,
                              child: const Center(
                                child: Icon(
                                  Icons.video_library,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedFileUrl == null)
                AppButton(
                  text: _uploadingFile ? 'Subiendo...' : 'Subir Archivo',
                  onPressed: _uploadingFile ? null : _uploadFile,
                ),
            ],
            if (_selectedFileUrl != null) ...[const SizedBox(height: 16)],
            const SizedBox(height: 16),
            AppTextField(
              controller: _mediaCaptionController,
              label: 'Descripción (Opcional)',
              hint: 'Describe este trabajo',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Agregar al Portfolio',
              onPressed: _addMedia,
              type: ButtonType.secondary,
            ),
            const SizedBox(height: 24),
            if (_portfolioMedia.isNotEmpty) ...[
              const Text(
                'Medios Agregados',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_portfolioMedia.length, (index) {
                final media = _portfolioMedia[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              media['type'] == 'IMAGE'
                                  ? 'Imagen'
                                  : media['type'] == 'VIDEO'
                                  ? 'Video'
                                  : 'GIF',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (media['type'] == 'IMAGE')
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.borderGold,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: media['url'] != null
                                      ? CachedNetworkImage(
                                          imageUrl: media['url'].toString(),
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 80,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: AppColors
                                                    .backgroundCardDark,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: AppColors
                                                            .primaryGold,
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: AppColors
                                                    .backgroundCardDark,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: 32,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: AppColors.backgroundCardDark,
                                          child: const Icon(
                                            Icons.image,
                                            color: AppColors.textSecondary,
                                            size: 32,
                                          ),
                                        ),
                                ),
                              )
                            else
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundCardDark,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.borderGold,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_circle_filled,
                                  color: AppColors.primaryGold,
                                  size: 32,
                                ),
                              ),
                            if (media['caption'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                media['caption'],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _removeMedia(index),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitStep3() async {
    if (_barberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de barbero no encontrado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final mediaDataSource = sl<BarberMediaRemoteDataSource>();

      if (_portfolioMedia.isNotEmpty) {
        await mediaDataSource.createMultipleMedia(_barberId!, _portfolioMedia);
      }

      // Refresh user data from backend by calling /api/auth/me
      final authDataSource = sl<AuthRemoteDataSource>();
      try {
        final updatedUser = await authDataSource.getCurrentUser();
        final localStorage = sl<LocalStorage>();
        await localStorage.saveUserData(jsonEncode(updatedUser.toJson()));
      } catch (e) {
        // If fetching from backend fails, just reload from cache
        appLogger.w('Failed to fetch user from backend: $e');
      }

      final authCubit = context.read<AuthCubit>();
      await authCubit.init();

      if (mounted) {
        // Show success message and navigate back to profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Te has convertido en barbero exitosamente!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to profile - use go instead of pop to ensure we go to profile
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: _currentStep == 1 ? 'Cancelar' : 'Atrás',
              onPressed: () {
                if (_currentStep == 1) {
                  context.pop();
                } else {
                  setState(() {
                    _currentStep--;
                  });
                }
              },
              type: ButtonType.outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: _currentStep == 1
                  ? 'Siguiente'
                  : _currentStep == 2
                  ? 'Siguiente'
                  : 'Completar',
              onPressed: _currentStep == 1
                  ? _handleNextStep1
                  : _currentStep == 2
                  ? _handleSubmitStep2
                  : _handleSubmitStep3,
            ),
          ),
        ],
      ),
    );
  }
}
