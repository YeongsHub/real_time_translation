import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:real_time_translation/features/translation/domain/repositories/translation_service.dart';

/// Offline translation using Google ML Kit on-device models.
class MlKitTranslationService implements TranslationService {
  final _modelManager = OnDeviceTranslatorModelManager();
  OnDeviceTranslator? _translator;
  String? _currentSource;
  String? _currentTarget;

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (text.trim().isEmpty) return '';

    // Re-create translator if languages changed
    if (_currentSource != sourceLanguage || _currentTarget != targetLanguage) {
      await _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: _toBcp47(sourceLanguage),
        targetLanguage: _toBcp47(targetLanguage),
      );
      _currentSource = sourceLanguage;
      _currentTarget = targetLanguage;
    }

    return await _translator!.translateText(text);
  }

  @override
  Future<void> downloadModel({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    await Future.wait([
      _modelManager.downloadModel(sourceLanguage),
      _modelManager.downloadModel(targetLanguage),
    ]);
  }

  TranslateLanguage _toBcp47(String languageCode) {
    return TranslateLanguage.values.firstWhere(
      (lang) => lang.bcpCode == languageCode,
      orElse: () => TranslateLanguage.english,
    );
  }

  @override
  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
  }
}
