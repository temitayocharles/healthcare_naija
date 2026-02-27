import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'features/home/home_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/symptom_checker/symptom_checker_screen.dart';
import 'features/provider_search/provider_search_screen.dart';
import 'features/appointments/appointments_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/emergency/emergency_screen.dart';
import 'features/telemedicine/telemedicine_screen.dart';
import 'features/health_records/health_records_screen.dart';
import 'widgets/main_scaffold.dart';

class NigeriaHealthCareApp extends ConsumerWidget {
  NigeriaHealthCareApp({super.key});

  final _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
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
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
