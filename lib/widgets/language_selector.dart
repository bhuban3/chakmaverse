 import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final bool isBengaliToChakma;
  final AnimationController animController;
  final VoidCallback onSwap;

  const LanguageSelector({
    super.key,
    required this.isBengaliToChakma,
    required this.animController,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: _langChip(
            label: isBengaliToChakma ? 'বাংলা' : 'চাকমা',
            subtitle: isBengaliToChakma ? 'Bengali' : 'Chakma',
            sample: isBengaliToChakma ? 'ক খ গ' : '𑄇 𑄈 𑄉',
            isActive: true,
            isSource: true,
          )),

          // Swap button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: onSwap,
              child: AnimatedBuilder(
                animation: animController,
                builder: (_, child) => Transform.rotate(
                  angle: animController.value * 2 * 3.14159,
                  child: child,
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          Expanded(child: _langChip(
            label: isBengaliToChakma ? 'চাকমা' : 'বাংলা',
            subtitle: isBengaliToChakma ? 'Chakma' : 'Bengali',
            sample: isBengaliToChakma ? '𑄇 𑄈 𑄉' : 'ক খ গ',
            isActive: true,
            isSource: false,
          )),
        ],
      ),
    );
  }

  Widget _langChip({
    required String label,
    required String subtitle,
    required String sample,
    required bool isActive,
    required bool isSource,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSource
            ? AppTheme.primary.withValues(alpha: 0.08)
            : AppTheme.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSource
              ? AppTheme.primary.withValues(alpha: 0.25)
              : AppTheme.accent.withValues(alpha: 0.30),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: isSource
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isSource
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Icon(
                isSource
                    ? Icons.input_rounded
                    : Icons.output_rounded,
                size: 13,
                color: isSource ? AppTheme.primary : AppTheme.accent,
              ),
              const SizedBox(width: 4),
              Text(
                isSource ? 'Input' : 'Output',
                style: TextStyle(
                  fontSize: 10,
                  color: isSource ? AppTheme.primary : AppTheme.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSource ? AppTheme.primaryDark : AppTheme.textPrimary,
              fontFamily: 'NotoSansBengali',
            ),
          ),
          Text(
            sample,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textHint,
              fontFamily: label == 'চাকমা' ? 'NotoSansChakma' : 'NotoSansBengali',
            ),
          ),
        ],
      ),
    );
  }
}
