import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/send_code_response_entity.dart';

class SendCodeStates{}
class SendCodeInitialState extends SendCodeStates{}
class SendCodeLoadingState extends SendCodeStates{}
class SendCodeSuccessState extends SendCodeStates{
  SendCodeResponseEntity sendCodeResponseEntity;
  SendCodeSuccessState({required this.sendCodeResponseEntity});
}
class SendCodeErrorState extends SendCodeStates{
  final Failures errors;
  SendCodeErrorState({required this.errors});
}