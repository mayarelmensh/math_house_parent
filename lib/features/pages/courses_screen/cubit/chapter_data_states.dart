import '../../../../data/models/chapter_data_model.dart';

abstract class ChapterDataStates {}

class ChapterDataInitialState extends ChapterDataStates {}

class ChapterDataLoadingState extends ChapterDataStates {}

class ChapterDataSuccessState extends ChapterDataStates {
  final ChapterDataEntity chapterData;

  ChapterDataSuccessState(this.chapterData);
}

class ChapterDataErrorState extends ChapterDataStates {
  final String error;

  ChapterDataErrorState(this.error);
}