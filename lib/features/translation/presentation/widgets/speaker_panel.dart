import 'package:flutter/material.dart';
import '../../domain/models/language.dart';

class SpeakerPanel extends StatelessWidget {
  final String label;
  final Language selectedLanguage;
  final String translatedText;
  final String originalText;
  final bool isListening;
  final bool isTopPanel;
  final VoidCallback onMicPressed;
  final VoidCallback onLanguageTap;

  const SpeakerPanel({
    super.key,
    required this.label,
    required this.selectedLanguage,
    required this.translatedText,
    required this.originalText,
    required this.isListening,
    required this.isTopPanel,
    required this.onMicPressed,
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final panelColor = isTopPanel
        ? colorScheme.primaryContainer
        : colorScheme.tertiaryContainer;
    final onPanelColor = isTopPanel
        ? colorScheme.onPrimaryContainer
        : colorScheme.onTertiaryContainer;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: panelColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: isListening
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: onPanelColor.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  _LanguageChip(
                    language: selectedLanguage,
                    onTap: onLanguageTap,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (translatedText.isNotEmpty)
                          Text(
                            translatedText,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: onPanelColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (originalText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            originalText,
                            style: TextStyle(
                              fontSize: 14,
                              color: onPanelColor.withValues(alpha: 0.5),
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (translatedText.isEmpty && originalText.isEmpty)
                          Text(
                            isListening ? '듣고 있어요...' : '마이크를 눌러 말하세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: onPanelColor.withValues(alpha: 0.4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MicButton(
                isListening: isListening,
                onPressed: onMicPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final Language language;
  final VoidCallback onTap;

  const _LanguageChip({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(language.flagEmoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                language.nativeName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const _MicButton({required this.isListening, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: isListening ? colorScheme.error : colorScheme.primary,
        shape: const CircleBorder(),
        elevation: isListening ? 8 : 2,
        shadowColor: isListening
            ? colorScheme.error.withValues(alpha: 0.4)
            : Colors.black26,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: isListening ? colorScheme.onError : colorScheme.onPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
