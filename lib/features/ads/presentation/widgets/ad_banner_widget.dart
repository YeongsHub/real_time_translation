import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:real_time_translation/features/ads/domain/ad_manager.dart';
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';

/// Shows an AdMob banner ad for free users. Hidden for Premium subscribers.
class AdBannerWidget extends ConsumerWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return const SizedBox.shrink();

    final adState = ref.watch(adManagerProvider);

    if (!adState.isBannerLoaded || adState.bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return SizedBox(
      width: adState.bannerAd!.size.width.toDouble(),
      height: adState.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: adState.bannerAd!),
    );
  }
}
