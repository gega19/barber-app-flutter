import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/injection/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../data/datasources/remote/barber_remote_datasource.dart';
import '../../utils/location_error_dialog.dart';
import '../map/location_map_picker_screen.dart';
import '../../../data/datasources/remote/specialty_remote_datasource.dart';
import '../../../data/models/specialty_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../cubit/auth/auth_cubit.dart';

class BarberInfoScreen extends StatefulWidget {
  const BarberInfoScreen({super.key});

  @override
  State<BarberInfoScreen> createState() => _BarberInfoScreenState();
}

class _BarberInfoScreenState extends State<BarberInfoScreen> {
  final BarberRemoteDataSource _barberDataSource = sl<BarberRemoteDataSource>();
  final SpecialtyRemoteDataSource _specialtyDataSource =
      sl<SpecialtyRemoteDataSource>();
  final LocationService _locationService = sl<LocationService>();

  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();

  SpecialtyModel? _selectedSpecialty;
  List<SpecialtyModel> _specialties = [];
  bool _isLoading = false;
  bool _loadingSpecialties = true;
  bool _isSaving = false;
  bool _loadingLocation = false;
  String? _barberEmail;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _locationController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is! AuthAuthenticated) return;

    setState(() {
      _isLoading = true;
      _barberEmail = currentState.user.email;
    });

    try {
      await Future.wait([_loadSpecialties(), _loadBarberInfo()]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSpecialties() async {
    try {
      final specialties = await _specialtyDataSource.getSpecialties();
      if (mounted) {
        setState(() {
          _specialties = specialties;
          _loadingSpecialties = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSpecialties = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar especialidades: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadBarberInfo() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get('${AppConstants.baseUrl}/api/barbers');

      if (response.statusCode == 200 && mounted) {
        final data = response.data['data'] as List;
        final matchingBarbers = data
            .where((b) => b['email'] == _barberEmail)
            .toList();

        if (matchingBarbers.isNotEmpty) {
          final barberData = matchingBarbers.first as Map<String, dynamic>;
          setState(() {
            _experienceController.text = (barberData['experienceYears'] ?? 0)
                .toString();
            _locationController.text = barberData['location'] ?? '';
            _latitude = barberData['latitude'] != null
                ? (barberData['latitude'] as num).toDouble()
                : null;
            _longitude = barberData['longitude'] != null
                ? (barberData['longitude'] as num).toDouble()
                : null;
            _instagramController.text = barberData['instagramUrl'] ?? '';
            _tiktokController.text = barberData['tiktokUrl'] ?? '';

            final specialtyName = barberData['specialty'] as String?;
            if (specialtyName != null && _specialties.isNotEmpty) {
              try {
                _selectedSpecialty = _specialties.firstWhere(
                  (s) => s.name == specialtyName,
                );
              } catch (_) {
                if (_specialties.isNotEmpty) {
                  _selectedSpecialty = _specialties.first;
                }
              }
            } else if (_specialties.isNotEmpty) {
              _selectedSpecialty = _specialties.first;
            }
          });
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

  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una especialidad'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _barberDataSource.updateBarberInfo(
        specialty: _selectedSpecialty!.name,
        specialtyId: _selectedSpecialty!.id,
        experienceYears: int.parse(_experienceController.text.trim()),
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        instagramUrl: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        tiktokUrl: _tiktokController.text.trim().isEmpty
            ? null
            : _tiktokController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información actualizada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
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
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });
    final result = await _locationService.getCurrentLocationWithResult();
    if (!mounted) return;
    setState(() {
      _loadingLocation = false;
    });
    if (result.isSuccess) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        if (_locationController.text.trim().isEmpty) {
          _locationController.text = 'Mi ubicación';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ubicación actual guardada. Ajusta el texto si lo deseas.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      showLocationErrorDialog(context, result.error!);
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute<LocationPickerResult>(
        builder: (context) => LocationMapPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
          initialAddress: _locationController.text,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _locationController.text = result.address;
      });
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
          'Información Profesional',
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Especialidad',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _loadingSpecialties
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold,
                                    ),
                                  )
                                : AppDropdown<SpecialtyModel>(
                                    value: _selectedSpecialty,
                                    items: _specialties
                                        .map(
                                          (specialty) => DropdownMenuItem(
                                            value: specialty,
                                            child: Text(
                                              specialty.name,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSpecialty = value;
                                      });
                                    },
                                    hint: 'Selecciona una especialidad',
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: _experienceController,
                              label: 'Años de Experiencia',
                              hint: 'Ej: 5',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                final years = int.tryParse(value.trim());
                                if (years == null || years < 0) {
                                  return 'Ingresa un número válido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: _locationController,
                              label: 'Ubicación',
                              hint: 'Ej: Caracas, Distrito Capital',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _loadingLocation
                                        ? null
                                        : _useCurrentLocation,
                                    icon: _loadingLocation
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primaryGold,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.my_location,
                                            size: 18,
                                            color: AppColors.primaryGold,
                                          ),
                                    label: Text(
                                      _loadingLocation
                                          ? 'Obteniendo...'
                                          : 'Mi ubicación',
                                      style: const TextStyle(
                                        color: AppColors.primaryGold,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _openMapPicker,
                                    icon: const Icon(
                                      Icons.map_outlined,
                                      size: 18,
                                      color: AppColors.primaryGold,
                                    ),
                                    label: const Text(
                                      'Elegir en mapa',
                                      style: TextStyle(
                                        color: AppColors.primaryGold,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_latitude != null && _longitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Coordenadas: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Redes Sociales',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _instagramController,
                              label: 'Instagram',
                              hint: '@usuario o https://instagram.com/usuario',
                              prefixIcon: Icons.camera_alt,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final trimmed = value.trim();
                                  // Validar que sea un formato válido (URL o @usuario)
                                  if (!trimmed.startsWith('@') &&
                                      !trimmed.startsWith('http') &&
                                      !trimmed.contains('instagram.com')) {
                                    return 'Ingresa @usuario o una URL válida';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _tiktokController,
                              label: 'TikTok',
                              hint: '@usuario o https://tiktok.com/@usuario',
                              prefixIcon: Icons.music_note,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final trimmed = value.trim();
                                  // Validar que sea un formato válido (URL o @usuario)
                                  if (!trimmed.startsWith('@') &&
                                      !trimmed.startsWith('http') &&
                                      !trimmed.contains('tiktok.com')) {
                                    return 'Ingresa @usuario o una URL válida';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Puedes usar @usuario o la URL completa. El sistema normalizará automáticamente.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Guardar Cambios',
                        onPressed: _isSaving ? null : _saveInfo,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
