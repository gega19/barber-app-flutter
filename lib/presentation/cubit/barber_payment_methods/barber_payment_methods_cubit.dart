import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/repositories/payment_method_repository.dart';

part 'barber_payment_methods_state.dart';

class BarberPaymentMethodsCubit extends Cubit<BarberPaymentMethodsState> {
  final PaymentMethodRepository paymentMethodRepository;

  BarberPaymentMethodsCubit({required this.paymentMethodRepository})
    : super(const BarberPaymentMethodsState());

  Future<void> load(String barberId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final methodsResult =
        await paymentMethodRepository.getBarberPaymentOptions(barberId);

    List<PaymentMethodEntity> methods = [];
    String? error;

    methodsResult.fold(
      (failure) => error = failure.message,
      (value) => methods = value,
    );

    emit(
      state.copyWith(
        isLoading: false,
        methods: methods,
        templates: const [],
        errorMessage: error,
      ),
    );
  }

  Future<bool> save({
    required String barberId,
    String? id,
    required String name,
    String? icon,
    Map<String, dynamic>? config,
    bool? isActive,
    String? templateId,
    int? sortOrder,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await paymentMethodRepository.saveBarberPaymentOption(
      barberId: barberId,
      id: id,
      name: name,
      icon: icon,
      config: config,
      isActive: isActive,
      templateId: templateId,
      sortOrder: sortOrder,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) async {
        await load(barberId);
        emit(state.copyWith(isSaving: false));
        return true;
      },
    );
  }

  /// Activa o desactiva (el registro sigue existiendo; desactivado → sección «Desactivados»).
  Future<bool> setActive({
    required String barberId,
    required String id,
    required bool isActive,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await paymentMethodRepository.setBarberPaymentOptionEnabled(
      id,
      isActive: isActive,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) async {
        await load(barberId);
        emit(state.copyWith(isSaving: false));
        return true;
      },
    );
  }

  /// Borra el método de la base de datos (no aparece en desactivados).
  Future<bool> delete({
    required String barberId,
    required String id,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await paymentMethodRepository.deleteBarberPaymentOption(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
      },
      (_) async {
        await load(barberId);
        emit(state.copyWith(isSaving: false));
        return true;
      },
    );
  }
}
