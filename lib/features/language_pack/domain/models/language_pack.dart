import 'package:real_time_translation/features/translation/domain/models/language.dart';

class LanguagePack {
  final Language language;
  final bool sttReady;
  final bool translationReady;
  final bool ttsReady;
  final double downloadProgress;
  final bool isDownloading;

  const LanguagePack({
    required this.language,
    this.sttReady = false,
    this.translationReady = false,
    this.ttsReady = false,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
  });

  bool get isFullyReady => sttReady && translationReady && ttsReady;

  int get readyCount =>
      (sttReady ? 1 : 0) + (translationReady ? 1 : 0) + (ttsReady ? 1 : 0);

  LanguagePack copyWith({
    bool? sttReady,
    bool? translationReady,
    bool? ttsReady,
    double? downloadProgress,
    bool? isDownloading,
  }) {
    return LanguagePack(
      language: language,
      sttReady: sttReady ?? this.sttReady,
      translationReady: translationReady ?? this.translationReady,
      ttsReady: ttsReady ?? this.ttsReady,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}
