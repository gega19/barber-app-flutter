import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/promotion_entity.dart';
import '../../../domain/usecases/promotion/get_promotions_usecase.dart';

part 'promotion_state.dart';

class PromotionCubit extends Cubit<PromotionState> {
  final GetPromotionsUseCase getPromotionsUseCase;

  PromotionCubit({required this.getPromotionsUseCase})
    : super(PromotionInitial());

  Future<void> loadPromotions() async {
    emit(PromotionLoading());

    final result = await getPromotionsUseCase();

    result.fold((failure) => emit(PromotionError(failure.message)), (
      promotions,
    ) {
      // Filtrar promociones expiradas y solo activas
      final now = DateTime.now();
      final activePromotions = promotions.where((promotion) {
        return promotion.isActive &&
            promotion.validUntil.isAfter(now) &&
            promotion.validFrom.isBefore(now);
      }).toList();
      emit(PromotionLoaded(activePromotions));
    });
  }
}
