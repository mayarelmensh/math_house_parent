import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/features/pages/payment_history/cubit/payment_history_states.dart';

import '../../../../core/api/api_manager.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/payment_history_response_dm.dart';

@injectable
class PaymentHistoryCubit extends Cubit<PaymentState> {
  final ApiManager _apiManager;

  PaymentHistoryCubit(this._apiManager) : super(PaymentInitial());

  Future<void> getPayments({required int? userId}) async {
    try {
      emit(PaymentLoading());
      var token = SharedPreferenceUtils.getData(key: 'token');

      final response = await _apiManager.postData(
        endPoint: EndPoints.paymentHistory,
        body: {
          'user_id': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // 'Content-Type': 'application/json',
            // 'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final paymentResponse = PaymentResponse.fromJson(response.data);
        // Store all payments in allPayments for filtering
        emit(PaymentSuccess(
          payments: paymentResponse.payments,
          allPayments: paymentResponse.payments,
        ));
      } else {
        emit(PaymentError(message: 'Error loading data'));
      }
    } on DioException catch (e) {
      String errorMessage = _handleDioError(e);
      emit(PaymentError(message: errorMessage));
    } catch (e) {
      emit(PaymentError(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  void filterPaymentsByStatus(String status) {
    final currentState = state;
    if (currentState is PaymentSuccess) {
      List<PaymentModel> filteredPayments;

      if (status.toLowerCase() == 'all') {
        filteredPayments = currentState.allPayments ?? currentState.payments;
      } else {
        final allPayments = currentState.allPayments ?? currentState.payments;
        filteredPayments = allPayments.where((payment) {
          final paymentStatus = payment.status.toLowerCase();
          if (status.toLowerCase() == 'pending') {
            return paymentStatus == 'pending' || payment.isPending;
          } else if (status.toLowerCase() == 'approve' || status.toLowerCase() == 'approved') {
            return paymentStatus == 'approved' || payment.isApproved;
          }
          return paymentStatus == status.toLowerCase();
        }).toList();
      }

      emit(PaymentSuccess(
        payments: filteredPayments,
        allPayments: currentState.allPayments ?? currentState.payments,
      ));
    }
  }

  Future<void> refreshPayments({required int? userId}) async {
    await getPayments(userId: userId);
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Unauthorized access';
        } else if (error.response?.statusCode == 404) {
          return 'Data not found';
        } else if (error.response?.statusCode == 500) {
          return 'Server error';
        }
        return 'Connection error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Check your internet connection';
      default:
        return 'Network error occurred';
    }
  }
}