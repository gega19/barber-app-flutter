import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Diálogo para confirmar eliminación de cuenta
class DeleteAccountDialog extends StatefulWidget {
  final Future<bool> Function(String password) onDelete;

  const DeleteAccountDialog({
    super.key,
    required this.onDelete,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: const Text(
        'Eliminar Cuenta',
        style: TextStyle(color: AppColors.error),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta acción eliminará permanentemente tu historial, reseñas y perfil. No podrás recuperar estos datos después.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Confirma tu contraseña',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderGold),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryGold),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _isDeleting
              ? null
              : () async {
                  final password = _passwordController.text.trim();
                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa tu contraseña para continuar'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _isDeleting = true;
                  });

                  final success = await widget.onDelete(password);

                  if (!mounted) return;

                  if (success) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      _isDeleting = false;
                    });
                  }
                },
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              : const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
        ),
      ],
    );
  }
}

