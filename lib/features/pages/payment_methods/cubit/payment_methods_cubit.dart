import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/use_case/payment_methods_use_case.dart';
import 'payment_methods_states.dart';

@injectable
class PaymentMethodsCubit extends Cubit<PaymentMethodsStates> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;

  PaymentMethodsCubit(this.getPaymentMethodsUseCase)
      : super(PaymentMethodsInitialState());

  Future<void> getPaymentMethods({
    required int userId,
  }) async {
    try {
      emit(PaymentMethodsLoadingState());

      final result = await getPaymentMethodsUseCase(
        userId: userId,
      );

      emit(PaymentMethodsSuccessState(result));
    } catch (e) {
      emit(PaymentMethodsErrorState(e.toString()));
    }
  }
}