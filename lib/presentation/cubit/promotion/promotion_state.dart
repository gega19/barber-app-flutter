part of 'promotion_cubit.dart';

abstract class PromotionState extends Equatable {
  const PromotionState();

  @override
  List<Object?> get props => [];
}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionLoaded extends PromotionState {
  final List<PromotionEntity> promotions;

  const PromotionLoaded(this.promotions);

  @override
  List<Object?> get props => [promotions];
}

class PromotionError extends PromotionState {
  final String message;

  const PromotionError(this.message);

  @override
  List<Object?> get props => [message];
}

