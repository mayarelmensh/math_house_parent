import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/features/pages/wallet_history/cubit/wallet_history_states.dart';

import '../../../../core/api/api_manager.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/wallet_history.dart';

@injectable
class WalletHistoryCubit extends Cubit<WalletState> {
  final ApiManager apiManager;

  WalletHistoryCubit(this.apiManager) : super(WalletInitial());

  Future<void> fetchWalletData({

    required int userId,
  }) async {
    emit(WalletLoading());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.postData(endPoint: EndPoints.walletHistory,
        body: {
        'user_id': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'User-Id': userId,
          },
        ),
      );
      final walletResponse = WalletResponse.fromJson(response.data);
      emit(WalletLoaded(walletResponse));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}