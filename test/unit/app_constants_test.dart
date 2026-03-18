import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('adIntervalTranslations is 5', () {
      expect(AppConstants.adIntervalTranslations, 5);
    });

    // subscription product IDs are now loaded from .env via EnvConfig;
    // tested in integration tests where dotenv is initialized.

    test('app name is TravelTalk', () {
      expect(AppConstants.appName, 'TravelTalk');
    });
  });
}
