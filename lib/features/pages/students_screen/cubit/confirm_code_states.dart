import 'package:math_house_parent/core/errors/failures.dart';
import 'package:math_house_parent/domain/entities/confirm_code_response_entity.dart';

class ConfirmCodeStates{}
class ConfirmCodeInitialState extends ConfirmCodeStates{}
class ConfirmCodeLoadingState extends  ConfirmCodeStates{}
class ConfirmCodeErrorState extends ConfirmCodeStates{
 final Failures errors;
  ConfirmCodeErrorState({required this.errors});
}
class ConfirmCodeSuccessState extends ConfirmCodeStates{
  final ConfirmCodeResponseEntity confirmCodeEntity;
  ConfirmCodeSuccessState({required this.confirmCodeEntity});
}