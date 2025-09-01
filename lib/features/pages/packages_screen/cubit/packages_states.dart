import '../../../../domain/entities/packages_response_entity.dart';

abstract class PackagesStates {}

class PackagesInitialState extends PackagesStates {}

class PackagesLoadingState extends PackagesStates {}

class PackagesErrorState extends PackagesStates {
  final String error;
  PackagesErrorState({required this.error});
}

class PackagesSpecificCourseSuccessState extends PackagesStates {
  final List<PackageEntity> packagesResponseList;
  PackagesSpecificCourseSuccessState({required this.packagesResponseList});
}

class PackagesSuccessState extends PackagesStates {
  final List<PackagesResponseEntity> packagesResponseEntities;
  PackagesSuccessState({required this.packagesResponseEntities});
}

class PackagesAllStudentsSuccessState extends PackagesStates {
  final Map<int, List<PackagesResponseEntity>> packagesByCourse;
  PackagesAllStudentsSuccessState({required this.packagesByCourse});
}