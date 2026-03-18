abstract class SttService {
  /// Start listening and return a stream of recognized text.
  /// [localeId] is a BCP-47 locale like "ko-KR" or "en-US".
  Stream<SttResult> startListening({required String localeId});

  /// Stop the current listening session.
  Future<void> stopListening();

  /// Whether the service is currently listening.
  bool get isListening;

  /// Dispose resources.
  Future<void> dispose();
}

class SttResult {
  const SttResult({
    required this.text,
    required this.isFinal,
  });

  final String text;
  final bool isFinal;
}
