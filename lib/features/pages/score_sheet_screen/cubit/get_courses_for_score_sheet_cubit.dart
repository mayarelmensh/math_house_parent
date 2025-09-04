import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/core/cache/shared_preferences_utils.dart';
import 'package:math_house_parent/data/models/course_score_sheet_model.dart';
import 'package:math_house_parent/data/models/student_selected.dart';
import 'get_courses_for_score_sheet_states.dart';

@injectable
class CoursesForScoreSheetCubit extends Cubit<CoursesForScoreSheetState> {
  final ApiManager apiManager;

  CoursesForScoreSheetCubit(this.apiManager)
      : super(CoursesForScoreSheetInitialState());

  Future<void> fetchCourses() async {
    try {
      print('Fetching courses...');
      emit(CoursesForScoreSheetLoadingState());
      final token = SharedPreferenceUtils.getData(key: 'token');
      final studentId = SelectedStudent.studentId;
      print('Token: $token, Student ID: $studentId');

      if (token == null || studentId == null) {
        print('Invalid token or studentId');
        emit(CoursesForScoreSheetErrorState(message: 'Invalid token or student ID'));
        return;
      }

      final response = await apiManager.postData(
        endPoint: EndPoints.scoreSheetCoursesList,
        body: {'user_id': studentId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Courses API response: ${response.data}');

      final coursesResponse = CoursesResponse.fromJson(response.data);
      emit(CoursesForScoreSheetSuccessState(
        courses: coursesResponse.courses,
        selectedCourse: null,
        scoreSheets: [],
      ));
    } catch (e) {
      print('Error fetching courses: $e');
      emit(CoursesForScoreSheetErrorState(message: e.toString()));
    }
  }

  void selectCourse(CourseForScoreSheetModel? course) {
    if (state is CoursesForScoreSheetSuccessState) {
      final currentState = state as CoursesForScoreSheetSuccessState;
      emit(CoursesForScoreSheetSuccessState(
        courses: currentState.courses,
        selectedCourse: course,
        scoreSheets: currentState.scoreSheets,
      ));
    } else {
      print('Cannot select course: Not in SuccessState');
    }
  }
}