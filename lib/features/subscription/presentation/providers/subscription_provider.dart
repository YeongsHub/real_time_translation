import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Whether the current user has an active Premium subscription.
final isPremiumProvider = StateProvider<bool>((ref) => false);

/// Available subscription products from the store.
final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final iap = InAppPurchase.instance;
  final available = await iap.isAvailable();
  if (!available) return [];

  const productIds = {'premium_monthly', 'premium_yearly'};
  final response = await iap.queryProductDetails(productIds);
  return response.productDetails;
});
