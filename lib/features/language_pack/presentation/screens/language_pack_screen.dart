import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_time_translation/features/translation/domain/models/language.dart';
import '../../domain/models/language_pack.dart';

final languagePacksProvider =
    StateNotifierProvider<LanguagePacksNotifier, List<LanguagePack>>(
  (ref) => LanguagePacksNotifier(),
);

class LanguagePacksNotifier extends StateNotifier<List<LanguagePack>> {
  LanguagePacksNotifier()
      : super(
          Language.supported.map((lang) {
            if (lang.code == 'ko') {
              return LanguagePack(
                language: lang,
                sttReady: true,
                translationReady: true,
                ttsReady: true,
              );
            }
            return LanguagePack(language: lang);
          }).toList(),
        );

  Future<void> downloadPack(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(isDownloading: true)
        else
          state[i],
    ];

    // TODO: Replace with actual download logic
    for (var progress = 0.0; progress <= 1.0; progress += 0.1) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(
              downloadProgress: progress,
              sttReady: progress >= 0.3,
              translationReady: progress >= 0.6,
              ttsReady: progress >= 0.9,
              isDownloading: progress < 1.0,
            )
          else
            state[i],
      ];
    }
  }

  void deletePack(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          LanguagePack(language: state[i].language)
        else
          state[i],
    ];
  }
}

class LanguagePackScreen extends ConsumerWidget {
  const LanguagePackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packs = ref.watch(languagePacksProvider);
    final notifier = ref.read(languagePacksProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('언어 팩'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              '오프라인 번역을 위해 언어 팩을 다운로드하세요',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: packs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _LanguagePackCard(
                  pack: packs[index],
                  onDownload: () => notifier.downloadPack(index),
                  onDelete: () => notifier.deletePack(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePackCard extends StatelessWidget {
  final LanguagePack pack;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _LanguagePackCard({
    required this.pack,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  pack.language.flagEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.language.nativeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pack.language.name,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (pack.isFullyReady && !pack.isDownloading)
                  _ReadyBadge(colorScheme: colorScheme, onDelete: onDelete)
                else if (pack.isDownloading)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: pack.downloadProgress,
                          strokeWidth: 3,
                          color: colorScheme.primary,
                        ),
                        Text(
                          '${(pack.downloadProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  FilledButton.tonal(
                    onPressed: onDownload,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Icon(Icons.download_rounded, size: 20),
                  ),
              ],
            ),
            if (pack.isDownloading ||
                pack.isFullyReady ||
                pack.readyCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    _ComponentChip(
                      label: 'STT',
                      isReady: pack.sttReady,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _ComponentChip(
                      label: '번역',
                      isReady: pack.translationReady,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _ComponentChip(
                      label: 'TTS',
                      isReady: pack.ttsReady,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            if (pack.isDownloading)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pack.downloadProgress,
                    minHeight: 4,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReadyBadge extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onDelete;

  const _ReadyBadge({required this.colorScheme, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '준비됨',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          tooltip: '삭제',
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

class _ComponentChip extends StatelessWidget {
  final String label;
  final bool isReady;
  final ColorScheme colorScheme;

  const _ComponentChip({
    required this.label,
    required this.isReady,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isReady
            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReady ? Icons.check_rounded : Icons.hourglass_empty_rounded,
            size: 12,
            color: isReady
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isReady
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
