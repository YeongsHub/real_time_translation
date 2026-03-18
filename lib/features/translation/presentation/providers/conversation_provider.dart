import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_time_translation/features/stt/domain/repositories/stt_service.dart';
import 'package:real_time_translation/services/service_resolver.dart';
import '../../domain/models/language.dart';

class ConversationState {
  final Language languageA;
  final Language languageB;
  final bool isListeningA;
  final bool isListeningB;
  final bool isOnlineMode;
  final String translatedTextA;
  final String originalTextA;
  final String translatedTextB;
  final String originalTextB;
  final bool isTranslating;
  final String? error;
  final int translationCount;

  const ConversationState({
    this.languageA = const Language(
      code: 'ko', name: 'Korean', nativeName: '한국어', flagEmoji: '🇰🇷',
    ),
    this.languageB = const Language(
      code: 'en', name: 'English', nativeName: 'English', flagEmoji: '🇺🇸',
    ),
    this.isListeningA = false,
    this.isListeningB = false,
    this.isOnlineMode = false,
    this.translatedTextA = '',
    this.originalTextA = '',
    this.translatedTextB = '',
    this.originalTextB = '',
    this.isTranslating = false,
    this.error,
    this.translationCount = 0,
  });

  ConversationState copyWith({
    Language? languageA,
    Language? languageB,
    bool? isListeningA,
    bool? isListeningB,
    bool? isOnlineMode,
    String? translatedTextA,
    String? originalTextA,
    String? translatedTextB,
    String? originalTextB,
    bool? isTranslating,
    String? error,
    int? translationCount,
  }) {
    return ConversationState(
      languageA: languageA ?? this.languageA,
      languageB: languageB ?? this.languageB,
      isListeningA: isListeningA ?? this.isListeningA,
      isListeningB: isListeningB ?? this.isListeningB,
      isOnlineMode: isOnlineMode ?? this.isOnlineMode,
      translatedTextA: translatedTextA ?? this.translatedTextA,
      originalTextA: originalTextA ?? this.originalTextA,
      translatedTextB: translatedTextB ?? this.translatedTextB,
      originalTextB: originalTextB ?? this.originalTextB,
      isTranslating: isTranslating ?? this.isTranslating,
      error: error,
      translationCount: translationCount ?? this.translationCount,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier(this._ref) : super(const ConversationState());

  final Ref _ref;
  StreamSubscription<SttResult>? _sttSubscription;

  void toggleMicA() {
    if (state.isListeningA) {
      _stopListening();
    } else {
      _startListening(
        speakerA: true,
        sourceLocale: _toLocaleId(state.languageA.code),
        sourceLanguage: state.languageA.code,
        targetLanguage: state.languageB.code,
      );
    }
  }

  void toggleMicB() {
    if (state.isListeningB) {
      _stopListening();
    } else {
      _startListening(
        speakerA: false,
        sourceLocale: _toLocaleId(state.languageB.code),
        sourceLanguage: state.languageB.code,
        targetLanguage: state.languageA.code,
      );
    }
  }

  Future<void> _startListening({
    required bool speakerA,
    required String sourceLocale,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    // Stop any existing session first
    await _stopListening();

    state = state.copyWith(
      isListeningA: speakerA,
      isListeningB: !speakerA,
      error: null,
    );

    final sttService = _ref.read(sttServiceProvider);
    final translationService = _ref.read(translationServiceProvider);
    final ttsService = _ref.read(ttsServiceProvider);

    try {
      final stream = sttService.startListening(localeId: sourceLocale);

      _sttSubscription = stream.listen(
        (result) async {
          // Update recognized text in real-time
          if (speakerA) {
            state = state.copyWith(originalTextA: result.text);
          } else {
            state = state.copyWith(originalTextB: result.text);
          }

          // Translate on final result
          if (result.isFinal && result.text.trim().isNotEmpty) {
            state = state.copyWith(isTranslating: true);

            try {
              final translated = await translationService.translate(
                text: result.text,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
              );

              final newCount = state.translationCount + 1;

              if (speakerA) {
                state = state.copyWith(
                  translatedTextA: translated,
                  isTranslating: false,
                  translationCount: newCount,
                );
              } else {
                state = state.copyWith(
                  translatedTextB: translated,
                  isTranslating: false,
                  translationCount: newCount,
                );
              }

              // Auto-speak the translation
              if (translated.isNotEmpty) {
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
            isListeningA: false,
            isListeningB: false,
            error: 'STT error: $error',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isListeningA: false,
        isListeningB: false,
        error: 'Failed to start listening: $e',
      );
    }
  }

  Future<void> _stopListening() async {
    await _sttSubscription?.cancel();
    _sttSubscription = null;

    try {
      final sttService = _ref.read(sttServiceProvider);
      await sttService.stopListening();
    } catch (_) {}

    state = state.copyWith(isListeningA: false, isListeningB: false);
  }

  void setLanguageA(Language lang) {
    state = state.copyWith(languageA: lang);
  }

  void setLanguageB(Language lang) {
    state = state.copyWith(languageB: lang);
  }

  void swapLanguages() {
    state = ConversationState(
      languageA: state.languageB,
      languageB: state.languageA,
      translatedTextA: state.translatedTextB,
      originalTextA: state.originalTextB,
      translatedTextB: state.translatedTextA,
      originalTextB: state.originalTextA,
      translationCount: state.translationCount,
    );
  }

  void setOnlineMode(bool online) {
    state = state.copyWith(isOnlineMode: online);
  }

  void updateTranslationA({String? translated, String? original}) {
    state = state.copyWith(
      translatedTextA: translated,
      originalTextA: original,
    );
  }

  void updateTranslationB({String? translated, String? original}) {
    state = state.copyWith(
      translatedTextB: translated,
      originalTextB: original,
    );
  }

  /// Maps a language code to a full locale ID for STT.
  String _toLocaleId(String code) {
    const localeMap = {
      'ko': 'ko-KR',
      'en': 'en-US',
      'ja': 'ja-JP',
      'zh': 'zh-CN',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'vi': 'vi-VN',
      'th': 'th-TH',
      'id': 'id-ID',
    };
    return localeMap[code] ?? 'en-US';
  }

  @override
  void dispose() {
    _sttSubscription?.cancel();
    super.dispose();
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>(
  (ref) => ConversationNotifier(ref),
);
