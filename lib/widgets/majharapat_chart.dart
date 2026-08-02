import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One row of the Majhara-Pat (vowel-sign / conjunct combination) table.
class MajharaPatEntry {
  final String formula;          // e.g. "ক + ি"
  final String descriptionBengali; // e.g. "আ-বান্যা = ই"
  final String chakmaSymbol;     // resulting Chakma glyph, e.g. "𑄇𑄨"
  final String exampleChakma;    // Chakma example word
  final String exampleBengali;   // Bengali transliteration of the example

  const MajharaPatEntry({
    required this.formula,
    required this.descriptionBengali,
    required this.chakmaSymbol,
    required this.exampleChakma,
    required this.exampleBengali,
  });

  factory MajharaPatEntry.fromJson(Map<String, dynamic> json) {
    return MajharaPatEntry(
      formula: json['formula'] as String,
      descriptionBengali: json['descriptionBengali'] as String,
      chakmaSymbol: json['chakmaSymbol'] as String,
      exampleChakma: json['exampleChakma'] as String,
      exampleBengali: json['exampleBengali'] as String,
    );
  }
}

/// Loads majhara_pat_data.json from assets.
/// Add to pubspec.yaml:
///   assets:
///     - assets/data/majhara_pat_data.json
class MajharaPatData {
  static Future<List<MajharaPatEntry>> load() async {
    final raw = await rootBundle.loadString('assets/data/majharapat.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final list = decoded['entries'] as List<dynamic>;
    return list
        .map((e) => MajharaPatEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Renders the "মাজারা-পাত" (Majhara-Pat) table exactly in the style of the
/// reference sheet: teal heading, boxed rows, 4 columns
/// [formula | description = result] [chakma symbol] [example (bengali)].
///
/// Drop this into the Alphabet screen, e.g. as a new tab/section:
///   MajharaPatSection(entries: await MajharaPatData.load())
class MajharaPatSection extends StatelessWidget {
  final List<MajharaPatEntry> entries;
  final String chakmaFontFamily;   // your Chakma-compatible font
  final String bengaliFontFamily;  // NotoSansBengali or similar

  const MajharaPatSection({
    super.key,
    required this.entries,
    this.chakmaFontFamily = 'NotoSansChakma',
    this.bengaliFontFamily = 'NotoSansBengali',
  });

  static const Color _teal = Color(0xFF1E7A6E);
  static const Color _borderColor = Color(0xFFD4E8DC);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF2E9E68) : const Color(0xFF1A6B45);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(primaryColor),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < entries.length; i++)
                  _buildRow(
                    entries[i], 
                    isLast: i == entries.length - 1,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Column(
      children: [
        Text(
          '𑄴𑄤𑄬𑄚𑄴-𑄛𑄧𑄖𑄴',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: chakmaFontFamily,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(মাজারা-পাত)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: bengaliFontFamily,
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    MajharaPatEntry e, {
    required bool isLast,
    required Color primaryColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: _borderColor),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Col 1: formula, e.g. "ক + ি"
            _cell(
              flex: 2,
              child: Text(
                e.formula,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: bengaliFontFamily, // Changed to Bengali for formulas
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
            _vDivider(),
            // Col 2: description = result (Bengali)
            _cell(
              flex: 4,
              child: Text(
                e.descriptionBengali,
                style: TextStyle(
                  fontFamily: bengaliFontFamily,
                  fontSize: 13,
                  color: subTextColor,
                ),
              ),
            ),
            _vDivider(),
            // Col 3: resulting Chakma symbol
            _cell(
              flex: 2,
              child: Text(
                e.chakmaSymbol,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: chakmaFontFamily,
                  fontSize: 20,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _vDivider(),
            // Col 4: example word (Chakma) + Bengali gloss in parentheses
            _cell(
              flex: 4,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: e.exampleChakma,
                      style: TextStyle(
                        fontFamily: chakmaFontFamily,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: '(${e.exampleBengali})',
                      style: TextStyle(
                        fontFamily: bengaliFontFamily,
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell({required int flex, required Widget child}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Center(child: child),
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, color: _borderColor);
}