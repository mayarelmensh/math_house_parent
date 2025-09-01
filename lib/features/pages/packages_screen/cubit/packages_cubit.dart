import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/data/models/get_students_response_dm.dart';
import 'package:math_house_parent/data/models/courses_response_dm.dart';
import 'package:math_house_parent/domain/use_case/packages_use_case.dart';
import 'packages_states.dart';

@Injectable()
class PackagesCubit extends Cubit<PackagesStates> {
  final PackagesUseCase packagesUseCase;

  PackagesCubit({required this.packagesUseCase}) : super(PackagesInitialState());

  Future<void> getPackagesForCourse({
    required int courseId,
    required int userId,
  }) async {
    emit(PackagesLoadingState());

    final result = await packagesUseCase.getPackagesByCourseId(
      courseId: courseId,
      userId: userId,
    );

    result.fold(
          (failure) => emit(PackagesErrorState(error: failure.errorMsg)),
          (packagesResponse) {
        // هنا packagesResponse هو PackagesResponseEntity
        final packagesList = packagesResponse.courses?.packages ?? [];

        emit(PackagesSpecificCourseSuccessState(
          packagesResponseList: packagesList,
        ));
      },
    );
  }




  Future<void> getPackagesForAllStudents({
    required List<CourseDm> courses,
    required List<StudentsDm> myStudents,
  }) async {
    emit(PackagesLoadingState());

    final result = await packagesUseCase.getPackagesForAllStudents(
      courses: courses,
      myStudents: myStudents,
    );

    result.fold(
          (failure) => emit(PackagesErrorState(error: failure.errorMsg)),
          (packagesByCourse) => emit(
        PackagesAllStudentsSuccessState(packagesByCourse: packagesByCourse),
      ),
    );
  }

  Future<void> getPackagesForSpecificCourse({
    required int courseId,
    required List<StudentsDm> myStudents,
  }) async {
    emit(PackagesLoadingState());

    final result = await packagesUseCase.getPackagesForSpecificCourse(
      courseId: courseId,
      myStudents: myStudents,
    );

    result.fold(
          (failure) => emit(PackagesErrorState(error: failure.errorMsg)),
          (packagesResponseList) => emit(
        PackagesSuccessState(packagesResponseEntities: packagesResponseList),
      ),
    );
  }
}