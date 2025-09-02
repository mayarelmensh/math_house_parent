// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/data_sources/offline_data_source/parent_offline_data_source_impl.dart'
    as _i219;
import '../../data/data_sources/online_data_source/auth_remote_data_source_impl.dart'
    as _i150;
import '../../data/data_sources/online_data_source/buy_package_remote_data_sourse_impl.dart'
    as _i625;
import '../../data/data_sources/online_data_source/confirm_code_remote_data_source_impl.dart'
    as _i307;
import '../../data/data_sources/online_data_source/courses_list_remote_data_source_impl.dart'
    as _i550;
import '../../data/data_sources/online_data_source/get_students_remote_data_source_impl.dart'
    as _i496;
import '../../data/data_sources/online_data_source/packages_remote_data_source.dart'
    as _i329;
import '../../data/data_sources/online_data_source/payment_methods_data_sourse_impl.dart'
    as _i207;
import '../../data/data_sources/online_data_source/send_code_remote_data_source_impl.dart'
    as _i86;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/buy_package_repository_impl.dart' as _i66;
import '../../data/repositories/confirm_code_repository_impl.dart' as _i299;
import '../../data/repositories/courses_list_repository_impl.dart' as _i14;
import '../../data/repositories/get_students_repository_impl.dart' as _i894;
import '../../data/repositories/packages_repository_impl.dart' as _i576;
import '../../data/repositories/payment_methods_repository_impl.dart' as _i721;
import '../../data/repositories/profile_repository_impl.dart' as _i813;
import '../../data/repositories/send_code_repository_impl.dart' as _i862;
import '../../domain/repository/auth/auth_repository.dart' as _i912;
import '../../domain/repository/buy_package/buy_package_repository.dart'
    as _i138;
import '../../domain/repository/courses_list/courses_list_repository.dart'
    as _i1066;
import '../../domain/repository/data_sources/offline_data_source/profile_offline_data_source.dart'
    as _i530;
import '../../domain/repository/data_sources/remote_data_source/auth_data_source.dart'
    as _i852;
import '../../domain/repository/data_sources/remote_data_source/buy_package_data_sourse.dart'
    as _i441;
import '../../domain/repository/data_sources/remote_data_source/confirm_code_data_source.dart'
    as _i698;
import '../../domain/repository/data_sources/remote_data_source/courses_list_data_source.dart'
    as _i126;
import '../../domain/repository/data_sources/remote_data_source/get_students_data_source.dart'
    as _i846;
import '../../domain/repository/data_sources/remote_data_source/packages_data_source.dart'
    as _i1010;
import '../../domain/repository/data_sources/remote_data_source/payment_methods_data_sourse.dart'
    as _i724;
import '../../domain/repository/data_sources/remote_data_source/send_code_data_source.dart'
    as _i486;
import '../../domain/repository/getStudents/confirm_code_repository.dart'
    as _i180;
import '../../domain/repository/getStudents/get_students_repository.dart'
    as _i1042;
import '../../domain/repository/getStudents/send_code_to_student_repository.dart'
    as _i74;
import '../../domain/repository/packages/packages_repository.dart' as _i792;
import '../../domain/repository/payment_methods/payment_methods_repository.dart'
    as _i837;
import '../../domain/repository/profile/profile_repository.dart' as _i742;
import '../../domain/use_case/buy_package_use_case.dart' as _i1015;
import '../../domain/use_case/confirm_code_use_case.dart' as _i708;
import '../../domain/use_case/courses_list_use_case.dart' as _i580;
import '../../domain/use_case/get_students_use_case.dart' as _i40;
import '../../domain/use_case/login_use_case.dart' as _i461;
import '../../domain/use_case/packages_use_case.dart' as _i869;
import '../../domain/use_case/payment_methods_use_case.dart' as _i290;
import '../../domain/use_case/profile_use_case.dart' as _i591;
import '../../domain/use_case/register_use_case.dart' as _i78;
import '../../domain/use_case/send_code_to_student_use_case.dart' as _i359;
import '../../features/auth/login/login_cubit/login_cubit.dart' as _i969;
import '../../features/auth/register/register_cubit/register_cubit.dart'
    as _i547;
import '../../features/pages/courses_screen/cubit/courses_cubit.dart' as _i91;
import '../../features/pages/packages_screen/cubit/packages_cubit.dart'
    as _i868;
import '../../features/pages/payment_methods/cubit/buy_package_cubit.dart'
    as _i161;
import '../../features/pages/payment_methods/cubit/payment_methods_cubit.dart'
    as _i354;
import '../../features/pages/profile_screen/cubit/profile_screen_cubit.dart'
    as _i314;
import '../../features/pages/students_screen/cubit/confirm_code_cubit.dart'
    as _i36;
import '../../features/pages/students_screen/cubit/send_code_cubit.dart'
    as _i1019;
import '../../features/pages/students_screen/cubit/students_screen_cubit.dart'
    as _i89;
