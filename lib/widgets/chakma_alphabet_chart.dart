import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Chakma alphabet chart that loads all data from assets/data/alphabets.json.
class ChakmaAlphabetChart extends StatefulWidget {
  const ChakmaAlphabetChart({super.key});

  @override
  State<ChakmaAlphabetChart> createState() => _ChakmaAlphabetChartState();
}

class _ChakmaAlphabetChartState extends State<ChakmaAlphabetChart> {
  // ── Colours matching the wall-chart in the reference image ────────────
  static const Color _bg          = Color(0xFF2E7D32);
  static const Color _cellBg      = Color(0xFFF5F0C8);
  static const Color _chakmaRed   = Color(0xFFCC0000);
  static const Color _labelGreen  = Color(0xFF1B5E20);
  static const Color _titleYellow = Color(0xFFFFD600);
  static const Color _borderGreen = Color(0xFF388E3C);

  // Loaded from JSON
  List<_AlphaEntry> _consonants = [];
  List<_AlphaEntry> _vowels     = [];
  List<_AlphaEntry> _numerals   = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dataRaw = await rootBundle.loadString('assets/data/alphabets.json');
      final data = json.decode(dataRaw) as Map<String, dynamic>;

      final cons = (data['consonants'] as List).map((e) {
        final map = e as Map<String, dynamic>;
        return _AlphaEntry(
          chakma: map['letter'],
          bangla: map['meaning'],
          pronunciation: map['pronunciation'],
          example: map['example'],
        );
      }).toList();

      final vows = (data['vowels'] as List).map((e) {
        final map = e as Map<String, dynamic>;
        return _AlphaEntry(
          chakma: map['letter'],
          bangla: map['meaning'],
        );
      }).toList();

      final nums = (data['numerals'] as List).map((e) {
        final map = e as Map<String, dynamic>;
        return _AlphaEntry(
          chakma: map['letter'],
          bangla: map['meaning'],
        );
      }).toList();

      setState(() {
        _consonants = cons;
        _vowels     = vows;
        _numerals   = nums;
        _loading    = false;
      });
    } catch (e) {
      setState(() {
        _error   = e.toString();
        _loading = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      );
    }

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
        child: Column(
          children: [
            _buildTitle(),
            const SizedBox(height: 14),
            _buildGrid(_consonants, glyphSize: 28),
            const SizedBox(height: 10),
            _buildBand('স্বরবর্ণ'),
            const SizedBox(height: 8),
            _buildGrid(_vowels, glyphSize: 24),
            const SizedBox(height: 10),
            _buildBand('𑄱𑄢𑄴𑄥𑄧𑄁 𑄥𑄁𑄈𑄴𑄡𑄧  (চাকমা সংখ্যা)'),
            const SizedBox(height: 8),
            _buildGrid(_numerals, glyphSize: 22),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => Column(
    children: [
      const Text(
        '𑄌𑄦𑄟 𑄝𑄧𑄢𑄴𑄚𑄟𑄣',
        style: TextStyle(
          fontFamily: 'NatoSansChakma',
          fontSize: 26,
          color: _titleYellow,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      const Text(
        'চাকমা বর্ণমালা',
        style: TextStyle(
          fontFamily: 'NotoSansBengali',
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildGrid(List<_AlphaEntry> entries, {required double glyphSize}) {
    final rows = <Widget>[];
    for (int i = 0; i < entries.length; i += 5) {
      final slice = entries.sublist(
          i, (i + 5).clamp(0, entries.length));
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: slice.map((e) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _Cell(entry: e, glyphSize: glyphSize),
            ),
          )).toList() + (slice.length < 5 
              ? List.generate(5 - slice.length, (index) => const Expanded(child: SizedBox())) 
              : []),
        ),
      ));
    }
    return Column(children: rows);
  }

  Widget _buildBand(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      color: _labelGreen,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'NotoSansBengali',
        fontSize: 13,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ── Shared data model ─────────────────────────────────────────────────────

class _AlphaEntry {
  final String chakma;
  final String bangla;
  final String? pronunciation;
  final String? example;
  const _AlphaEntry({
    required this.chakma,
    required this.bangla,
    this.pronunciation,
    this.example,
  });
}

// ── Single cell ───────────────────────────────────────────────────────────

class _Cell extends StatelessWidget {
  final _AlphaEntry entry;
  final double glyphSize;

  const _Cell({required this.entry, required this.glyphSize});

  static const Color _cellBg     = Color(0xFFF5F0C8);
  static const Color _chakmaRed  = Color(0xFFCC0000);
  static const Color _labelGreen = Color(0xFF1B5E20);
  static const Color _border     = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: _cellBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _border, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.chakma,
              style: TextStyle(
                fontFamily: 'NatoSansChakma',
                fontSize: glyphSize,
                color: _chakmaRed,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              entry.pronunciation ?? entry.bangla,
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 10,
                color: _labelGreen,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F0C8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              entry.chakma,
              style: const TextStyle(
                fontFamily: 'NatoSansChakma',
                fontSize: 90,
                color: Color(0xFFCC0000),
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              entry.bangla,
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.center,
            ),
            if (entry.pronunciation != null) ...[
              const SizedBox(height: 8),
              Text(
                entry.pronunciation!,
                style: const TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (entry.example != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF388E3C).withValues(alpha: 0.2)),
                ),
                child: Text(
                  'উদাহরণ: ${entry.example!}',
                  style: const TextStyle(
                    fontFamily: 'NotoSansBengali',
                    fontSize: 16,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
