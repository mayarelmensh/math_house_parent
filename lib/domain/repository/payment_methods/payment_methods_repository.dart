
import '../../entities/payment_methods_response_entity.dart';

abstract class PaymentMethodsRepository {
  Future<PaymentMethodsResponseEntity> getPaymentMethods({
    required int userId,
  });
}