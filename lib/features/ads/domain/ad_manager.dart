import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:real_time_translation/core/config/env_config.dart';
import 'package:real_time_translation/core/constants/app_constants.dart';
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:real_time_translation/features/translation/presentation/providers/conversation_provider.dart';

/// Manages AdMob banner and interstitial ads.
/// Disables all ads for Premium subscribers.
class AdManager extends StateNotifier<AdManagerState> {
  AdManager(this._ref) : super(const AdManagerState()) {
    _init();
  }

  final Ref _ref;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  void _init() {
    MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    if (_ref.read(isPremiumProvider)) return;

    _bannerAd = BannerAd(
      adUnitId: EnvConfig.admobBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = state.copyWith(isBannerLoaded: true, bannerAd: ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = state.copyWith(isBannerLoaded: false);
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (_ref.read(isPremiumProvider)) return;

    InterstitialAd.load(
      adUnitId: EnvConfig.admobInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          state = state.copyWith(isInterstitialLoaded: true);
        },
        onAdFailedToLoad: (error) {
          state = state.copyWith(isInterstitialLoaded: false);
        },
      ),
    );
  }

  /// Show interstitial ad if translation count reached the threshold.
  /// Returns true if ad was shown.
  bool maybeShowInterstitial() {
    if (_ref.read(isPremiumProvider)) return false;

    final count = _ref.read(conversationProvider).translationCount;
    if (count > 0 && count % AppConstants.adIntervalTranslations == 0) {
      return _showInterstitial();
    }
    return false;
  }

  bool _showInterstitial() {
    if (_interstitialAd == null) return false;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    state = state.copyWith(isInterstitialLoaded: false);
    return true;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

}

class AdManagerState {
  const AdManagerState({
    this.isBannerLoaded = false,
    this.isInterstitialLoaded = false,
    this.bannerAd,
  });

  final bool isBannerLoaded;
  final bool isInterstitialLoaded;
  final BannerAd? bannerAd;

  AdManagerState copyWith({
    bool? isBannerLoaded,
    bool? isInterstitialLoaded,
    BannerAd? bannerAd,
  }) {
    return AdManagerState(
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      isInterstitialLoaded: isInterstitialLoaded ?? this.isInterstitialLoaded,
      bannerAd: bannerAd ?? this.bannerAd,
    );
  }
}

final adManagerProvider = StateNotifierProvider<AdManager, AdManagerState>(
  (ref) => AdManager(ref),
);
