import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';

void main() {
  group('isPremiumProvider (PurchaseGuard)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('defaults to false (free user)', () {
      expect(container.read(isPremiumProvider), isFalse);
    });

    test('can be set to true (premium user)', () {
      container.read(isPremiumProvider.notifier).state = true;
      expect(container.read(isPremiumProvider), isTrue);
    });

    test('can toggle back to free', () {
      container.read(isPremiumProvider.notifier).state = true;
      expect(container.read(isPremiumProvider), isTrue);

      container.read(isPremiumProvider.notifier).state = false;
      expect(container.read(isPremiumProvider), isFalse);
    });
  });
}
