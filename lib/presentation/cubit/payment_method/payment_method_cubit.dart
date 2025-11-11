import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/usecases/payment_method/get_payment_methods_usecase.dart';

part 'payment_method_state.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;

  PaymentMethodCubit({
    required this.getPaymentMethodsUseCase,
  }) : super(PaymentMethodInitial());

  Future<void> loadPaymentMethods() async {
    emit(PaymentMethodLoading());

    final result = await getPaymentMethodsUseCase();

    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (paymentMethods) => emit(PaymentMethodLoaded(paymentMethods)),
    );
  }
}

