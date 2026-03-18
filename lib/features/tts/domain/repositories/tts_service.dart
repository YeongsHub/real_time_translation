abstract class TtsService {
  /// Speak the given [text] in the specified [language] (BCP-47).
  Future<void> speak({
    required String text,
    required String language,
  });

  /// Stop any ongoing speech.
  Future<void> stop();

  /// Set speech rate (0.0 to 1.0).
  Future<void> setSpeechRate(double rate);

  /// Dispose resources.
  Future<void> dispose();
}
