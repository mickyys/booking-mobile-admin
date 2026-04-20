import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reservaloya_admin/core/network/network_info.dart';
import 'package:reservaloya_admin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:reservaloya_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:reservaloya_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:reservaloya_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:reservaloya_admin/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:reservaloya_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:reservaloya_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/cancel_booking_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/agenda_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_agenda_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_sport_center_settings_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/update_sport_center_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/settings_bloc.dart';
import 'package:reservaloya_admin/features/recurring/data/datasources/recurring_remote_data_source.dart';
import 'package:reservaloya_admin/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/get_recurring_series_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/cancel_recurring_reservation_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/delete_series_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/create_recurring_reservation_usecase.dart';
import 'package:reservaloya_admin/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:reservaloya_admin/features/users/data/datasources/users_remote_data_source.dart';
import 'package:reservaloya_admin/features/users/data/repositories/users_repository_impl.dart';
import 'package:reservaloya_admin/features/users/domain/repositories/users_repository.dart';
import 'package:reservaloya_admin/features/users/domain/usecases/get_users_usecase.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: sl()));
  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton(() => Dio());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth0: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => SocialLoginUseCase(repository: sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), socialLoginUseCase: sl()));

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetDashboardDataUseCase(repository: sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAgendaUseCase(repository: sl()));
  sl.registerFactory(() => DashboardBloc(
    getDashboardDataUseCase: sl(),
    cancelBookingUseCase: sl(),
  ));
  sl.registerFactory(() => AgendaBloc(getAgendaUseCase: sl()));

  sl.registerLazySingleton(() => GetSportCenterSettingsUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateSportCenterUseCase(repository: sl()));
  sl.registerFactory(() => SettingsBloc(
    getSportCenterSettingsUseCase: sl(),
    updateSportCenterUseCase: sl(),
  ));

  sl.registerLazySingleton<RecurringRemoteDataSource>(
    () => RecurringRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RecurringRepository>(
    () => RecurringRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetRecurringSeriesUseCase(repository: sl()));
  sl.registerLazySingleton(() => CancelRecurringReservationUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteSeriesUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateRecurringReservationUseCase(repository: sl()));
  sl.registerFactory(() => RecurringBloc(
    getRecurringSeriesUseCase: sl(),
    cancelRecurringReservationUseCase: sl(),
    deleteSeriesUseCase: sl(),
  ));

  sl.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetUsersUseCase(repository: sl()));
  sl.registerFactory(() => UsersBloc(getUsersUseCase: sl()));
}