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

import '../../data/data_sources/online_data_source/auth_remote_data_source_impl.dart'
    as _i150;
import '../../data/data_sources/online_data_source/confirm_code_remote_data_source_impl.dart'
    as _i307;
import '../../data/data_sources/online_data_source/get_students_remote_data_source.dart'
    as _i1063;
import '../../data/data_sources/online_data_source/send_code_remote_data_source.dart'
    as _i412;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/confirm_code_repository_impl.dart' as _i299;
import '../../data/repositories/get_students_repository_impl.dart' as _i894;
import '../../data/repositories/send_code_repository_impl.dart' as _i862;
import '../../domain/repository/auth/auth_repository.dart' as _i912;
import '../../domain/repository/data_sources/auth_data_source.dart' as _i231;
import '../../domain/repository/data_sources/confirm_code_data_source.dart'
    as _i115;
import '../../domain/repository/data_sources/get_students_data_source.dart'
    as _i873;
import '../../domain/repository/data_sources/send_code_data_source.dart'
    as _i663;
import '../../domain/repository/getStudents/confirm_code_repository.dart'
    as _i180;
import '../../domain/repository/getStudents/get_students_repository.dart'
    as _i1042;
import '../../domain/repository/getStudents/send_code_to_student_repository.dart'
    as _i74;
import '../../domain/use_case/confirm_code_use_case.dart' as _i708;
import '../../domain/use_case/get_students_use_case.dart' as _i40;
import '../../domain/use_case/login_use_case.dart' as _i461;
import '../../domain/use_case/register_use_case.dart' as _i78;
import '../../domain/use_case/send_code_to_student_use_case.dart' as _i359;
import '../../features/auth/login/login_cubit/login_cubit.dart' as _i969;
import '../../features/auth/register/register_cubit/register_cubit.dart'
    as _i547;
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
    gh.factory<_i873.GetStudentsDataSource>(
      () => _i1063.GetStudentsRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i663.SendCodeDataSource>(
      () => _i412.SendCodeRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i1042.GetStudentsRepository>(
      () => _i894.GetStudentsRepositoryImpl(
        getStudentsDataSource: gh<_i873.GetStudentsDataSource>(),
      ),
    );
    gh.factory<_i115.ConfirmCodeDataSource>(
      () => _i307.ConfirmCodeRemoteDataSourceImpl(
        apiManager: gh<_i1047.ApiManager>(),
      ),
    );
    gh.factory<_i231.AuthDataSource>(
      () => _i150.AuthRemoteDataSourceImpl(apiManager: gh<_i1047.ApiManager>()),
    );
    gh.factory<_i74.SendCodeToStudentRepository>(
      () => _i862.SendCodeRepositoryImpl(
        sendCodeDataSource: gh<_i663.SendCodeDataSource>(),
      ),
    );
    gh.factory<_i180.ConfirmCodeRepository>(
      () => _i299.ConfirmCodeRepositoryImpl(
        confirmCodeDataSource: gh<_i115.ConfirmCodeDataSource>(),
      ),
    );
    gh.factory<_i40.GetStudentsUseCase>(
      () => _i40.GetStudentsUseCase(gh<_i1042.GetStudentsRepository>()),
    );
    gh.factory<_i912.AuthRepository>(
      () =>
          _i895.AuthRepositoryImpl(authDataSource: gh<_i231.AuthDataSource>()),
    );
    gh.factory<_i359.SendCodeUseCase>(
      () => _i359.SendCodeUseCase(
        sendCodeToStudentRepository: gh<_i74.SendCodeToStudentRepository>(),
      ),
    );
    gh.factory<_i461.LoginUseCase>(
      () => _i461.LoginUseCase(authRepository: gh<_i912.AuthRepository>()),
    );
    gh.factory<_i78.RegisterUseCase>(
      () => _i78.RegisterUseCase(authRepository: gh<_i912.AuthRepository>()),
    );
    gh.factory<_i89.GetStudentsCubit>(
      () => _i89.GetStudentsCubit(
        gh<_i40.GetStudentsUseCase>(),
        gh<_i359.SendCodeUseCase>(),
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
    gh.factory<_i547.RegisterCubit>(
      () => _i547.RegisterCubit(registerUseCase: gh<_i78.RegisterUseCase>()),
    );
    gh.factory<_i1019.SendCodeCubit>(
      () => _i1019.SendCodeCubit(sendCodeUseCase: gh<_i359.SendCodeUseCase>()),
    );
    return this;
  }
}
