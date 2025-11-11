import '../../entities/payment_method_entity.dart';
import '../../repositories/payment_method_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetPaymentMethodsUseCase {
  final PaymentMethodRepository repository;

  GetPaymentMethodsUseCase(this.repository);

  Future<Either<Failure, List<PaymentMethodEntity>>> call() async {
    return await repository.getPaymentMethods();
  }
}

