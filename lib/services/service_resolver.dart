import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_time_translation/core/network/connectivity_provider.dart';
import 'package:real_time_translation/features/stt/data/datasources/cloud_stt_service.dart';
import 'package:real_time_translation/features/stt/data/datasources/device_stt_service.dart';
import 'package:real_time_translation/features/stt/domain/repositories/stt_service.dart';
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:real_time_translation/features/translation/data/datasources/cloud_translation_service.dart';
import 'package:real_time_translation/features/translation/data/datasources/ml_kit_translation_service.dart';
import 'package:real_time_translation/features/translation/domain/repositories/translation_service.dart';
import 'package:real_time_translation/features/tts/data/datasources/native_tts_service.dart';
import 'package:real_time_translation/features/tts/domain/repositories/tts_service.dart';
import 'package:real_time_translation/services/config_service.dart';

enum ServiceMode { offline, online }

/// Resolves the current service mode based on connectivity + subscription.
final serviceModeProvider = Provider<AsyncValue<ServiceMode>>((ref) {
  final isOnline = ref.watch(connectivityProvider);
  final isPremium = ref.watch(isPremiumProvider);

  return isOnline.when(
    data: (online) {
      if (online && isPremium) {
        return const AsyncData(ServiceMode.online);
      }
      return const AsyncData(ServiceMode.offline);
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => const AsyncData(ServiceMode.offline),
  );
});

/// Dio instance shared across cloud services.
final dioProvider = Provider<Dio>((ref) => Dio());

/// Provides the appropriate SttService based on service mode.
final sttServiceProvider = Provider<SttService>((ref) {
  final mode = ref.watch(serviceModeProvider);

  return mode.when(
    data: (m) {
      switch (m) {
        case ServiceMode.online:
          final config = ref.watch(configServiceProvider).valueOrNull;
          return CloudSttService(
            dio: ref.read(dioProvider),
            proxyBaseUrl: config?.proxyBaseUrl ?? '',
          );
        case ServiceMode.offline:
          return DeviceSttService();
      }
    },
    loading: () => DeviceSttService(),
    error: (_, _) => DeviceSttService(),
  );
});

/// Provides the appropriate TranslationService based on service mode.
final translationServiceProvider = Provider<TranslationService>((ref) {
  final mode = ref.watch(serviceModeProvider);

  return mode.when(
    data: (m) {
      switch (m) {
        case ServiceMode.online:
          final config = ref.watch(configServiceProvider).valueOrNull;
          return CloudTranslationService(
            dio: ref.read(dioProvider),
            proxyBaseUrl: config?.proxyBaseUrl ?? '',
          );
        case ServiceMode.offline:
          return MlKitTranslationService();
      }
    },
    loading: () => MlKitTranslationService(),
    error: (_, _) => MlKitTranslationService(),
  );
});

/// TTS always uses the native engine.
final ttsServiceProvider = Provider<TtsService>((ref) => NativeTtsService());
