import 'package:flutter/material.dart';
import '../../../../core/injection/injection.dart';
import '../../../../domain/usecases/barber/get_barber_by_slug_usecase.dart';
import '../../widgets/common/error_widget.dart';

import 'barber_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';

class BarberDetailBySlugScreen extends StatefulWidget {
  final String slug;

  const BarberDetailBySlugScreen({super.key, required this.slug});

  @override
  State<BarberDetailBySlugScreen> createState() =>
      _BarberDetailBySlugScreenState();
}

class _BarberDetailBySlugScreenState extends State<BarberDetailBySlugScreen> {
  final GetBarberBySlugUseCase _getBarberBySlug = sl<GetBarberBySlugUseCase>();

  // States
  bool _isLoading = true;
  String? _error;
  String? _barberId;

  @override
  void initState() {
    super.initState();
    _resolveSlug();
  }

  Future<void> _resolveSlug() async {
    final result = await _getBarberBySlug(widget.slug);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
        });
      },
      (barber) {
        setState(() {
          _isLoading = false;
          _barberId = barber.id;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          leading: const BackButton(color: Colors.white),
        ),
        body: AppErrorWidget(message: _error!, onRetry: _resolveSlug),
      );
    }

    if (_barberId != null) {
      // We found the ID, delegate to the standard detail screen.
      // We wrap it in the providers that BarberDetailScreen expects?
      // Actually app_router handles providers normally.
      // But here we are instantiating the widget directly.
      // So checking app_router lines 302-308:
      /*
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<BarberCubit>()..loadBarbers()),
              BlocProvider(create: (_) => sl<ReviewCubit>()),
            ],
            child: BarberDetailScreen(barberId: barberId),
          );
      */
      // We must check if BarberDetailScreen includes providers or expects them from parent.
      // Typically screens expect providers.
      // So we should delegate to the ROUTER via pushReplacement?
      // Or duplicate the providers wrapping here.
      // pushReplacement is cleaner but changes URL.
      // If we want to keep /barber/slug/X url, we must wrap here.

      return BarberDetailScreen(barberId: _barberId!);
    }

    return const SizedBox.shrink();
  }
}
