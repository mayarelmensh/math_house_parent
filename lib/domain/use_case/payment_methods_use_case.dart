import 'package:injectable/injectable.dart';
import '../entities/payment_methods_response_entity.dart';
import '../repository/payment_methods/payment_methods_repository.dart';

@injectable
class GetPaymentMethodsUseCase {
  final PaymentMethodsRepository repository;

  GetPaymentMethodsUseCase(this.repository);

  Future<PaymentMethodsResponseEntity> call({
    required int userId,
  }) async {
    return await repository.getPaymentMethods(
      userId: userId,
    );
  }
}