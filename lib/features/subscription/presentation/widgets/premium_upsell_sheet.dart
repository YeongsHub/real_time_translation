import 'package:flutter/material.dart';

class PremiumUpsellSheet extends StatefulWidget {
  const PremiumUpsellSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumUpsellSheet(),
    );
  }

  @override
  State<PremiumUpsellSheet> createState() => _PremiumUpsellSheetState();
}

class _PremiumUpsellSheetState extends State<PremiumUpsellSheet> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Premium으로 업그레이드',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '고품질 온라인 번역으로 더 정확한 소통을 경험하세요',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Comparison table
          _ComparisonTable(colorScheme: colorScheme),
          const SizedBox(height: 24),

          // Plan toggle
          _PlanToggle(
            isYearly: _isYearly,
            onChanged: (yearly) => setState(() => _isYearly = yearly),
          ),
          const SizedBox(height: 16),

          // Price
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isYearly
                ? _PriceDisplay(
                    key: const ValueKey('yearly'),
                    price: '₩59,900',
                    period: '/년',
                    subtitle: '월 ₩4,992 · 58% 할인',
                    colorScheme: colorScheme,
                  )
                : _PriceDisplay(
                    key: const ValueKey('monthly'),
                    price: '₩9,900',
                    period: '/월',
                    subtitle: '',
                    colorScheme: colorScheme,
                  ),
          ),
          const SizedBox(height: 20),

          // CTA
          FilledButton(
            onPressed: () {
              // TODO: Trigger in-app purchase
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '지금 업그레이드',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              // TODO: Restore purchases
            },
            child: Text(
              '구매 복원',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ComparisonTable({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Text(
                    '무료',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _ComparisonRow(
            feature: '번역 품질', free: '기본', premium: '고품질',
            colorScheme: colorScheme,
          ),
          _ComparisonRow(
            feature: '번역 모드', free: '오프라인', premium: '온라인+오프라인',
            colorScheme: colorScheme,
          ),
          _ComparisonRow(
            feature: '광고', free: '있음', premium: '없음',
            colorScheme: colorScheme, isPremiumHighlight: true,
          ),
          _ComparisonRow(
            feature: '지원 언어', free: '10개', premium: '40+개',
            colorScheme: colorScheme, isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;
  final ColorScheme colorScheme;
  final bool isPremiumHighlight;
  final bool isLast;

  const _ComparisonRow({
    required this.feature,
    required this.free,
    required this.premium,
    required this.colorScheme,
    this.isPremiumHighlight = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPremiumHighlight
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanToggle extends StatelessWidget {
  final bool isYearly;
  final ValueChanged<bool> onChanged;
  const _PlanToggle({required this.isYearly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PlanOption(
              label: '월간', isSelected: !isYearly,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _PlanOption(
              label: '연간', badge: '58% 할인', isSelected: isYearly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOption({
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4, offset: const Offset(0, 1),
                )]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final String price;
  final String period;
  final String subtitle;
  final ColorScheme colorScheme;

  const _PriceDisplay({
    super.key,
    required this.price,
    required this.period,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 13, color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
