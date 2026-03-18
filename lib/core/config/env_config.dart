import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment variables loaded from .env file.
/// All sensitive values (API keys, ad unit IDs, endpoints) are read from here.
/// Never hardcode secrets in source files — use this class instead.
class EnvConfig {
  EnvConfig._();

  // --- AdMob Ad Unit IDs ---

  static String get admobBannerAdUnitId {
    if (Platform.isIOS) {
      return dotenv.get('ADMOB_BANNER_AD_UNIT_ID_IOS', fallback: '');
    }
    return dotenv.get('ADMOB_BANNER_AD_UNIT_ID_ANDROID', fallback: '');
  }

  static String get admobInterstitialAdUnitId {
    if (Platform.isIOS) {
      return dotenv.get('ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS', fallback: '');
    }
    return dotenv.get('ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID', fallback: '');
  }

  static String get admobRewardedAdUnitId {
    if (Platform.isIOS) {
      return dotenv.get('ADMOB_REWARDED_AD_UNIT_ID_IOS', fallback: '');
    }
    return dotenv.get('ADMOB_REWARDED_AD_UNIT_ID_ANDROID', fallback: '');
  }

  // --- Cloud Functions Proxy ---

  static String get proxyBaseUrl {
    return dotenv.get('PROXY_BASE_URL', fallback: '');
  }

  // --- Firebase ---

  static String get firebaseProjectId {
    return dotenv.get('FIREBASE_PROJECT_ID', fallback: '');
  }

  // --- In-App Purchase Product IDs ---

  static String get iapPremiumMonthlyId {
    return dotenv.get('IAP_PREMIUM_MONTHLY_ID', fallback: 'premium_monthly');
  }

  static String get iapPremiumYearlyId {
    return dotenv.get('IAP_PREMIUM_YEARLY_ID', fallback: 'premium_yearly');
  }
}
