import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import 'package:get_it/get_it.dart';
import '../../features/booking/presentation/screens/booking_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_list_screen.dart';
import '../../features/booking/presentation/screens/create_booking_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/notification/presentation/screens/notification_list_screen.dart';
import '../../features/notification/presentation/screens/notification_preferences_screen.dart';
import '../../features/payment/presentation/cubit/payment_cubit.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/tracking/presentation/screens/live_tracking_screen.dart';
import '../../features/runner/presentation/cubit/nearby_runners_cubit.dart';
import '../../features/runner/presentation/screens/nearby_runners_screen.dart';
import '../../features/petshop/presentation/cubit/pet_shop_cubit.dart';
import '../../features/petshop/presentation/cubit/pet_shop_detail_cubit.dart';
import '../../features/petshop/presentation/screens/pet_shop_list_screen.dart';
import '../../features/petshop/presentation/screens/pet_shop_detail_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => _AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (_, __) => const BookingListScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/bookings/create',
        builder: (_, __) => const CreateBookingScreen(),
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (_, state) => BookingDetailScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/bookings/:id/payment',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider(
            create: (_) => GetIt.instance<PaymentCubit>(),
            child: PaymentScreen(
              bookingId: state.pathParameters['id']!,
              amountCents: extra['amountCents'] as int? ?? 0,
              currency: extra['currency'] as String? ?? 'MYR',
            ),
          );
        },
      ),
      GoRoute(
        path: '/bookings/:id/tracking',
        builder: (_, state) => LiveTrackingScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/notifications/settings',
        builder: (_, __) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/runners/nearby',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<NearbyRunnersCubit>(),
          child: const NearbyRunnersScreen(),
        ),
      ),
      GoRoute(
        path: '/petshops',
        builder: (_, __) => BlocProvider(
          create: (_) => GetIt.instance<PetShopCubit>(),
          child: const PetShopListScreen(),
        ),
      ),
      GoRoute(
        path: '/petshops/:id',
        builder: (_, state) => BlocProvider(
          create: (_) => GetIt.instance<PetShopDetailCubit>(),
          child: PetShopDetailScreen(
            shopId: state.pathParameters['id']!,
          ),
        ),
      ),
    ],
  );
}

class _AppScaffold extends StatelessWidget {
  final Widget child;
  const _AppScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notifState) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _calculateIndex(context),
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                case 1:
                  context.go('/bookings');
                case 2:
                  context.go('/notifications');
                case 3:
                  context.go('/profile');
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: notifState.unreadCount > 0,
                  label: Text(
                    notifState.unreadCount > 99
                        ? '99+'
                        : '${notifState.unreadCount}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: const Icon(Icons.notifications),
                ),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}

/// Converts a Bloc stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
