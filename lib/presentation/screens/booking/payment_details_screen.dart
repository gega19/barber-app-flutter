import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../data/datasources/remote/upload_remote_datasource.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import 'package:intl/intl.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final PaymentMethodEntity paymentMethod;
  final String barberId;
  final String? serviceId;
  final DateTime date;
  final String time;
  final double price;

  const PaymentDetailsScreen({
    super.key,
    required this.paymentMethod,
    required this.barberId,
    this.serviceId,
    required this.date,
    required this.time,
    required this.price,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final UploadRemoteDataSource _uploadDataSource = sl<UploadRemoteDataSource>();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedProof;
  bool _isUploading = false;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundCardDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Detalles de Pago',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Method Info
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (widget.paymentMethod.icon != null)
                                  Text(
                                    widget.paymentMethod.icon!,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                if (widget.paymentMethod.icon != null)
                                  const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.paymentMethod.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Información de pago',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentDetails(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Appointment Summary
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de la cita',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow('Fecha', DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(widget.date), Icons.calendar_today),
                            const SizedBox(height: 12),
                            _buildSummaryRow('Hora', widget.time, Icons.access_time),
                            const SizedBox(height: 12),
                            _buildSummaryRow('Total', '\$${widget.price.toStringAsFixed(2)}', Icons.attach_money),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Payment Proof Section
                      Text(
                        'Comprobante de pago',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sube una imagen del comprobante de tu pago',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedProof != null)
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedProof!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppButton(
                                    text: 'Cambiar imagen',
                                    onPressed: _isUploading ? null : _pickImage,
                                    type: ButtonType.secondary,
                                    width: 120,
                                  ),
                                  const SizedBox(width: 12),
                                  AppButton(
                                    text: 'Eliminar',
                                    onPressed: _isUploading
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedProof = null;
                                            });
                                          },
                                    type: ButtonType.secondary,
                                    width: 120,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        InkWell(
                          onTap: _isUploading ? null : _pickImage,
                          borderRadius: BorderRadius.circular(12),
                          child: AppCard(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Toca para seleccionar imagen',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: _isCreating ? 'Creando cita...' : 'Confirmar cita',
                          onPressed: (_isUploading || _isCreating) ? null : _confirmAppointment,
                          isLoading: _isCreating,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    final config = widget.paymentMethod.config;
    if (config == null || config.isEmpty) {
      return Text(
        'No hay información adicional disponible',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      );
    }

    final type = widget.paymentMethod.type?.toUpperCase() ?? '';

    if (type == 'PAGO_MOVIL') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config['bank'] != null)
            _buildDetailItem('Banco', config['bank'] as String),
          if (config['phone'] != null)
            _buildDetailItem('Teléfono', config['phone'] as String),
          if (config['id'] != null)
            _buildDetailItem('Cédula', config['id'] as String),
        ],
      );
    } else if (type == 'BINANCE') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config['wallet'] != null)
            _buildDetailItem('Wallet', config['wallet'] as String),
          if (config['network'] != null)
            _buildDetailItem('Red', config['network'] as String),
        ],
      );
    } else if (type == 'TRANSFERENCIA') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config['bank'] != null)
            _buildDetailItem('Banco', config['bank'] as String),
          if (config['account'] != null)
            _buildDetailItem('Cuenta', config['account'] as String),
          if (config['accountType'] != null)
            _buildDetailItem('Tipo de cuenta', config['accountType'] as String),
        ],
      );
    }

    // Generic display for any other config
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: config.entries.map((entry) {
        return _buildDetailItem(
          entry.key.toString().replaceAll('_', ' ').toUpperCase(),
          entry.value.toString(),
        );
      }).toList(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedProof = File(pickedFile.path);
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

  Future<void> _confirmAppointment() async {
    if (_selectedProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor sube un comprobante de pago'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload proof
      final proofUrl = await _uploadDataSource.uploadFile(_selectedProof!);
      
      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _isCreating = true;
      });

      // Return to booking screen with proof URL
      if (mounted) {
        context.pop(proofUrl);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir comprobante: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

