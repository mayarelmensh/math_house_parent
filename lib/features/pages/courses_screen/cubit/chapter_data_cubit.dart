import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import '../../../../data/models/chapter_data_model.dart';
import 'chapter_data_states.dart';

@injectable
class ChapterDataCubit extends Cubit<ChapterDataStates> {
  final ApiManager apiManager;

  ChapterDataCubit(this.apiManager) : super(ChapterDataInitialState());

  Future<void> getChapterData(int chapterId) async {
    try {
      emit(ChapterDataLoadingState());
      final token = SharedPreferenceUtils.getData(key: 'token') as String?;

      final response = await apiManager.postData(
        endPoint: EndPoints.chapterData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        body :{
          'chapter_ids[]': chapterId
        }
      );
      final chapterData = ChapterDataEntity.fromJson(response.data);
      emit(ChapterDataSuccessState(chapterData));
    } catch (e) {
      emit(ChapterDataErrorState(e.toString()));
    }
  }
}
