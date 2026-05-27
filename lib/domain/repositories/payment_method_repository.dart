import '../entities/payment_method_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class PaymentMethodRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods({String? barberId});
  Future<Either<Failure, PaymentMethodEntity>> getPaymentMethodWithConfig(String id);

  Future<Either<Failure, List<PaymentMethodEntity>>> getBarberPaymentOptions(String barberId);
  Future<Either<Failure, List<PaymentMethodEntity>>> getBarberPaymentTemplates(String barberId);
  Future<Either<Failure, PaymentMethodEntity>> saveBarberPaymentOption({
    required String barberId,
    String? id,
    required String name,
    String? icon,
    Map<String, dynamic>? config,
    bool? isActive,
    String? templateId,
    int? sortOrder,
  });
  Future<Either<Failure, void>> setBarberPaymentOptionEnabled(
    String id, {
    required bool isActive,
  });

  Future<Either<Failure, void>> deleteBarberPaymentOption(String id);
}

