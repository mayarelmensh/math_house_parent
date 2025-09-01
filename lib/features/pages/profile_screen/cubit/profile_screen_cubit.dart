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
          String errorMessage = 'حدث خطأ في تحميل البيانات';
          if (failure is CacheFailure) {
            errorMessage = 'لا توجد بيانات محفوظة';
          } else if (failure is ServerError) {
            errorMessage = 'خطأ في الخادم';
          }
          emit(ProfileError(message: errorMessage));
        },
            (parent) {
          emit(ProfileLoaded(parent: parent));
        },
      );
    } catch (e) {
      emit(ProfileError(message: 'حدث خطأ غير متوقع'));
    }
  }

  // Future<void> clearProfile() async {
  //   try {
  //     final result = await _profileUseCase.clear();
  //     result.fold(
  //           (failure) {
  //         emit(ProfileError(message: 'حدث خطأ في مسح البيانات'));
  //       },
  //           (_) {
  //         emit(ProfileInitial());
  //       },
  //     );
  //   } catch (e) {
  //     emit(ProfileError(message: 'حدث خطأ غير متوقع'));
  //   }
  // }

  Future<void> cacheProfile(ParentLoginEntity parent) async {
    try {
      final result = await _profileUseCase.cache(parent);
      result.fold(
            (failure) {
          emit(ProfileError(message: 'حدث خطأ في حفظ البيانات'));
        },
            (cachedParent) {
          emit(ProfileLoaded(parent: cachedParent));
        },
      );
    } catch (e) {
      emit(ProfileError(message: 'حدث خطأ غير متوقع'));
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
}

