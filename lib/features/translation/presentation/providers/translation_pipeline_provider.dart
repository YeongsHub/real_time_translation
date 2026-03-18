import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_time_translation/features/stt/domain/repositories/stt_service.dart';
import 'package:real_time_translation/services/service_resolver.dart';

/// State for the translation pipeline.
class TranslationPipelineState {
  const TranslationPipelineState({
    this.recognizedText = '',
    this.translatedText = '',
    this.isListening = false,
    this.isTranslating = false,
    this.error,
  });

  final String recognizedText;
  final String translatedText;
  final bool isListening;
  final bool isTranslating;
  final String? error;

  TranslationPipelineState copyWith({
    String? recognizedText,
    String? translatedText,
    bool? isListening,
    bool? isTranslating,
    String? error,
  }) {
    return TranslationPipelineState(
      recognizedText: recognizedText ?? this.recognizedText,
      translatedText: translatedText ?? this.translatedText,
      isListening: isListening ?? this.isListening,
      isTranslating: isTranslating ?? this.isTranslating,
      error: error,
    );
  }
}

/// Manages the full STT → Translation → TTS pipeline.
class TranslationPipelineNotifier extends StateNotifier<TranslationPipelineState> {
  TranslationPipelineNotifier(this._ref) : super(const TranslationPipelineState());

  final Ref _ref;
  StreamSubscription<SttResult>? _sttSubscription;

  /// Start listening and translating.
  Future<void> startListening({
    required String sourceLocale,
    required String sourceLanguage,
    required String targetLanguage,
    bool autoSpeak = true,
  }) async {
    final sttService = _ref.read(sttServiceProvider);
    final translationService = _ref.read(translationServiceProvider);
    final ttsService = _ref.read(ttsServiceProvider);

    state = state.copyWith(isListening: true, error: null);

    try {
      final stream = sttService.startListening(localeId: sourceLocale);

      await _sttSubscription?.cancel();
      _sttSubscription = stream.listen(
        (result) async {
          state = state.copyWith(recognizedText: result.text);

          if (result.isFinal && result.text.trim().isNotEmpty) {
            state = state.copyWith(isTranslating: true);

            try {
              final translated = await translationService.translate(
                text: result.text,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
              );

              state = state.copyWith(
                translatedText: translated,
                isTranslating: false,
              );

              if (autoSpeak && translated.isNotEmpty) {
                await ttsService.speak(
                  text: translated,
                  language: targetLanguage,
                );
              }
            } catch (e) {
              state = state.copyWith(
                isTranslating: false,
                error: 'Translation failed: $e',
              );
            }
          }
        },
        onError: (error) {
          state = state.copyWith(
            isListening: false,
            error: 'STT error: $error',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isListening: false,
        error: 'Failed to start listening: $e',
      );
    }
  }

  /// Stop the pipeline.
  Future<void> stopListening() async {
    await _sttSubscription?.cancel();
    _sttSubscription = null;

    final sttService = _ref.read(sttServiceProvider);
    await sttService.stopListening();

    state = state.copyWith(isListening: false);
  }

  /// Clear current results.
  void clear() {
    state = const TranslationPipelineState();
  }

  @override
  void dispose() {
    _sttSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for the translation pipeline.
final translationPipelineProvider =
    StateNotifierProvider<TranslationPipelineNotifier, TranslationPipelineState>(
  (ref) => TranslationPipelineNotifier(ref),
);
