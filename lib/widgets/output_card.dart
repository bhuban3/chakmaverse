import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OutputCard extends StatelessWidget {
  final String output;
  final bool isChakmaOutput;
  final VoidCallback onCopy;
  final int mappingCount;

  const OutputCard({
    super.key,
    required this.output,
    required this.isChakmaOutput,
    required this.onCopy,
    required this.mappingCount,
  });

  @override
  Widget build(BuildContext context) {
    final fontFamily = isChakmaOutput ? 'NotoSansChakma' : 'NotoSansBengali';
    final langLabel = isChakmaOutput ? 'চাকমা আউটপুট' : 'বাংলা আউটপুট';
    final emptyHint = isChakmaOutput
        ? 'চাকমা লিপি এখানে দেখাবে'
        : 'বাংলা লিপি এখানে দেখাবে';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: output.isEmpty
              ? [
                  AppTheme.cardBg,
                  AppTheme.surface,
                ]
              : [
                  const Color(0xFFF0F9F4),
                  const Color(0xFFE6F4ED),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: output.isEmpty ? 0.04 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: output.isEmpty
              ? AppTheme.divider
              : AppTheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  langLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                    fontFamily: 'NotoSansBengali',
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                if (output.isNotEmpty) ...[
                  Text(
                    '${output.runes.length} অক্ষর',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHint,
                      fontFamily: 'NotoSansBengali',
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Copy button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onCopy,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Output text area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: output.isEmpty
                ? Column(
                    children: [
                      const SizedBox(height: 12),
                      Icon(
                        Icons.text_fields_rounded,
                        size: 36,
                        color: AppTheme.textHint.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emptyHint,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textHint,
                          fontFamily: 'NotoSansBengali',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : SelectableText(
                    output,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: fontFamily,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
          ),

          // Footer: mapping stats
          if (output.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hub_outlined, size: 13, color: AppTheme.textHint),
                  const SizedBox(width: 5),
                  Text(
                    '$mappingCount টি ম্যাপিং লোড হয়েছে',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHint,
                      fontFamily: 'NotoSansBengali',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
