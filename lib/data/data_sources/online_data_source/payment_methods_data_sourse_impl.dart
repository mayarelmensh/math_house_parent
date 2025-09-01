import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_manager.dart';
import '../../../domain/repository/data_sources/remote_data_source/payment_methods_data_sourse.dart';
import '../../models/payment_methods_response_dm.dart';

@Injectable(as: PaymentMethodsRemoteDataSource)
class PaymentMethodsRemoteDataSourceImpl implements PaymentMethodsRemoteDataSource {
  final ApiManager apiManager;

  PaymentMethodsRemoteDataSourceImpl(this.apiManager);

  @override
  Future<PaymentMethodsResponseDm> getPaymentMethods({required int userId}) async {
    try {
      // Get token and userId from SharedPreferences
      final token = await SharedPreferenceUtils.getData(key: 'token');

      if (token==null) {
        throw Exception('No authentication token found');
      }

      // if (userId == 0) {
      //   throw Exception('User ID not found');
      // }

      final response = await apiManager.postData(
        endPoint: EndPoints.paymentMethods,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        body: {
          'user_id': userId
        }
      );

      return PaymentMethodsResponseDm.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }
}