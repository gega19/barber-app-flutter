import '../entities/payment_method_entity.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class PaymentMethodRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, PaymentMethodEntity>> getPaymentMethodWithConfig(String id);
}

