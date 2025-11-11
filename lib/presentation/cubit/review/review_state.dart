part of 'review_cubit.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<ReviewEntity> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}

class ReviewCreating extends ReviewState {}

class ReviewCreated extends ReviewState {
  final ReviewEntity review;

  const ReviewCreated(this.review);

  @override
  List<Object> get props => [review];
}

class ReviewChecking extends ReviewState {}

class ReviewCheckLoaded extends ReviewState {
  final bool hasReviewed;

  const ReviewCheckLoaded(this.hasReviewed);

  @override
  List<Object> get props => [hasReviewed];
}

