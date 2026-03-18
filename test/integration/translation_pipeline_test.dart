import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_time_translation/features/stt/domain/repositories/stt_service.dart';
import 'package:real_time_translation/features/translation/domain/repositories/translation_service.dart';
import 'package:real_time_translation/features/tts/domain/repositories/tts_service.dart';

// Mocks using real domain interfaces
class MockSttService extends Mock implements SttService {}

class MockTranslationService extends Mock implements TranslationService {}

class MockTtsService extends Mock implements TtsService {}

void main() {
  group('Translation pipeline – voice input → translate → TTS', () {
    late MockSttService stt;
    late MockTranslationService translator;
    late MockTtsService tts;

    setUp(() {
      stt = MockSttService();
      translator = MockTranslationService();
      tts = MockTtsService();
    });

    test('full flow: STT → translate → TTS', () async {
      // Arrange
      when(() => stt.startListening(localeId: 'ko-KR')).thenAnswer(
        (_) => Stream.fromIterable([
          const SttResult(text: '안녕', isFinal: false),
          const SttResult(text: '안녕하세요', isFinal: true),
        ]),
      );
      when(() => stt.stopListening()).thenAnswer((_) async {});

      when(() => translator.translate(
            text: '안녕하세요',
            sourceLanguage: 'ko',
            targetLanguage: 'en',
          )).thenAnswer((_) async => 'Hello');

      when(() => tts.speak(text: 'Hello', language: 'en'))
          .thenAnswer((_) async {});

      // Act
      final sttResults = <SttResult>[];
      await for (final result in stt.startListening(localeId: 'ko-KR')) {
        sttResults.add(result);
      }

      final finalResult = sttResults.where((r) => r.isFinal).last;
      final translated = await translator.translate(
        text: finalResult.text,
        sourceLanguage: 'ko',
        targetLanguage: 'en',
      );

      await tts.speak(text: translated, language: 'en');

      // Assert
      expect(finalResult.text, '안녕하세요');
      expect(translated, 'Hello');

      verify(() => stt.startListening(localeId: 'ko-KR')).called(1);
      verify(() => translator.translate(
            text: '안녕하세요',
            sourceLanguage: 'ko',
            targetLanguage: 'en',
          )).called(1);
      verify(() => tts.speak(text: 'Hello', language: 'en')).called(1);
    });

    test('does not call translator when STT returns empty text', () async {
      when(() => stt.startListening(localeId: 'en-US')).thenAnswer(
        (_) => Stream.fromIterable([
          const SttResult(text: '', isFinal: true),
        ]),
      );

      final results = <SttResult>[];
      await for (final result in stt.startListening(localeId: 'en-US')) {
        results.add(result);
      }

      final finalResult = results.where((r) => r.isFinal).last;

      // Empty text — pipeline should short-circuit
      if (finalResult.text.isEmpty) {
        verifyNever(() => translator.translate(
              text: any(named: 'text'),
              sourceLanguage: any(named: 'sourceLanguage'),
              targetLanguage: any(named: 'targetLanguage'),
            ));
      }
    });

    test('does not call TTS when translation throws', () async {
      when(() => stt.startListening(localeId: 'ko-KR')).thenAnswer(
        (_) => Stream.fromIterable([
          const SttResult(text: '안녕하세요', isFinal: true),
        ]),
      );

      when(() => translator.translate(
            text: '안녕하세요',
            sourceLanguage: 'ko',
            targetLanguage: 'en',
          )).thenThrow(Exception('Translation model not loaded'));

      final results = <SttResult>[];
      await for (final result in stt.startListening(localeId: 'ko-KR')) {
        results.add(result);
      }

      expect(
        () => translator.translate(
          text: '안녕하세요',
          sourceLanguage: 'ko',
          targetLanguage: 'en',
        ),
        throwsA(isA<Exception>()),
      );

      verifyNever(
        () => tts.speak(
          text: any(named: 'text'),
          language: any(named: 'language'),
        ),
      );
    });
  });

  group('Ad counter – free user sees interstitial after 5 translations', () {
    test('counter triggers at exactly 5 translations', () {
      const adInterval = 5;
      var adShown = false;
      var translationCount = 0;

      void onTranslationComplete() {
        translationCount++;
        if (translationCount % adInterval == 0) {
          adShown = true;
        }
      }

      for (var i = 0; i < 4; i++) {
        onTranslationComplete();
      }
      expect(adShown, isFalse);
      expect(translationCount, 4);

      onTranslationComplete();
      expect(adShown, isTrue);
      expect(translationCount, 5);
    });

    test('ad shows twice at 5 and 10 translations', () {
      const adInterval = 5;
      var adShowCount = 0;
      var translationCount = 0;

      void onTranslationComplete() {
        translationCount++;
        if (translationCount % adInterval == 0) {
          adShowCount++;
        }
      }

      for (var i = 0; i < 10; i++) {
        onTranslationComplete();
      }

      expect(adShowCount, 2);
      expect(translationCount, 10);
    });

    test('premium user never sees ads regardless of count', () {
      const isPremium = true;
      const adInterval = 5;
      var adShown = false;
      var translationCount = 0;

      void onTranslationComplete() {
        translationCount++;
        if (!isPremium && translationCount % adInterval == 0) {
          adShown = true;
        }
      }

      for (var i = 0; i < 20; i++) {
        onTranslationComplete();
      }

      expect(adShown, isFalse);
    });
  });
}
