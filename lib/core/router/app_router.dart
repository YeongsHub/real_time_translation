import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_time_translation/features/translation/presentation/screens/translation_screen.dart';
import 'package:real_time_translation/features/history/presentation/screens/history_screen.dart';
import 'package:real_time_translation/features/settings/presentation/screens/settings_screen.dart';
import 'package:real_time_translation/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:real_time_translation/features/language_pack/presentation/screens/language_pack_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TranslationScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/language-packs',
        builder: (context, state) => const LanguagePackScreen(),
      ),
    ],
  );
});
