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
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../domain/repository/auth/auth_repository.dart' as _i912;
import '../../domain/repository/data_sources/auth_data_source.dart' as _i231;
import '../../domain/use_case/register_use_case.dart' as _i78;
import '../../features/auth/register/register_cubit/register_cubit.dart'
    as _i547;
import '../api/api_manager.dart' as _i1047;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i1047.ApiManager>(() => _i1047.ApiManager());
    gh.factory<_i231.AuthDataSource>(
      () => _i150.AuthRemoteDataSourceImpl(apiManager: gh<_i1047.ApiManager>()),
    );
    gh.factory<_i912.AuthRepository>(
      () =>
          _i895.AuthRepositoryImpl(authDataSource: gh<_i231.AuthDataSource>()),
    );
    gh.factory<_i78.RegisterUseCase>(
      () => _i78.RegisterUseCase(authRepository: gh<_i912.AuthRepository>()),
    );
    gh.factory<_i547.RegisterCubit>(
      () => _i547.RegisterCubit(registerUseCase: gh<_i78.RegisterUseCase>()),
    );
    return this;
  }
}
