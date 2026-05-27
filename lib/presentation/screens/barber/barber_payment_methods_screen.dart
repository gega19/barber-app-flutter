import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../cubit/barber_payment_methods/barber_payment_methods_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class BarberPaymentMethodsScreen extends StatefulWidget {
  final String barberId;

  const BarberPaymentMethodsScreen({super.key, required this.barberId});

  @override
  State<BarberPaymentMethodsScreen> createState() =>
      _BarberPaymentMethodsScreenState();
}

class _BarberPaymentMethodsScreenState
    extends State<BarberPaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BarberPaymentMethodsCubit>().load(widget.barberId);
  }

  Future<void> _toggleMethod(
    PaymentMethodEntity method,
    bool enabled,
    bool isSaving,
  ) async {
    if (isSaving) return;
    await context.read<BarberPaymentMethodsCubit>().setActive(
      barberId: widget.barberId,
      id: method.id,
      isActive: enabled,
    );
  }

  Future<void> _confirmDelete(PaymentMethodEntity method) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar método',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '«${method.name}» se borrará por completo y no podrás recuperarlo. '
          'Para ocultarlo al reservar sin borrarlo, usa el interruptor.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await context.read<BarberPaymentMethodsCubit>().delete(
      barberId: widget.barberId,
      id: method.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«${method.name}» eliminado permanentemente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showMethodActions(PaymentMethodEntity method) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  method.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryGold,
              ),
              title: const Text(
                'Editar',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openEditor(method: method);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(method);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor({PaymentMethodEntity? method}) async {
    final cubit = context.read<BarberPaymentMethodsCubit>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _PaymentMethodEditorSheet(
          barberId: widget.barberId,
          method: method,
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            method == null ? 'Método agregado' : 'Cambios guardados',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: const Text(
          'Métodos de pago',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () =>
                context.read<BarberPaymentMethodsCubit>().load(widget.barberId),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: BlocConsumer<BarberPaymentMethodsCubit, BarberPaymentMethodsState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              );
            }

            final active = state.methods.where((m) => m.isActive).toList();
            final inactive = state.methods.where((m) => !m.isActive).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                Text(
                  'Activa los métodos que aceptas. Solo los activos aparecen al reservar.',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                if (active.isNotEmpty) ...[
                  const _SectionLabel('Disponibles para clientes'),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < active.length; i++) ...[
                          if (i > 0)
                            Divider(height: 1, color: AppColors.borderGold),
                          _PaymentMethodTile(
                            method: active[i],
                            isSaving: state.isSaving,
                            onToggle: (v) =>
                                _toggleMethod(active[i], v, state.isSaving),
                            onEdit: () => _openEditor(method: active[i]),
                            onMore: () => _showMethodActions(active[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else
                  const _EmptyBlock(message: 'No tienes métodos activos.'),
                if (inactive.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const _SectionLabel('Desactivados'),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < inactive.length; i++) ...[
                          if (i > 0)
                            Divider(height: 1, color: AppColors.borderGold),
                          _PaymentMethodTile(
                            method: inactive[i],
                            muted: true,
                            isSaving: state.isSaving,
                            onToggle: (v) =>
                                _toggleMethod(inactive[i], v, state.isSaving),
                            onEdit: () => _openEditor(method: inactive[i]),
                            onMore: () => _showMethodActions(inactive[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        elevation: 2,
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Agregar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PaymentMethodEditorSheet extends StatefulWidget {
  final String barberId;
  final PaymentMethodEntity? method;

  const _PaymentMethodEditorSheet({required this.barberId, this.method});

  @override
  State<_PaymentMethodEditorSheet> createState() =>
      _PaymentMethodEditorSheetState();
}

class _PaymentMethodEditorSheetState extends State<_PaymentMethodEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _instructionsController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.method?.name ?? '');
    _instructionsController = TextEditingController(
      text: widget.method?.config?['instructions']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);

    final ok = await context.read<BarberPaymentMethodsCubit>().save(
      barberId: widget.barberId,
      id: widget.method?.id,
      name: name,
      icon: widget.method?.icon,
      config: {'instructions': _instructionsController.text.trim()},
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.method == null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isNew ? 'Nuevo método' : 'Editar método',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Nombre e instrucciones que verá el cliente al pagar.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _EditorField(
                label: 'Nombre',
                controller: _nameController,
                hint: 'Ej. Pago móvil, Efectivo',
              ),
              const SizedBox(height: 16),
              _EditorField(
                label: 'Instrucciones (opcional)',
                controller: _instructionsController,
                hint: 'Datos de cuenta, teléfono, etc.',
                maxLines: 4,
              ),
              const SizedBox(height: 28),
              AppButton(
                text: 'Guardar',
                isLoading: _saving,
                width: double.infinity,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethodEntity method;
  final bool muted;
  final bool isSaving;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  const _PaymentMethodTile({
    required this.method,
    this.muted = false,
    required this.isSaving,
    required this.onToggle,
    required this.onEdit,
    required this.onMore,
  });

  static IconData _iconFor(PaymentMethodEntity m) {
    final cat = m.config?['category']?.toString() ?? '';
    switch (cat) {
      case 'CASH':
        return Icons.payments_outlined;
      case 'PAGO_MOVIL':
        return Icons.phone_android_outlined;
      case 'TRANSFER':
      case 'BANK_TRANSFER':
        return Icons.account_balance_outlined;
      default:
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final instructions = method.config?['instructions']?.toString().trim();
    final titleColor = muted ? AppColors.textSecondary : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 4, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(
                            alpha: muted ? 0.08 : 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconFor(method),
                          size: 22,
                          color: muted
                              ? AppColors.textSecondary
                              : AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.name,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (instructions != null &&
                                instructions.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                instructions,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: muted ? 0.65 : 0.85,
                                  ),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
              tooltip: 'Opciones',
              onPressed: onMore,
            ),
            Transform.scale(
              scale: 0.88,
              child: Switch.adaptive(
                value: method.isActive,
                onChanged: isSaving ? null : onToggle,
                activeTrackColor: AppColors.primaryGold.withValues(alpha: 0.45),
                activeThumbColor: AppColors.primaryGold,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final int maxLines;

  const _EditorField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.backgroundDark,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryGold.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String message;
  const _EmptyBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
