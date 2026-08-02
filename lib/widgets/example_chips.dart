import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExampleChips extends StatelessWidget {
  final bool isBengaliSource;
  final ValueChanged<String> onSelected;

  const ExampleChips({
    super.key,
    required this.isBengaliSource,
    required this.onSelected,
  });

  static const List<String> _bengaliExamples = [
    'ভূবন চাক‌মা',
    'ক খ গ ঘ ঙ',
    'চাকমা ভাষা',
    'সূর্য',
    'নমস্কার',
  ];

  static const List<String> _chakmaExamples = [
    '𑄞𑄫𑄝𑄧𑄚𑄴 𑄌𑄇𑄴𑄟',
    '𑄇 𑄈 𑄉 𑄊 𑄋',
    '𑄌𑄇𑄴𑄟 𑄞𑄥',
    '𑄥𑄫𑄢𑄴𑄡𑄧',
    '𑄚𑄧𑄟𑄧𑄥𑄴𑄇𑄢𑄧',
  ];

  @override
  Widget build(BuildContext context) {
    final examples = isBengaliSource ? _bengaliExamples : _chakmaExamples;
    final fontFamily = isBengaliSource ? 'NotoSansBengali' : 'NotoSansChakma';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'উদাহরণ চেষ্টা করুন:',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontFamily: 'NotoSansBengali',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: examples.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _ExampleChip(
              text: examples[i],
              fontFamily: fontFamily,
              onTap: () => onSelected(examples[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String text;
  final String fontFamily;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.text,
    required this.fontFamily,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontFamily: fontFamily,
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
