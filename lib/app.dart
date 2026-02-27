import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'core/config/feature_flags.dart';
import 'features/home/home_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/symptom_checker/symptom_checker_screen.dart';
import 'features/provider_search/provider_search_screen.dart';
import 'features/appointments/appointments_screen.dart';
import 'features/appointments/booking_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/sync_diagnostics_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/emergency/emergency_screen.dart';
import 'features/telemedicine/telemedicine_screen.dart';
import 'features/health_records/health_records_screen.dart';
import 'models/provider.dart' as model;
import 'widgets/main_scaffold.dart';
import 'widgets/feature_unavailable_screen.dart';

class NigeriaHealthCareApp extends ConsumerStatefulWidget {
  const NigeriaHealthCareApp({super.key});

  @override
  ConsumerState<NigeriaHealthCareApp> createState() =>
      _NigeriaHealthCareAppState();
}

class _NigeriaHealthCareAppState extends ConsumerState<NigeriaHealthCareApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final user = ref.read(currentUserProvider);
        final isAuthRoute = state.uri.path == '/login';
        if (user == null && !isAuthRoute) {
          return '/login';
        }
        if (user != null && isAuthRoute) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(
              path: '/symptoms',
              builder: (context, state) => const SymptomCheckerScreen(),
            ),
            GoRoute(
              path: '/providers',
              builder: (context, state) => const ProviderSearchScreen(),
            ),
            GoRoute(
              path: '/appointments',
              builder: (context, state) => const AppointmentsScreen(),
            ),
            GoRoute(
              path: '/booking',
              builder: (context, state) {
                final provider = state.extra as model.HealthcareProvider?;
                if (provider == null) {
                  return const AppointmentsScreen();
                }
                return BookingScreen(provider: provider);
              },
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/sync-diagnostics',
              builder: (context, state) => const SyncDiagnosticsScreen(),
            ),
            GoRoute(
              path: '/chat',
              builder: (context, state) {
                final chatEnabled = ref.read(
                  featureEnabledProvider(FeatureFlagKeys.chatEnabled),
                );
                if (!chatEnabled) {
                  return const FeatureUnavailableScreen(
                    title: 'Chat',
                    message:
                        'Messaging is currently disabled. Please try again later.',
                  );
                }
                return ChatScreen(
                  initialCaregiverId: state.uri.queryParameters['caregiverId'],
                );
              },
            ),
            GoRoute(
              path: '/emergency',
              builder: (context, state) => const EmergencyScreen(),
            ),
            GoRoute(
              path: '/telemedicine',
              builder: (context, state) => const TelemedicineScreen(),
            ),
            GoRoute(
              path: '/records',
              builder: (context, state) => const HealthRecordsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncQueueServiceProvider).flushQueue();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(syncQueueServiceProvider);

    return MaterialApp.router(
      title: 'Nigeria Health Care',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
