import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/features/pages/profile_screen/cubit/profile_screen_states.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/login_response_entity.dart';
import '../../../../domain/use_case/profile_use_case.dart';

@injectable
class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileUseCase _profileUseCase;

  ProfileCubit(this._profileUseCase) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final result = await _profileUseCase.getCached();
      result.fold(
            (failure) {
          String errorMessage = 'An error occurred while loading data';
          if (failure is CacheFailure) {
            errorMessage = 'No cached data available';
          } else if (failure is ServerError) {
            errorMessage = 'Server error';
          }
          emit(ProfileError(message: errorMessage));
        },
            (parent) {
          emit(ProfileLoaded(parent: parent));
        },
      );
    } catch (e) {
      emit(ProfileError(message: 'An unexpected error occurred'));
    }
  }

  // Future<void> clearProfile() async {
  //   try {
  //     final result = await _profileUseCase.clear();
  //     result.fold(
  //       (failure) {
  //         emit(ProfileError(message: 'An error occurred while clearing data'));
  //       },
  //       (_) {
  //         emit(ProfileInitial());
  //       },
  //     );
  //   } catch (e) {
  //     emit(ProfileError(message: 'An unexpected error occurred'));
  //   }
  // }

  Future<void> cacheProfile(ParentLoginEntity parent) async {
    try {
      final result = await _profileUseCase.cache(parent);
      result.fold(
            (failure) {
          emit(ProfileError(message: 'An error occurred while saving data'));
        },
            (cachedParent) {
          emit(ProfileLoaded(parent: cachedParent));
        },
      );
    } catch (e) {
      emit(ProfileError(message: 'An unexpected error occurred'));
    }
  }
}

//
  // void addStudentLocally(StudentsLoginEntity student) {
  //   if (state is ProfileLoaded) {
  //     final currentParent = (state as ProfileLoaded).parent;
  //     final updatedParent = currentParent.copyWith(
  //       students: [...currentParent.students!, student],
  //     );
  //
  //     // Emit updated state
  //     emit(ProfileLoaded(parent: updatedParent));
  //
  //     // Cache the updated parent
  //     cacheProfile(updatedParent);
  //   }
  // }
  //
  // void addStudent(StudentsLoginEntity student) async {
  //   emit(ProfileLoading());
  //   final result = await _profileUseCase.updateStudents(student);
  //   result.fold(
  //         (failure) => emit(ProfileError(message: failure.errorMsg)),
  //         (updatedParent) => emit(ProfileLoaded(parent: updatedParent)),
  //   );
  // }


