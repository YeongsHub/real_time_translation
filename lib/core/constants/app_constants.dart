import 'package:real_time_translation/core/config/env_config.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'TravelTalk';

  // Ad frequency: show interstitial every N translations
  static const int adIntervalTranslations = 5;

  // Subscription product IDs — read from .env via EnvConfig at runtime.
  // Kept here as pass-through for convenience; source of truth is .env file.
  static String get premiumMonthlyId => EnvConfig.iapPremiumMonthlyId;
  static String get premiumYearlyId => EnvConfig.iapPremiumYearlyId;
}
