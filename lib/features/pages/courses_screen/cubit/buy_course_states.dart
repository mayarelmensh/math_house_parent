
import '../../../../data/models/buy_cource_model.dart';

abstract class BuyCourseStates {}

class BuyCourseInitialState extends BuyCourseStates {}

class BuyCourseLoadingState extends BuyCourseStates {}

class BuyCourseSuccessState extends BuyCourseStates {
  final BuyCourseResponseEntity response;

  BuyCourseSuccessState(this.response);
}

class BuyCourseErrorState extends BuyCourseStates {
  final String error;

  BuyCourseErrorState(this.error);
}