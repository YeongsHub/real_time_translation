import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';

/// Guards access to premium features based on subscription status.
/// Listens to purchase updates and maintains isPremium state.
class PurchaseGuard {
  PurchaseGuard(this._ref);

  final Ref _ref;
  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;

  /// Start listening for purchase updates and verify premium status.
  Future<void> initialize() async {
    final inAppPurchase = iap.InAppPurchase.instance;
    final available = await inAppPurchase.isAvailable();
    if (!available) return;

    _subscription = inAppPurchase.purchaseStream.listen(_onPurchaseUpdate);

    // Restore purchases on app start to verify premium status
    await inAppPurchase.restorePurchases();
  }

  void _onPurchaseUpdate(List<iap.PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == iap.PurchaseStatus.purchased ||
          purchase.status == iap.PurchaseStatus.restored) {
        _ref.read(isPremiumProvider.notifier).state = true;
        if (purchase.pendingCompletePurchase) {
          iap.InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

  /// Check if user can access online mode.
  bool canAccessOnlineMode() {
    return _ref.read(isPremiumProvider);
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final purchaseGuardProvider = Provider<PurchaseGuard>((ref) {
  final guard = PurchaseGuard(ref);
  ref.onDispose(() => guard.dispose());
  return guard;
});
