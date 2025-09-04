import 'package:equatable/equatable.dart';
import 'package:math_house_parent/data/models/course_score_sheet_model.dart';
import 'package:math_house_parent/data/models/score_sheet_model.dart';

abstract class CoursesForScoreSheetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoursesForScoreSheetInitialState extends CoursesForScoreSheetState {}

class CoursesForScoreSheetLoadingState extends CoursesForScoreSheetState {}

class CoursesForScoreSheetSuccessState extends CoursesForScoreSheetState {
  final List<CourseForScoreSheetModel> courses;
  final CourseForScoreSheetModel? selectedCourse;
  final List<ScoreSheetResponseModel> scoreSheets;

  CoursesForScoreSheetSuccessState({
    required this.courses,
    this.selectedCourse,
    required this.scoreSheets,
  });

  @override
  List<Object?> get props => [courses, selectedCourse, scoreSheets];
}

class CoursesForScoreSheetErrorState extends CoursesForScoreSheetState {
  final String message;

  CoursesForScoreSheetErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}