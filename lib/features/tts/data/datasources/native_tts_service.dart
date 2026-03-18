import 'package:flutter_tts/flutter_tts.dart';
import 'package:real_time_translation/features/tts/domain/repositories/tts_service.dart';

/// TTS using the device's native text-to-speech engine.
class NativeTtsService implements TtsService {
  NativeTtsService() : _tts = FlutterTts() {
    _tts.setSharedInstance(true);
  }

  final FlutterTts _tts;

  @override
  Future<void> speak({
    required String text,
    required String language,
  }) async {
    if (text.trim().isEmpty) return;

    await _tts.setLanguage(language);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  @override
  Future<void> dispose() async {
    await _tts.stop();
  }
}
