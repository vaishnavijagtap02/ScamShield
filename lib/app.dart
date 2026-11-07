import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/screens/action_plan_screen.dart';
import 'package:scamshield/ui/screens/analysing_screen.dart';
import 'package:scamshield/ui/screens/complaint_screen.dart';
import 'package:scamshield/ui/screens/demo_screen.dart';
import 'package:scamshield/ui/screens/guardians_screen.dart';
import 'package:scamshield/ui/screens/home_screen.dart';
import 'package:scamshield/ui/screens/live_guard_screen.dart';
import 'package:scamshield/ui/screens/questions_screen.dart';
import 'package:scamshield/ui/screens/settings_screen.dart';
import 'package:scamshield/ui/screens/upload_screen.dart';
import 'package:scamshield/ui/screens/verdict_screen.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/analysing',
        builder: (context, state) => const AnalysingScreen(),
      ),
      GoRoute(
        path: '/verdict',
        builder: (context, state) => const VerdictScreen(),
      ),
      GoRoute(
        path: '/questions',
        builder: (context, state) => const QuestionsScreen(),
      ),
      GoRoute(
        path: '/plan',
        builder: (context, state) {
          final answers = state.extra as Answers?;
          return ActionPlanScreen(answers: answers);
        },
      ),
      GoRoute(
        path: '/complaint',
        builder: (context, state) {
          final answers = state.extra as Answers?;
          return ComplaintScreen(answers: answers);
        },
      ),
      GoRoute(
        path: '/live',
        builder: (context, state) => const LiveGuardScreen(),
      ),
      GoRoute(path: '/demo', builder: (context, state) => const DemoScreen()),
      GoRoute(
        path: '/guardians',
        builder: (context, state) => const GuardiansScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class ScamShieldApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    return MaterialApp.router(
      title: s.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
