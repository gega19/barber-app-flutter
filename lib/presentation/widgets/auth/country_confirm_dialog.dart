import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../core/utils/country_display.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/country/country_cubit.dart';
import '../../cubit/country/country_state.dart';

/// Pide confirmar o elegir país cuando el backend detectó uno por IP y el usuario no tiene país guardado.
class CountryConfirmDialog extends StatefulWidget {
  const CountryConfirmDialog({
    super.key,
    required this.suggestedCountryCode,
  });

  final String suggestedCountryCode;

  static Future<void> show(
    BuildContext context, {
    required String suggestedCountryCode,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: CountryConfirmDialog(
          suggestedCountryCode: suggestedCountryCode.trim().toUpperCase(),
        ),
      ),
    );
  }

  @override
  State<CountryConfirmDialog> createState() => _CountryConfirmDialogState();
}

class _CountryConfirmDialogState extends State<CountryConfirmDialog> {
  String? _selectedCode;

  String? _matchCode(CountryLoaded state, String? code) {
    if (code == null || code.isEmpty) return null;
    final upper = code.toUpperCase();
    for (final c in state.countries) {
      if (c.code.toUpperCase() == upper) return c.code;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CountryCubit>()..fetchCountries(),
      child: AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Selecciona tu país',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: BlocBuilder<CountryCubit, CountryState>(
          builder: (context, state) {
            if (state is CountryLoading || state is CountryInitial) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                ),
              );
            }

            if (state is! CountryLoaded) {
              return const Text(
                'No se pudo cargar la lista de países',
                style: TextStyle(color: AppColors.error),
              );
            }

            final matched = _matchCode(state, widget.suggestedCountryCode);
            _selectedCode ??= matched ?? state.countries.first.code;
            final detectedInCatalog = matched != null;
            final selectedInList = _matchCode(state, _selectedCode);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Esto nos ayuda a mostrarte barberos y barberías disponibles en tu zona.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                if (detectedInCatalog) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        countryEmojiForCode(matched),
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.countries.firstWhere((c) => c.code == matched).name,
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderGold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedInList,
                      hint: const Text('Elige un país'),
                      items: state.countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.code,
                              child: Text(
                                '${countryEmojiForCode(c.code)} ${c.name}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCode = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Más tarde',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.textDark,
            ),
            onPressed: _selectedCode == null
                ? null
                : () {
                    context.read<AuthCubit>().updateProfile(country: _selectedCode);
                    Navigator.of(context).pop();
                  },
            child: const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
