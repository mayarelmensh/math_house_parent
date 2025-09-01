
import '../../../../domain/entities/payment_methods_response_entity.dart';

abstract class PaymentMethodsStates {}

class PaymentMethodsInitialState extends PaymentMethodsStates {}

class PaymentMethodsLoadingState extends PaymentMethodsStates {}

class PaymentMethodsSuccessState extends PaymentMethodsStates {
  final PaymentMethodsResponseEntity paymentMethodsResponse;

  PaymentMethodsSuccessState(this.paymentMethodsResponse);
}

class PaymentMethodsErrorState extends PaymentMethodsStates {
  final String error;

  PaymentMethodsErrorState(this.error);
}