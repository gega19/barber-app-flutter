part of 'barber_payment_methods_cubit.dart';

class BarberPaymentMethodsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final List<PaymentMethodEntity> methods;
  final List<PaymentMethodEntity> templates;
  final String? errorMessage;

  const BarberPaymentMethodsState({
    this.isLoading = false,
    this.isSaving = false,
    this.methods = const [],
    this.templates = const [],
    this.errorMessage,
  });

  BarberPaymentMethodsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<PaymentMethodEntity>? methods,
    List<PaymentMethodEntity>? templates,
    String? errorMessage,
  }) {
    return BarberPaymentMethodsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      methods: methods ?? this.methods,
      templates: templates ?? this.templates,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    methods,
    templates,
    errorMessage,
  ];
}
