import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/presentation/bloc/booking_detail_cubit.dart';
import 'features/booking/presentation/bloc/booking_list_bloc.dart';
import 'features/booking/presentation/bloc/create_booking_bloc.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/notification/presentation/cubit/notification_preferences_cubit.dart';
import 'features/tracking/presentation/bloc/live_tracking_bloc.dart';

class KilatPetRunnerApp extends StatelessWidget {
  const KilatPetRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<HomeCubit>()),
        BlocProvider(create: (_) => getIt<BookingListBloc>()),
        BlocProvider(create: (_) => getIt<BookingDetailCubit>()),
        BlocProvider(create: (_) => getIt<CreateBookingBloc>()),
        BlocProvider(create: (_) => getIt<PaymentCubit>()),
        BlocProvider(create: (_) => getIt<LiveTrackingBloc>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<NotificationCubit>()),
        BlocProvider(create: (_) => getIt<NotificationPreferencesCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Kilat Pet Runner',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
      ),
    );
  }
}
