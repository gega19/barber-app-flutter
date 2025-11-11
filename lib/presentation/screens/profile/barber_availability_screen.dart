import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/barber_availability_entity.dart';
import '../../cubit/barber_availability/barber_availability_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class BarberAvailabilityScreen extends StatefulWidget {
  const BarberAvailabilityScreen({super.key});

  @override
  State<BarberAvailabilityScreen> createState() => _BarberAvailabilityScreenState();
}

class _BarberAvailabilityScreenState extends State<BarberAvailabilityScreen> {
  List<BarberAvailabilityEntity> _availability = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    context.read<BarberAvailabilityCubit>().loadMyAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mi Horario',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<BarberAvailabilityCubit, BarberAvailabilityState>(
        listener: (context, state) {
          if (state is BarberAvailabilityLoaded) {
            setState(() {
              _availability = List.from(state.availability);
              _hasChanges = false;
            });
          } else if (state is BarberAvailabilityUpdated) {
            setState(() {
              _availability = List.from(state.availability);
              _hasChanges = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Horario actualizado correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is BarberAvailabilityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BarberAvailabilityLoading || state is BarberAvailabilityInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            );
          }

          if (state is BarberAvailabilityError && _availability.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.5),
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
                      context.read<BarberAvailabilityCubit>().loadMyAvailability();
                    },
                  ),
                ],
              ),
            );
          }

          if (_availability.isEmpty) {
            return const Center(
              child: Text(
                'No hay disponibilidad configurada',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configura tus días y horarios disponibles',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._availability.map((day) => _buildDayCard(day)),
                    ],
                  ),
                ),
              ),
              if (_hasChanges)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    border: Border(
                      top: BorderSide(color: AppColors.borderGold, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancelar',
                          onPressed: () {
                            context.read<BarberAvailabilityCubit>().loadMyAvailability();
                          },
                          type: ButtonType.outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Guardar',
                          onPressed: _saveAvailability,
                          isLoading: state is BarberAvailabilityUpdating,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayCard(BarberAvailabilityEntity day) {
    final dayIndex = _availability.indexOf(day);
    final isAvailable = day.isAvailable;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.dayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _availability[dayIndex] = BarberAvailabilityEntity(
                        id: day.id,
                        barberId: day.barberId,
                        dayOfWeek: day.dayOfWeek,
                        startTime: day.startTime,
                        endTime: day.endTime,
                        isAvailable: value,
                        breakStart: day.breakStart,
                        breakEnd: day.breakEnd,
                      );
                      _hasChanges = true;
                    });
                  },
                  activeColor: AppColors.primaryGold,
                ),
              ],
            ),
            if (isAvailable) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Inicio',
                      value: day.startTime,
                      onChanged: (value) {
                        setState(() {
                          _availability[dayIndex] = BarberAvailabilityEntity(
                            id: day.id,
                            barberId: day.barberId,
                            dayOfWeek: day.dayOfWeek,
                            startTime: value,
                            endTime: day.endTime,
                            isAvailable: day.isAvailable,
                            breakStart: day.breakStart,
                            breakEnd: day.breakEnd,
                          );
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Fin',
                      value: day.endTime,
                      onChanged: (value) {
                        setState(() {
                          _availability[dayIndex] = BarberAvailabilityEntity(
                            id: day.id,
                            barberId: day.barberId,
                            dayOfWeek: day.dayOfWeek,
                            startTime: day.startTime,
                            endTime: value,
                            isAvailable: day.isAvailable,
                            breakStart: day.breakStart,
                            breakEnd: day.breakEnd,
                          );
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Hora de almuerzo (opcional)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Inicio break',
                      value: day.breakStart ?? '',
                      placeholder: 'Ej: 13:00',
                      onChanged: (value) {
                        setState(() {
                          _availability[dayIndex] = BarberAvailabilityEntity(
                            id: day.id,
                            barberId: day.barberId,
                            dayOfWeek: day.dayOfWeek,
                            startTime: day.startTime,
                            endTime: day.endTime,
                            isAvailable: day.isAvailable,
                            breakStart: value.isEmpty ? null : value,
                            breakEnd: day.breakEnd,
                          );
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Fin break',
                      value: day.breakEnd ?? '',
                      placeholder: 'Ej: 14:00',
                      onChanged: (value) {
                        setState(() {
                          _availability[dayIndex] = BarberAvailabilityEntity(
                            id: day.id,
                            barberId: day.barberId,
                            dayOfWeek: day.dayOfWeek,
                            startTime: day.startTime,
                            endTime: day.endTime,
                            isAvailable: day.isAvailable,
                            breakStart: day.breakStart,
                            breakEnd: value.isEmpty ? null : value,
                          );
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Día cerrado',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.backgroundCardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGold),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
            TimeTextInputFormatter(),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _saveAvailability() {
    final availabilityData = _availability.map((day) {
      return {
        'dayOfWeek': day.dayOfWeek,
        'startTime': day.startTime,
        'endTime': day.endTime,
        'isAvailable': day.isAvailable,
        'breakStart': day.breakStart,
        'breakEnd': day.breakEnd,
      };
    }).toList();

    context.read<BarberAvailabilityCubit>().updateMyAvailability(availabilityData);
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    // Solo permitir números y dos puntos
    if (!RegExp(r'^[0-9:]*$').hasMatch(text)) {
      return oldValue;
    }

    // Limitar longitud
    if (text.length > 5) {
      return oldValue;
    }

    // Auto-formatear con :
    if (text.length == 2 && !text.contains(':')) {
      return TextEditingValue(
        text: '$text:',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    return newValue;
  }
}

