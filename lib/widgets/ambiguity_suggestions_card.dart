import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AmbiguitySuggestionsCard extends StatelessWidget {
  final List<String> variants;
  final String selected;
  final ValueChanged<String> onSelected;

  const AmbiguitySuggestionsCard({
    super.key,
    required this.variants,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'সঠিক রূপান্তরটি পছন্দ করুন:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'NotoSansBengali',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variants.map((word) {
              final isSelected = word == selected;

              return ChoiceChip(
                label: Text(
                  word,
                  style: const TextStyle(
                    fontFamily: 'NotoSansBengali',
                    fontSize: 14,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) onSelected(word);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
