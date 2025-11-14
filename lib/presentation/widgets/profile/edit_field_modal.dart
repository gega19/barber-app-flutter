import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/app_button.dart';

/// Modal para editar campos del perfil
class EditFieldModal extends StatefulWidget {
  final String label;
  final String fieldType;
  final String currentValue;
  final Function(String) onSave;

  const EditFieldModal({
    super.key,
    required this.label,
    required this.fieldType,
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<EditFieldModal> createState() => _EditFieldModalState();
}

class _EditFieldModalState extends State<EditFieldModal> {
  late TextEditingController _controller;
  late String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue == 'No configurado' ? '' : widget.currentValue,
    );
    _selectedGender = widget.currentValue != 'No configurado'
        ? widget.currentValue
        : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editar ${widget.label}',
                style: const TextStyle(
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
          if (widget.fieldType == 'gender') ...[
            const Text(
              'Seleccionar Género',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    'Masculino',
                    'Male',
                    _selectedGender,
                    (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption(
                    'Femenino',
                    'Female',
                    _selectedGender,
                    (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption(
                    'Otro',
                    'Other',
                    _selectedGender,
                    (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ] else
            TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
                ),
                fillColor: AppColors.backgroundCard,
                filled: true,
              ),
            ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Guardar',
            onPressed: () {
              final newValue = widget.fieldType == 'gender'
                  ? _selectedGender
                  : _controller.text.trim();

              if (newValue != null && newValue.isNotEmpty) {
                widget.onSave(newValue);
              }

              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
    String label,
    String value,
    String? selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.borderGold,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

