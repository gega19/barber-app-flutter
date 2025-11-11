import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/injection/injection.dart';
import '../../../data/datasources/remote/service_remote_datasource.dart';
import '../../../data/models/service_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../cubit/auth/auth_cubit.dart';

class BarberServicesScreen extends StatefulWidget {
  const BarberServicesScreen({super.key});

  @override
  State<BarberServicesScreen> createState() => _BarberServicesScreenState();
}

class _BarberServicesScreenState extends State<BarberServicesScreen> {
  final ServiceRemoteDataSource _serviceDataSource = sl<ServiceRemoteDataSource>();
  List<ServiceModel> _services = [];
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
          _loadServices();
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

  Future<void> _loadServices() async {
    if (_barberId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _serviceDataSource.getBarberServices(_barberId!);
      if (mounted) {
        setState(() {
          _services = services;
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
            content: Text('Error al cargar servicios: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showServiceForm({ServiceModel? service}) async {
    final result = await showModalBottomSheet<ServiceModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ServiceFormModal(
        service: service,
        barberId: _barberId!,
      ),
    );

    if (result != null && mounted) {
      _loadServices();
    }
  }

  Future<void> _deleteService(ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Eliminar Servicio',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${service.name}"?',
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

    if (confirmed == true) {
      try {
        await _serviceDataSource.deleteService(service.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio eliminado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadServices();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar servicio: ${e.toString()}'),
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
          'Mis Servicios',
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
                : _services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.content_cut_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tienes servicios registrados',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Agrega tu primer servicio',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadServices,
                        color: AppColors.primaryGold,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return _buildServiceCard(service);
                          },
                        ),
                      ),
      ),
      floatingActionButton: _barberId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showServiceForm(),
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.add, color: AppColors.textDark),
              label: const Text(
                'Agregar Servicio',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
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
                      service.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    _showServiceForm(service: service);
                  } else if (value == 'delete') {
                    _deleteService(service);
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
            ],
          ),
          if (service.description != null && service.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              service.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          if (service.includes != null && service.includes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.includes!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceFormModal extends StatefulWidget {
  final ServiceModel? service;
  final String barberId;

  const _ServiceFormModal({
    this.service,
    required this.barberId,
  });

  @override
  State<_ServiceFormModal> createState() => _ServiceFormModalState();
}

class _ServiceFormModalState extends State<_ServiceFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _includesController = TextEditingController();
  bool _isLoading = false;
  final ServiceRemoteDataSource _serviceDataSource = sl<ServiceRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _priceController.text = widget.service!.price.toStringAsFixed(2);
      _descriptionController.text = widget.service!.description ?? '';
      _includesController.text = widget.service!.includes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _includesController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text.trim());
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final includes = _includesController.text.trim().isEmpty
          ? null
          : _includesController.text.trim();

      if (price == null) {
        throw Exception('El precio debe ser un número válido');
      }

      if (widget.service == null) {
        await _serviceDataSource.createService(
          widget.barberId,
          name: name,
          price: price,
          description: description,
          includes: includes,
        );
      } else {
        await _serviceDataSource.updateService(
          widget.service!.id,
          name: name,
          price: price,
          description: description,
          includes: includes,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(widget.service ?? ServiceModel(
          id: '',
          barberId: widget.barberId,
          name: name,
          price: price,
          description: description,
          includes: includes,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar servicio: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.service == null ? 'Nuevo Servicio' : 'Editar Servicio',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _nameController,
              label: 'Nombre del Servicio',
              hint: 'Ej: Corte de cabello',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _priceController,
              label: 'Precio',
              hint: 'Ej: 25.00',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio es requerido';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Ingresa un precio válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descriptionController,
              label: 'Descripción (Opcional)',
              hint: 'Describe el servicio',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _includesController,
              label: 'Qué incluye (Opcional)',
              hint: 'Ej: Corte, peinado y barba',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: widget.service == null ? 'Crear Servicio' : 'Guardar Cambios',
              onPressed: _isLoading ? null : _saveService,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
