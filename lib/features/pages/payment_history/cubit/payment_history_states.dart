import 'package:equatable/equatable.dart';

import '../../../../data/models/payment_history_response_dm.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final List<PaymentModel> payments;
  final List<PaymentModel>? allPayments; // للاحتفاظ بجميع البيانات عند التصفية

  const PaymentSuccess({
    required this.payments,
    this.allPayments,
  });

  @override
  List<Object?> get props => [payments, allPayments];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}