import '../api/api_manager.dart' as _i1047;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i1047.ApiManager>(() => _i1047.ApiManager());
    gh.factory<_i530.ProfileLocalDataSource>(
      () => _i219.ProfileLocalDataSourceImpl(),
    );
    gh.factory<_i441.BuyPackageRemoteDataSource>(
      () => _i625.BuyPackageRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.factory<_i724.PaymentMethodsRemoteDataSource>(
      () => _i207.PaymentMethodsRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.factory<_i742.ProfileRepository>(
      () => _i813.ProfileRepositoryImpl(
        localDataSource: gh<_i530.ProfileLocalDataSource>(),
      ),
    );
    gh.factory<_i698.ConfirmCodeDataSource>(
      () => _i307.ConfirmCodeRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i852.AuthDataSource>(
      () => _i150.AuthRemoteDataSourceImpl(apiManager: gh<_i1047.ApiManager>()),
    );
    gh.factory<_i138.BuyPackageRepository>(
      () =>
          _i66.BuyPackageRepositoryImpl(gh<_i441.BuyPackageRemoteDataSource>()),
    );
    gh.factory<_i1010.PackagesRemoteDataSource>(
      () => _i329.PackagesRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i846.GetStudentsRemoteDataSource>(
      () => _i496.GetStudentsRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i126.CoursesListDataSource>(
      () => _i550.CoursesListRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i486.SendCodeDataSource>(
      () => _i86.SendCodeRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i180.ConfirmCodeRepository>(
      () => _i299.ConfirmCodeRepositoryImpl(
        confirmCodeDataSource: gh<_i698.ConfirmCodeDataSource>(),
      ),
    );
    gh.factory<_i1042.GetStudentsRepository>(
      () => _i894.GetStudentsRepositoryImpl(
        getStudentsDataSource: gh<_i846.GetStudentsRemoteDataSource>(),
      ),
    );
    gh.factory<_i837.PaymentMethodsRepository>(
      () => _i721.PaymentMethodsRepositoryImpl(
        gh<_i724.PaymentMethodsRemoteDataSource>(),
      ),
    );
    gh.factory<_i1066.CoursesListRepository>(
      () => _i14.CoursesListRepositoryImpl(
        coursesListDataSource: gh<_i126.CoursesListDataSource>(),
      ),
    );
    gh.factory<_i912.AuthRepository>(
      () => _i895.AuthRepositoryImpl(
        authDataSource: gh<_i852.AuthDataSource>(),
        profileLocalDataSource: gh<_i530.ProfileLocalDataSource>(),
      ),
    );
    gh.factory<_i40.GetStudentsUseCase>(
      () => _i40.GetStudentsUseCase(gh<_i1042.GetStudentsRepository>()),
    );
    gh.factory<_i591.ProfileUseCase>(
      () => _i591.ProfileUseCase(repository: gh<_i742.ProfileRepository>()),
    );
    gh.factory<_i290.GetPaymentMethodsUseCase>(
      () =>
          _i290.GetPaymentMethodsUseCase(gh<_i837.PaymentMethodsRepository>()),
    );
    gh.factory<_i580.CoursesListUseCase>(
      () => _i580.CoursesListUseCase(
        coursesListRepository: gh<_i1066.CoursesListRepository>(),
      ),
    );
    gh.factory<_i91.CoursesCubit>(
      () =>
          _i91.CoursesCubit(coursesListUseCase: gh<_i580.CoursesListUseCase>()),
    );
    gh.factory<_i461.LoginUseCase>(
      () => _i461.LoginUseCase(authRepository: gh<_i912.AuthRepository>()),
    );
    gh.factory<_i78.RegisterUseCase>(
      () => _i78.RegisterUseCase(authRepository: gh<_i912.AuthRepository>()),
    );
    gh.lazySingleton<_i1015.BuyPackageUseCase>(
      () => _i1015.BuyPackageUseCase(gh<_i138.BuyPackageRepository>()),
    );
    gh.factory<_i792.PackagesRepository>(
      () => _i576.PackagesRepositoryImpl(
        packagesRemoteDataSource: gh<_i1010.PackagesRemoteDataSource>(),
      ),
    );
    gh.factory<_i74.SendCodeToStudentRepository>(
      () => _i862.SendCodeRepositoryImpl(
        sendCodeDataSource: gh<_i486.SendCodeDataSource>(),
      ),
    );
    gh.factory<_i969.LoginCubit>(
      () => _i969.LoginCubit(loginUseCase: gh<_i461.LoginUseCase>()),
    );
    gh.factory<_i708.ConfirmCodeUseCase>(
      () => _i708.ConfirmCodeUseCase(
        confirmCodeRepository: gh<_i180.ConfirmCodeRepository>(),
      ),
    );
    gh.factory<_i354.PaymentMethodsCubit>(
      () => _i354.PaymentMethodsCubit(gh<_i290.GetPaymentMethodsUseCase>()),
    );
    gh.factory<_i314.ProfileCubit>(
      () => _i314.ProfileCubit(gh<_i591.ProfileUseCase>()),
    );
    gh.factory<_i547.RegisterCubit>(
      () => _i547.RegisterCubit(registerUseCase: gh<_i78.RegisterUseCase>()),
    );
    gh.factory<_i869.PackagesUseCase>(
      () => _i869.PackagesUseCase(
        packagesRepository: gh<_i792.PackagesRepository>(),
      ),
    );
    gh.factory<_i161.BuyPackageCubit>(
      () => _i161.BuyPackageCubit(gh<_i1015.BuyPackageUseCase>()),
    );
    gh.factory<_i359.SendCodeUseCase>(
      () => _i359.SendCodeUseCase(
        sendCodeToStudentRepository: gh<_i74.SendCodeToStudentRepository>(),
      ),
    );
    gh.factory<_i36.ConfirmCodeCubit>(
      () => _i36.ConfirmCodeCubit(
        confirmCodeUseCase: gh<_i708.ConfirmCodeUseCase>(),
      ),
    );
    gh.factory<_i89.GetStudentsCubit>(
      () => _i89.GetStudentsCubit(
        gh<_i40.GetStudentsUseCase>(),
        gh<_i359.SendCodeUseCase>(),
      ),
    );
    gh.factory<_i868.PackagesCubit>(
      () => _i868.PackagesCubit(packagesUseCase: gh<_i869.PackagesUseCase>()),
    );
    gh.factory<_i1019.SendCodeCubit>(
      () => _i1019.SendCodeCubit(sendCodeUseCase: gh<_i359.SendCodeUseCase>()),
    );
    return this;
  }
}
