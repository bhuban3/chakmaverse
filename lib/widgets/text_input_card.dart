import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TextInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isBengaliSource;
  final VoidCallback onClear;

  const TextInputCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isBengaliSource,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fontFamily = isBengaliSource ? 'NotoSansBengali' : 'NotoSansChakma';
    final hintText = isBengaliSource
        ? 'এখানে বাংলা লিখুন…'
        : '𑄃𑄧𑄖𑄴 𑄌𑄦𑄟 𑄣𑄨𑄈𑄪𑄚𑄴…';
    final langLabel = isBengaliSource ? 'বাংলা ইনপুট' : 'চাকমা ইনপুট';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  langLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontFamily: 'NotoSansBengali',
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                // Character count
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) => Text(
                    '${value.text.length} অক্ষর',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHint,
                      fontFamily: 'NotoSansBengali',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Clear button
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) => value.text.isEmpty
                      ? const SizedBox(width: 36)
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppTheme.textHint,
                          onPressed: onClear,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Text field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 5,
              minLines: 3,
              style: TextStyle(
                fontSize: 20,
                fontFamily: fontFamily,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: fontFamily,
                  color: AppTheme.textHint,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
          ),
        ],
      ),
    );
  }
}
