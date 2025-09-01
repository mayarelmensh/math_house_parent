import 'package:injectable/injectable.dart';
import '../../../domain/entities/payment_methods_response_entity.dart';
import '../../domain/repository/data_sources/remote_data_source/payment_methods_data_sourse.dart';
import '../../domain/repository/payment_methods/payment_methods_repository.dart';

@Injectable(as: PaymentMethodsRepository)
class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource remoteDataSource;

  PaymentMethodsRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaymentMethodsResponseEntity> getPaymentMethods({
    required int userId,
  }) async {
    try {
      final result = await remoteDataSource.getPaymentMethods(
        userId: userId,
      );
      return result;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}