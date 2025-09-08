// promo_code_screen/cubit/promo_code_states.dart
import '../../../../data/models/promo_code_model.dart';

abstract class PromoCodeStates {}

class PromoCodeInitialState extends PromoCodeStates {}

class PromoCodeLoadingState extends PromoCodeStates {}

class PromoCodeSuccessState extends PromoCodeStates {
  final PromoCodeResponse response;

  PromoCodeSuccessState(this.response);
}

class PromoCodeErrorState extends PromoCodeStates {
  final String error;

  PromoCodeErrorState(this.error);
}