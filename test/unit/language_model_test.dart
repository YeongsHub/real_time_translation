import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_translation/features/translation/domain/models/language.dart';
import 'package:real_time_translation/features/language_pack/domain/models/language_pack.dart';

void main() {
  group('Language', () {
    test('supported list has 10 languages', () {
      expect(Language.supported.length, 10);
    });

    test('all languages have non-empty fields', () {
      for (final lang in Language.supported) {
        expect(lang.code, isNotEmpty);
        expect(lang.name, isNotEmpty);
        expect(lang.nativeName, isNotEmpty);
        expect(lang.flagEmoji, isNotEmpty);
      }
    });

    test('language codes are unique', () {
      final codes = Language.supported.map((l) => l.code).toSet();
      expect(codes.length, Language.supported.length);
    });

    test('contains Korean and English', () {
      final codes = Language.supported.map((l) => l.code).toList();
      expect(codes, contains('ko'));
      expect(codes, contains('en'));
    });
  });

  group('LanguagePack', () {
    const korean = Language(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      flagEmoji: '\u{1F1F0}\u{1F1F7}',
    );

    test('isFullyReady returns true only when all services ready', () {
      const pack = LanguagePack(
        language: korean,
        sttReady: true,
        translationReady: true,
        ttsReady: true,
      );
      expect(pack.isFullyReady, isTrue);
    });

    test('isFullyReady returns false when any service not ready', () {
      const pack = LanguagePack(
        language: korean,
        sttReady: true,
        translationReady: false,
        ttsReady: true,
      );
      expect(pack.isFullyReady, isFalse);
    });

    test('readyCount returns correct count', () {
      const pack = LanguagePack(
        language: korean,
        sttReady: true,
        translationReady: false,
        ttsReady: true,
      );
      expect(pack.readyCount, 2);
    });

    test('readyCount is 0 for default pack', () {
      const pack = LanguagePack(language: korean);
      expect(pack.readyCount, 0);
      expect(pack.isFullyReady, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const original = LanguagePack(
        language: korean,
        sttReady: true,
        translationReady: false,
        ttsReady: true,
        downloadProgress: 0.5,
        isDownloading: true,
      );

      final updated = original.copyWith(translationReady: true);

      expect(updated.sttReady, isTrue);
      expect(updated.translationReady, isTrue);
      expect(updated.ttsReady, isTrue);
      expect(updated.downloadProgress, 0.5);
      expect(updated.isDownloading, isTrue);
      expect(updated.language.code, 'ko');
    });

    test('copyWith overrides specified fields', () {
      const original = LanguagePack(
        language: korean,
        downloadProgress: 0.0,
        isDownloading: false,
      );

      final updated = original.copyWith(
        downloadProgress: 0.75,
        isDownloading: true,
      );

      expect(updated.downloadProgress, 0.75);
      expect(updated.isDownloading, isTrue);
    });
  });
}
