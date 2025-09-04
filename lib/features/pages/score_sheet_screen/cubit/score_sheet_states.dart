import 'package:equatable/equatable.dart';
import 'package:math_house_parent/data/models/score_sheet_model.dart';

abstract class ScoreSheetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScoreSheetInitialState extends ScoreSheetState {}

class ScoreSheetLoadingState extends ScoreSheetState {}

class ScoreSheetSuccessState extends ScoreSheetState {
  final ScoreSheetResponseModel scoreSheet;

  ScoreSheetSuccessState({required this.scoreSheet});

  @override
  List<Object?> get props => [scoreSheet];
}

class ScoreSheetErrorState extends ScoreSheetState {
  final String message;

  ScoreSheetErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}