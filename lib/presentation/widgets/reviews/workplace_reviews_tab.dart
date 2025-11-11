import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/entities/review_entity.dart';
import '../../cubit/review/review_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../common/app_card.dart';
import '../common/app_avatar.dart';
import '../common/error_widget.dart';
import '../common/app_button.dart';
import 'package:intl/intl.dart';

class WorkplaceReviewsTab extends StatefulWidget {
  final WorkplaceEntity workplace;

  const WorkplaceReviewsTab({
    super.key,
    required this.workplace,
  });

  @override
  State<WorkplaceReviewsTab> createState() => _WorkplaceReviewsTabState();
}

class _WorkplaceReviewsTabState extends State<WorkplaceReviewsTab> {
  bool _hasReviewed = false;
  bool _isCheckingReview = true;
  bool _showReviewForm = false;
  final TextEditingController _commentController = TextEditingController();
  List<ReviewEntity> _cachedReviews = []; // Cache de reseñas para mantenerlas durante recargas

  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().loadReviewsByWorkplace(widget.workplace.id);
    _checkReviewStatus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _checkReviewStatus() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Verificar si ya ha dejado reseña
      context.read<ReviewCubit>().checkHasUserReviewedWorkplace(widget.workplace.id);
    } else {
      setState(() {
        _isCheckingReview = false;
      });
    }
  }

  void _showReviewFormDialog() {
    final reviewCubit = context.read<ReviewCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: reviewCubit,
        child: _ReviewFormModal(
          workplaceId: widget.workplace.id,
          onReviewSubmitted: () {
            setState(() {
              _hasReviewed = true;
              _showReviewForm = false;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewCubit, ReviewState>(
      listener: (context, state) {
        if (state is ReviewCheckLoaded) {
          setState(() {
            _hasReviewed = state.hasReviewed;
            _isCheckingReview = false;
          });
        }
        if (state is ReviewLoaded) {
          // Actualizar cache cuando se cargan las reseñas
          setState(() {
            _cachedReviews = state.reviews;
            _isCheckingReview = false;
          });
        }
        if (state is ReviewCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Reseña enviada exitosamente!'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _hasReviewed = true;
            _showReviewForm = false;
            _commentController.clear();
            // Agregar la nueva reseña al cache inmediatamente
            if (!_cachedReviews.any((r) => r.id == state.review.id)) {
              _cachedReviews = [state.review, ..._cachedReviews];
            }
          });
          // Recargar datos de la barbería para actualizar rating y reviews en toda la pantalla
          if (context.read<WorkplaceCubit>().state is WorkplaceLoaded) {
            context.read<WorkplaceCubit>().loadWorkplaces();
          }
          // Recargar reseñas para obtener la lista completa actualizada
          context.read<ReviewCubit>().loadReviewsByWorkplace(widget.workplace.id);
        }
        if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          // Mostrar loading solo si estamos verificando el estado inicial y no hay cache
          if (state is ReviewLoading && _isCheckingReview && _cachedReviews.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            );
          }

          if (state is ReviewError && _isCheckingReview && _cachedReviews.isEmpty) {
            return Center(
              child: AppErrorWidget(
                message: state.message,
                onRetry: () {
                  _checkReviewStatus();
                },
              ),
            );
          }

          // Usar cache de reseñas (actualizado en el listener)
          final reviews = _cachedReviews;
          final dateFormat = DateFormat('d MMM yyyy', 'es_ES');
          final authState = context.read<AuthCubit>().state;
          final isAuthenticated = authState is AuthAuthenticated;
          final canReview = isAuthenticated && !_hasReviewed;

          // Calcular rating promedio desde las reseñas cargadas
          final double averageRating = reviews.isEmpty
              ? widget.workplace.rating
              : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length.toDouble();
          final int totalReviews = reviews.isEmpty ? widget.workplace.reviews : reviews.length;

          return Column(
            children: [
              // Rating Summary
              AppCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  size: 24,
                                  color: index < averageRating.floor()
                                      ? AppColors.primaryGold
                                      : AppColors.textSecondary,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalReviews reseñas totales',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Add Review Button (if user can review)
              if (canReview && !_showReviewForm)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppButton(
                    text: 'Dejar Reseña',
                    icon: Icons.star_outline,
                    onPressed: _showReviewFormDialog,
                  ),
                ),
              // Reviews List
              Expanded(
                child: reviews.isEmpty && !canReview
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_outline,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay reseñas aún',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];

                          return AppCard(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppAvatar(
                                      imageUrl: review.user.avatar,
                                      name: review.user.name,
                                      avatarSeed: review.user.avatarSeed,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                review.user.name,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                dateFormat.format(review.createdAt),
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                Icons.star,
                                                size: 16,
                                                color: i < review.rating
                                                    ? AppColors.primaryGold
                                                    : AppColors.textSecondary,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (review.comment != null && review.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    review.comment!,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewFormModal extends StatefulWidget {
  final String workplaceId;
  final VoidCallback onReviewSubmitted;

  const _ReviewFormModal({
    required this.workplaceId,
    required this.onReviewSubmitted,
  });

  @override
  State<_ReviewFormModal> createState() => _ReviewFormModalState();
}

class _ReviewFormModalState extends State<_ReviewFormModal> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una calificación'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await context.read<ReviewCubit>().createReview(
          workplaceId: widget.workplaceId,
          rating: _selectedRating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      widget.onReviewSubmitted();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dejar Reseña',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
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
          const Text(
            'Calificación',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.star,
                    size: 48,
                    color: index < _selectedRating
                        ? AppColors.primaryGold
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          const Text(
            'Comentario (opcional)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 5,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Escribe tu experiencia...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.backgroundCardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderGold),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderGold),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: _isSubmitting ? 'Enviando...' : 'Enviar Reseña',
            onPressed: _isSubmitting ? null : _submitReview,
            icon: _isSubmitting ? null : Icons.send,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
