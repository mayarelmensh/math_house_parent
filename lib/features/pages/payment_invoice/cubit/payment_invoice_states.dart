// payment_invoice_states.dart
import '../../../../data/models/payment_invoice_model.dart';

abstract class PaymentInvoiceState {}

class PaymentInvoiceInitial extends PaymentInvoiceState {}

class PaymentInvoiceLoading extends PaymentInvoiceState {}

class PaymentInvoiceSuccess extends PaymentInvoiceState {
  final PaymentInvoiceModel invoice;

  PaymentInvoiceSuccess(this.invoice);
}

class PaymentInvoiceError extends PaymentInvoiceState {
  final String message;

  PaymentInvoiceError(this.message);
}