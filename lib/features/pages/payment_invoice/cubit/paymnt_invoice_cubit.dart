// payment_invoice_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import '../../../../data/models/payment_invoice_model.dart';
import 'payment_invoice_states.dart';

@injectable
class PaymentInvoiceCubit extends Cubit<PaymentInvoiceState> {
  final ApiManager _apiManager;

  PaymentInvoiceCubit(this._apiManager) : super(PaymentInvoiceInitial());

  Future<void> getInvoice({required int paymentId}) async {
    try {
      emit(PaymentInvoiceLoading());
      var token = SharedPreferenceUtils.getData(key: 'token');

      final response = await _apiManager.postData(
        endPoint: '${EndPoints.paymentInvoice}$paymentId', // ضع هنا endpoint الفاتورة الصحيح
        body: {
          'user_id': SelectedStudent.studentId, // أو حسب ما يتطلب الـ API
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('Invoice response data:::::::::::::::: ${response.data}');
        final invoice = PaymentInvoiceModel.fromJson(response.data);
        print('Parsed invoice: $invoice');
        emit(PaymentInvoiceSuccess(invoice));
      } else {
        emit(PaymentInvoiceError('Failed to load invoice'));
      }
    } on DioException catch (e) {
      emit(PaymentInvoiceError('Network error: ${e.message}'));
    } catch (e) {
      emit(PaymentInvoiceError('Unexpected error: ${e.toString()}'));
    }
  }
}