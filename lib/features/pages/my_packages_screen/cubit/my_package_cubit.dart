import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';

import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/my_package_model.dart';

abstract class MyPackageState {}

class MyPackageInitial extends MyPackageState {}

class MyPackageLoading extends MyPackageState {}

class MyPackageLoaded extends MyPackageState {
  final MyPackageModel package;
  MyPackageLoaded(this.package);
}

class MyPackageError extends MyPackageState {
  final String message;
  MyPackageError(this.message);
}

@injectable
class MyPackageCubit extends Cubit<MyPackageState> {
  final ApiManager apiManager;

  MyPackageCubit(this.apiManager) : super(MyPackageInitial());

  Future<void> fetchMyPackageData({
    required int userId,

  }) async {
    emit(MyPackageLoading());
    try {
      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.postData(
        endPoint: EndPoints.myPackages,
        body: {
          'user_id':userId
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token'
          },
        ),
      );
      final package = MyPackageModel.fromJson(response.data);
      emit(MyPackageLoaded(package));
    } catch (e) {
      emit(MyPackageError(e.toString()));
    }
  }
}