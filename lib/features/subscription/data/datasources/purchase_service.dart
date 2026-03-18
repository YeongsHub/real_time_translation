import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:real_time_translation/core/constants/app_constants.dart';

/// Manages in-app purchase flow for Premium subscriptions.
class PurchaseService {
  PurchaseService() : _iap = InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _statusController = StreamController<PurchaseUpdate>.broadcast();

  /// Stream of purchase update events.
  Stream<PurchaseUpdate> get statusStream => _statusController.stream;

  /// Initialize and listen for purchase updates.
  Future<bool> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        _statusController.addError(error);
      },
    );

    return true;
  }

  /// Query available subscription products.
  Future<List<ProductDetails>> getProducts() async {
    final productIds = {
      AppConstants.premiumMonthlyId,
      AppConstants.premiumYearlyId,
    };

    final response = await _iap.queryProductDetails(productIds);
    return response.productDetails;
  }

  /// Purchase a subscription.
  Future<void> purchaseSubscription(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _statusController.add(PurchaseUpdate.activated);
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        case PurchaseStatus.error:
          _statusController.addError(
            purchase.error?.message ?? 'Purchase failed',
          );
        case PurchaseStatus.pending:
          _statusController.add(PurchaseUpdate.pending);
        case PurchaseStatus.canceled:
          _statusController.add(PurchaseUpdate.canceled);
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }
}

/// Simple purchase update events emitted by PurchaseService.
enum PurchaseUpdate {
  pending,
  activated,
  canceled,
}
