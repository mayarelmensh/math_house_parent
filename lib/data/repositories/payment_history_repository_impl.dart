// import 'package:injectable/injectable.dart';
// import 'package:math_house_parent/domain/entities/payment_history_response_entity.dart';
//
// import '../../domain/repository/data_sources/remote_data_source/payment_history_data_source.dart';
// import '../../domain/repository/payment_history/payment_history.dart';
//
// @Injectable(as: PaymentHistoryRepository)
// class PaymentRepositoryImpl implements PaymentHistoryRepository {
//   final PaymentRemoteDataSource remoteDataSource;
//
//   PaymentRepositoryImpl(this.remoteDataSource);
//
//   @override
//   Future<List<PaymentHistoryResponseEntity>> getPaymentHistory(String userId) async {
//     try {
//       final response = await remoteDataSource.getPaymentHistory(userId);
//       // هنا response هو PaymentHistoryResponseEntity ومفروض يكون فيه قائمة payments
//       return response.payments; // ✅ إذا كان فيه payments property
//     } catch (e) {
//       throw Exception('Failed to fetch payment history: $e');
//     }
//   }
// }
