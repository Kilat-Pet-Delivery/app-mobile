import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/websocket/ws_manager.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/presentation/bloc/booking_detail_cubit.dart';
import 'features/booking/presentation/bloc/booking_list_bloc.dart';
import 'features/booking/presentation/bloc/create_booking_bloc.dart';

import 'features/home/presentation/cubit/home_cubit.dart';

import 'features/runner/data/repositories/runner_repository_impl.dart';
import 'features/runner/domain/repositories/runner_repository.dart';
import 'features/runner/presentation/cubit/nearby_runners_cubit.dart';

import 'features/petshop/data/repositories/pet_shop_repository_impl.dart';
import 'features/petshop/domain/repositories/pet_shop_repository.dart';
import 'features/petshop/presentation/cubit/pet_shop_cubit.dart';
import 'features/petshop/presentation/cubit/pet_shop_detail_cubit.dart';

import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';

import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/notification/presentation/cubit/notification_preferences_cubit.dart';

import 'features/profile/presentation/cubit/profile_cubit.dart';

import 'features/tracking/data/repositories/tracking_repository_impl.dart';
import 'features/tracking/domain/repositories/tracking_repository.dart';
import 'features/tracking/presentation/bloc/live_tracking_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Config
  getIt.registerSingleton<AppConfig>(AppConfig.dev());

  // Storage
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Network
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: getIt(), config: getIt()),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(config: getIt(), authInterceptor: getIt()),
  );
  getIt.registerLazySingleton<WebSocketManager>(
    () => WebSocketManager(storage: getIt(), config: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<RunnerRepository>(
    () => RunnerRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<PetShopRepository>(
    () => PetShopRepositoryImpl(getIt()),
  );

  // Blocs & Cubits
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt(), storage: getIt()),
  );

  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt(), getIt()),
  );
  getIt.registerFactory<BookingListBloc>(
    () => BookingListBloc(getIt()),
  );
  getIt.registerFactory<BookingDetailCubit>(
    () => BookingDetailCubit(getIt(), getIt()),
  );
  getIt.registerFactory<CreateBookingBloc>(
    () => CreateBookingBloc(getIt(), getIt()),
  );
  getIt.registerFactory<PaymentCubit>(
    () => PaymentCubit(getIt()),
  );
  getIt.registerFactory<LiveTrackingBloc>(
    () => LiveTrackingBloc(getIt(), getIt()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt(), getIt()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(getIt()),
  );
  getIt.registerFactory<NotificationPreferencesCubit>(
    () => NotificationPreferencesCubit(getIt()),
  );
  getIt.registerFactory<NearbyRunnersCubit>(
    () => NearbyRunnersCubit(getIt()),
  );
  getIt.registerFactory<PetShopCubit>(
    () => PetShopCubit(getIt()),
  );
  getIt.registerFactory<PetShopDetailCubit>(
    () => PetShopDetailCubit(getIt()),
  );

  // Router
  getIt.registerLazySingleton<AppRouter>(
    () => AppRouter(getIt()),
  );
}
