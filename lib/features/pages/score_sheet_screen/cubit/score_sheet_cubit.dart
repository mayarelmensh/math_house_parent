import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'package:math_house_parent/data/models/score_sheet_model.dart';
import 'score_sheet_states.dart';

@injectable
class ScoreSheetCubit extends Cubit<ScoreSheetState> {
  final ApiManager apiManager;

  ScoreSheetCubit(this.apiManager) : super(ScoreSheetInitialState());

  Future<void> fetchScoreSheet(int courseId) async {
    try {
      print('Fetching score sheet for courseId: $courseId');
      emit(ScoreSheetLoadingState());
      final token = SharedPreferenceUtils.getData(key: 'token');
      final studentId = SelectedStudent.studentId;
      print('Token: $token, Student ID: $studentId, Course ID: $courseId');

      if (token == null || studentId == null) {
        print('Invalid token or studentId');
        emit(ScoreSheetErrorState(message: 'Invalid token or student ID'));
        return;
      }

      final response = await apiManager.postData(
        endPoint: EndPoints.scoreSheet,
        body: {
          'user_id': studentId,
          'course_id': courseId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Score sheet API response: ${response.data}');

      final scoreSheet = ScoreSheetResponseModel.fromJson(response.data);
      emit(ScoreSheetSuccessState(scoreSheet: scoreSheet));
    } catch (e) {
      print('Error fetching score sheet: $e');
      emit(ScoreSheetErrorState(message: e.toString()));
    }
  }
}