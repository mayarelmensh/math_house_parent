import 'package:equatable/equatable.dart';
import 'package:math_house_parent/data/models/my_course_model.dart';

abstract class MyCoursesState extends Equatable {
  const MyCoursesState();

  @override
  List<Object> get props => [];
}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final List<MyCoursesModel> courses;

  const MyCoursesLoaded(this.courses);

  @override
  List<Object> get props => [courses];
}

class MyCoursesError extends MyCoursesState {
  final String message;

  const MyCoursesError(this.message);

  @override
  List<Object> get props => [message];
}