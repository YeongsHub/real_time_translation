import 'package:flutter/material.dart';
import '../../domain/models/language.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final Language currentLanguage;
  final ValueChanged<Language> onSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLanguage,
    required this.onSelected,
  });

  static Future<Language?> show(
    BuildContext context, {
    required Language currentLanguage,
  }) {
    return showModalBottomSheet<Language>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguageSelectorSheet(
        currentLanguage: currentLanguage,
        onSelected: (lang) => Navigator.of(context).pop(lang),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '언어 선택',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 16 + bottomPadding),
              itemCount: Language.supported.length,
              itemBuilder: (context, index) {
                final lang = Language.supported[index];
                final isSelected = lang.code == currentLanguage.code;
                return ListTile(
                  onTap: () => onSelected(lang),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  leading: Text(
                    lang.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    lang.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
