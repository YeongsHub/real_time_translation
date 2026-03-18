import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_time_translation/core/network/connectivity_provider.dart';
import 'package:real_time_translation/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:real_time_translation/features/subscription/presentation/widgets/premium_upsell_sheet.dart';
import '../providers/conversation_provider.dart';
import '../widgets/speaker_panel.dart';
import '../widgets/language_selector_sheet.dart';

class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);
    final notifier = ref.read(conversationProvider.notifier);
    final isPremium = ref.watch(isPremiumProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final isConnected = connectivityAsync.valueOrNull ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    // Show error snackbar
    ref.listen<ConversationState>(conversationProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: '닫기',
              onPressed: () {},
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            _StatusBar(
              isOnlineMode: state.isOnlineMode,
              isPremium: isPremium,
              isConnected: isConnected,
              onOnlineModeToggle: () {
                if (!isPremium) {
                  PremiumUpsellSheet.show(context);
                  return;
                }
                notifier.setOnlineMode(!state.isOnlineMode);
              },
              onSettingsTap: () => context.push('/settings'),
              onLanguagePackTap: () => context.push('/language-packs'),
            ),

            // Speaker A (top)
            SpeakerPanel(
              label: '화자 A',
              selectedLanguage: state.languageA,
              translatedText: state.translatedTextA,
              originalText: state.originalTextA,
              isListening: state.isListeningA,
              isTopPanel: true,
              onMicPressed: () => notifier.toggleMicA(),
              onLanguageTap: () async {
                final selected = await LanguageSelectorSheet.show(
                  context,
                  currentLanguage: state.languageA,
                );
                if (selected != null) notifier.setLanguageA(selected);
              },
            ),

            // Swap divider with translating indicator
            Stack(
              alignment: Alignment.center,
              children: [
                _SwapDivider(onSwap: () => notifier.swapLanguages()),
                if (state.isTranslating)
                  Positioned(
                    right: 24,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

            // Speaker B (bottom)
            SpeakerPanel(
              label: '화자 B',
              selectedLanguage: state.languageB,
              translatedText: state.translatedTextB,
              originalText: state.originalTextB,
              isListening: state.isListeningB,
              isTopPanel: false,
              onMicPressed: () => notifier.toggleMicB(),
              onLanguageTap: () async {
                final selected = await LanguageSelectorSheet.show(
                  context,
                  currentLanguage: state.languageB,
                );
                if (selected != null) notifier.setLanguageB(selected);
              },
            ),

            // Ad banner (free users)
            if (!isPremium) _AdBannerPlaceholder(colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final bool isOnlineMode;
  final bool isPremium;
  final bool isConnected;
  final VoidCallback onOnlineModeToggle;
  final VoidCallback onSettingsTap;
  final VoidCallback onLanguagePackTap;

  const _StatusBar({
    required this.isOnlineMode,
    required this.isPremium,
    required this.isConnected,
    required this.onOnlineModeToggle,
    required this.onSettingsTap,
    required this.onLanguagePackTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isOnlineMode
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnlineMode
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                  size: 14,
                  color: isOnlineMode
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnlineMode ? '온라인 모드' : '오프라인 모드',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOnlineMode
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Language pack button
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 22),
            onPressed: onLanguagePackTap,
            tooltip: '언어 팩',
          ),

          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: onSettingsTap,
            tooltip: '설정',
          ),

          // Online mode toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOnlineModeToggle,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOnlineMode
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: isOnlineMode
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '고품질',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOnlineMode
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapDivider extends StatelessWidget {
  final VoidCallback onSwap;

  const _SwapDivider({required this.onSwap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 36,
              height: 36,
              child: IconButton.filled(
                onPressed: onSwap,
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                ),
                tooltip: '언어 바꾸기',
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdBannerPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;

  const _AdBannerPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          'AdMob Banner',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
