abstract class TranslationService {
  /// Translate [text] from [sourceLanguage] to [targetLanguage].
  /// Language codes follow BCP-47 (e.g. "ko", "en", "ja").
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Download any required models for offline use.
  Future<void> downloadModel({
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Dispose resources.
  Future<void> dispose();
}
