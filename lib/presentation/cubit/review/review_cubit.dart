import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/usecases/review/get_reviews_by_barber_usecase.dart';
import '../../../domain/usecases/review/get_reviews_by_workplace_usecase.dart';
import '../../../domain/usecases/review/create_review_usecase.dart';
import '../../../domain/usecases/review/has_user_reviewed_barber_usecase.dart';
import '../../../domain/usecases/review/has_user_reviewed_workplace_usecase.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final GetReviewsByBarberUseCase getReviewsByBarberUseCase;
  final GetReviewsByWorkplaceUseCase getReviewsByWorkplaceUseCase;
  final CreateReviewUseCase createReviewUseCase;
  final HasUserReviewedBarberUseCase hasUserReviewedBarberUseCase;
  final HasUserReviewedWorkplaceUseCase hasUserReviewedWorkplaceUseCase;

  ReviewCubit({
    required this.getReviewsByBarberUseCase,
    required this.getReviewsByWorkplaceUseCase,
    required this.createReviewUseCase,
    required this.hasUserReviewedBarberUseCase,
    required this.hasUserReviewedWorkplaceUseCase,
  }) : super(ReviewInitial());

  Future<void> loadReviewsByBarber(String barberId) async {
    emit(ReviewLoading());

    final result = await getReviewsByBarberUseCase(barberId);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewLoaded(reviews)),
    );
  }

  Future<void> loadReviewsByWorkplace(String workplaceId) async {
    emit(ReviewLoading());

    final result = await getReviewsByWorkplaceUseCase(workplaceId);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewLoaded(reviews)),
    );
  }

  Future<void> checkHasUserReviewedBarber(String barberId) async {
    emit(ReviewChecking());

    final result = await hasUserReviewedBarberUseCase(barberId);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (hasReviewed) => emit(ReviewCheckLoaded(hasReviewed)),
    );
  }

  Future<void> checkHasUserReviewedWorkplace(String workplaceId) async {
    emit(ReviewChecking());

    final result = await hasUserReviewedWorkplaceUseCase(workplaceId);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (hasReviewed) => emit(ReviewCheckLoaded(hasReviewed)),
    );
  }

  Future<bool> createReview({
    String? barberId,
    String? workplaceId,
    required int rating,
    String? comment,
  }) async {
    emit(ReviewCreating());

    final result = await createReviewUseCase(
      barberId: barberId,
      workplaceId: workplaceId,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) {
        emit(ReviewError(failure.message));
        return false;
      },
      (review) {
        emit(ReviewCreated(review));
        // Recargar reseñas después de crear una nueva
        if (barberId != null) {
          loadReviewsByBarber(barberId);
        } else if (workplaceId != null) {
          loadReviewsByWorkplace(workplaceId);
        }
        return true;
      },
    );
  }
}

