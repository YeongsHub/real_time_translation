import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/core/errors/app_exception.dart';

void main() {
  group('AppException hierarchy', () {
    test('SttException carries message and implements Exception', () {
      const e = SttException('microphone not available');
      expect(e, isA<AppException>());
      expect(e, isA<Exception>());
      expect(e.message, 'microphone not available');
      expect(e.toString(), 'microphone not available');
    });

    test('TranslationException carries message', () {
      const e = TranslationException('model not loaded');
      expect(e, isA<AppException>());
      expect(e.message, 'model not loaded');
    });

    test('TtsException carries message', () {
      const e = TtsException('speaker unavailable');
      expect(e, isA<AppException>());
      expect(e.message, 'speaker unavailable');
    });

    test('NetworkException carries message', () {
      const e = NetworkException('timeout');
      expect(e, isA<AppException>());
      expect(e.message, 'timeout');
    });

    test('PurchaseException carries message', () {
      const e = PurchaseException('purchase cancelled');
      expect(e, isA<AppException>());
      expect(e.message, 'purchase cancelled');
    });

    test('sealed class prevents arbitrary subtypes at runtime', () {
      // All concrete subtypes should be distinguishable via pattern matching
      const AppException e = SttException('test');
      final result = switch (e) {
        SttException() => 'stt',
        TranslationException() => 'translation',
        TtsException() => 'tts',
        NetworkException() => 'network',
        PurchaseException() => 'purchase',
      };
      expect(result, 'stt');
    });
  });
}
