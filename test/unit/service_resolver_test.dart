import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/core/network/connectivity_provider.dart';
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:real_time_translation/services/service_resolver.dart';

void main() {
  group('ServiceResolver – serviceModeProvider', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    /// Helper: creates a container with overridden connectivity and premium,
    /// then waits for the stream-based serviceModeProvider to settle.
    Future<AsyncValue<ServiceMode>> resolveServiceMode({
      required Stream<bool> connectivityStream,
      required bool isPremium,
    }) async {
      container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) => connectivityStream),
          isPremiumProvider.overrideWith((ref) => isPremium),
        ],
      );

      // Listen so the stream is subscribed and data flows through.
      final completer = Completer<AsyncValue<ServiceMode>>();
      container.listen<AsyncValue<ServiceMode>>(
        serviceModeProvider,
        (prev, next) {
          if (next is! AsyncLoading && !completer.isCompleted) {
            completer.complete(next);
          }
        },
        fireImmediately: false,
      );

      // Read once to kick off the provider chain
      container.read(serviceModeProvider);

      return completer.future.timeout(const Duration(seconds: 2));
    }

    test('returns online when connected AND premium', () async {
      final mode = await resolveServiceMode(
        connectivityStream: Stream.value(true),
        isPremium: true,
      );

      expect(mode, isA<AsyncData<ServiceMode>>());
      expect(mode.value, ServiceMode.online);
    });

    test('returns offline when connected but NOT premium', () async {
      final mode = await resolveServiceMode(
        connectivityStream: Stream.value(true),
        isPremium: false,
      );

      expect(mode, isA<AsyncData<ServiceMode>>());
      expect(mode.value, ServiceMode.offline);
    });

    test('returns offline when disconnected regardless of premium', () async {
      final mode = await resolveServiceMode(
        connectivityStream: Stream.value(false),
        isPremium: true,
      );

      expect(mode, isA<AsyncData<ServiceMode>>());
      expect(mode.value, ServiceMode.offline);
    });

    test('returns offline when disconnected and not premium', () async {
      final mode = await resolveServiceMode(
        connectivityStream: Stream.value(false),
        isPremium: false,
      );

      expect(mode, isA<AsyncData<ServiceMode>>());
      expect(mode.value, ServiceMode.offline);
    });

    test('falls back to offline on connectivity error', () async {
      final mode = await resolveServiceMode(
        connectivityStream: Stream.error(Exception('no wifi')),
        isPremium: true,
      );

      expect(mode, isA<AsyncData<ServiceMode>>());
      expect(mode.value, ServiceMode.offline);
    });
  });
}
