import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_time_translation/core/router/app_router.dart';
import 'package:real_time_translation/core/theme/app_theme.dart';
import 'package:real_time_translation/features/subscription/domain/entities/purchase_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase 설정 파일 없을 때 개발 모드로 실행
    debugPrint('Firebase 초기화 실패 (개발 모드): $e');
  }

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Initialize purchase guard to restore Premium status on app start.
    Future.microtask(() {
      ref.read(purchaseGuardProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TravelTalk',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
