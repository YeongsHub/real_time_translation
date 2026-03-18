import 'package:dio/dio.dart';
import 'package:real_time_translation/features/translation/domain/repositories/translation_service.dart';

/// Cloud translation service for premium users.
/// Routes through a backend proxy to avoid embedding API keys.
class CloudTranslationService implements TranslationService {
  CloudTranslationService({required this.dio, required this.proxyBaseUrl});

  final Dio dio;
  final String proxyBaseUrl;

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (text.trim().isEmpty) return '';

    final response = await dio.post(
      '$proxyBaseUrl/translate',
      data: {
        'text': text,
        'source': sourceLanguage,
        'target': targetLanguage,
      },
    );

    return response.data['translatedText'] as String;
  }

  @override
  Future<void> downloadModel({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    // Cloud translation doesn't need local models.
  }

  @override
  Future<void> dispose() async {
    // No resources to dispose for cloud service.
  }
}
