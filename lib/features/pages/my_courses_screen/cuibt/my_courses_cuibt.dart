import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';
import 'package:math_house_parent/core/api/end_points.dart';
import 'package:math_house_parent/data/models/my_course_model.dart';
import '../../../../core/cache/shared_preferences_utils.dart';
import 'my_courses_states.dart';

@injectable
class MyCoursesCubit extends Cubit<MyCoursesState> {
  final ApiManager apiManager;

  MyCoursesCubit(this.apiManager) : super(MyCoursesInitial());

  Future<void> fetchMyCourses(int userId) async {
    try {
      emit(MyCoursesLoading());

      final token = SharedPreferenceUtils.getData(key: 'token');
      final response = await apiManager.postData(
          endPoint: EndPoints.myCourses,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          body: {
            'user_id':userId
          }
      );

      if (response.statusCode == 200) {
        final courses = (response.data['courses'] as List)
            .map((json) => MyCoursesModel.fromJson(json))
            .toList();
        emit(MyCoursesLoaded(courses));
      } else {
        emit(MyCoursesError('Failed to load courses'));
      }
    } catch (e) {
      emit(MyCoursesError('Error: ${e.toString()}'));
    }
  }
}