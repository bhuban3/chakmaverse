import 'dart:convert';
import 'package:flutter/services.dart';

enum TransliterationDirection { bengaliToChakma, chakmaToBengali }

/// One ambiguous segment found in a Chakma -> Bengali output.
/// e.g. the Chakma syllable 𑄥𑄮 (in সোনার) could be সো, শো, or ষো,
/// or a hasanta+consonant pair could render as a joined ligature or a
/// ZWNJ-separated pair. Every case is represented the same way so the UI
/// can render them uniformly.
class AmbiguousSegment {
  final int startIndex; // position in the OUTPUT string (rune index)
  final int length; // length in runes of the currently-placed value
  final String chakmaSource; // original Chakma text that produced this segment
  final List<String> options; // candidate Bengali strings, preferred first
  final String current; // which option is currently selected

  const AmbiguousSegment({
    required this.startIndex,
    required this.length,
    required this.chakmaSource,
    required this.options,
    required this.current,
  });

  AmbiguousSegment copyWith({String? current}) => AmbiguousSegment(
    startIndex: startIndex,
    length: length,
    chakmaSource: chakmaSource,
    options: options,
    current: current ?? this.current,
  );
}

/// Result of a transliteration. For Bengali -> Chakma, [segments] is always
/// empty (no ambiguity in that direction). For Chakma -> Bengali, [segments]
/// lists EVERY ambiguous spot (consonant collisions like স/শ/ষ, ড/ড়, ঢ/ঢ়,
/// ঋ/রি, AND hasanta+consonant joined-vs-separated) so the UI can offer
/// alternatives for all of them at once.
class TransliterationResult {
  final String text; // full output using default (preferred) choices
  final List<AmbiguousSegment> segments;

  const TransliterationResult({required this.text, required this.segments});

  bool get hasAmbiguity => segments.isNotEmpty;

  /// Rebuilds the full string by applying [choices] (one chosen option per
  /// segment, same order as [segments] sorted by position). Splices
  /// right-to-left so earlier indices stay valid.
  String applyChoices(List<String> choices) {
    final sorted = [...segments]
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));
    var runes = text.runes.toList();
    for (int i = sorted.length - 1; i >= 0; i--) {
      final seg = sorted[i];
      final choiceRunes = choices[i].runes.toList();
      runes = [
        ...runes.sublist(0, seg.startIndex),
        ...choiceRunes,
        ...runes.sublist(seg.startIndex + seg.length),
      ];
    }
    return String.fromCharCodes(runes);
  }

  /// Generates full-word candidate strings — one complete string per
  /// combination of segment choices — for cases where showing whole-word
  /// alternatives is more useful than per-segment chips. Capped at
  /// [maxVariants]; the all-default text is always first.
  List<String> wordVariants({int maxVariants = 50}) {
    if (segments.isEmpty) return [text];

    final sorted = [...segments]
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    List<List<int>> combos = [<int>[]];
    for (final seg in sorted) {
      final next = <List<int>>[];
      for (final combo in combos) {
        for (int oi = 0; oi < seg.options.length; oi++) {
          next.add([...combo, oi]);
          if (next.length >= maxVariants * 4) break;
        }
      }
      combos = next;
    }

    final variants = <String>[];
    final seen = <String>{};
    for (final combo in combos) {
      final choices = [
        for (int i = 0; i < sorted.length; i++) sorted[i].options[combo[i]]
      ];
      final rendered = applyChoices(choices);
      if (seen.add(rendered)) {
        variants.add(rendered);
        if (variants.length >= maxVariants) break;
      }
    }

    variants.remove(text);
    variants.insert(0, text);
    return variants;
  }
}

class TransliterationService {
  static final TransliterationService _instance =
  TransliterationService._internal();
  factory TransliterationService() => _instance;
  TransliterationService._internal();

  bool _isInitialized = false;

  final List<MapEntry<String, String>> _bengaliToChakma = [];
  final List<MapEntry<String, String>> _chakmaToBengali = [];

  // Chakma string -> ordered list of every Bengali letter that collapses
  // onto it. Built automatically during initialize() by scanning for
  // Chakma values produced by more than one Bengali key. First entry in
  // each list is the preferred default. This is fully automatic — any new
  // ambiguity present in the JSON data shows up here with zero code changes.
  final Map<String, List<String>> _chakmaAmbiguities = {};

  // ── Add more conjunct pairs here as you receive them ──────────────────
  static const List<(String, String)> _conjunctFilePairs = [
    ('assets/data/conjuncts_Bengali_a.json', 'assets/data/conjuncts_Chakma_a.json'),
    ('assets/data/conjuncts_Bengali_ai.json', 'assets/data/conjuncts_Chakma_ai.json'),
    ('assets/data/conjuncts_Bengali_au.json', 'assets/data/conjuncts_Chakma_au.json'),
    ('assets/data/conjuncts_Bengali_aḥ.json', 'assets/data/conjuncts_Chakma_aḥ.json'),
    ('assets/data/conjuncts_Bengali_aṃ.json', 'assets/data/conjuncts_Chakma_aṃ.json'),
    ('assets/data/conjuncts_Bengali_e.json', 'assets/data/conjuncts_Chakma_e.json'),
    ('assets/data/conjuncts_Bengali_o.json', 'assets/data/conjuncts_Chakma_o.json'),
    ('assets/data/conjuncts_Bengali_u.json', 'assets/data/conjuncts_Chakma_u.json'),
    ('assets/data/conjuncts_Bengali_i.json', 'assets/data/conjuncts_Chakma_i.json'),
    ('assets/data/conjuncts_Bengali_ā.json', 'assets/data/conjuncts_Chakma_ā.json'),
    ('assets/data/conjuncts_Bengali_ĕ.json', 'assets/data/conjuncts_Chakma_ĕ.json'),
    ('assets/data/conjuncts_Bengali_ṛ.json', 'assets/data/conjuncts_Chakma_ṛ.json'),
    ('assets/data/conjuncts_Bengali_ī.json', 'assets/data/conjuncts_Chakma_ī.json'),
    ('assets/data/conjuncts_Bengali_ū.json', 'assets/data/conjuncts_Chakma_ū.json'),
    ('assets/data/conjuncts_Bengali_ŏ.json', 'assets/data/conjuncts_Chakma_ŏ.json'),
  ];

  static const List<String> _conjunctCategories = [
    'conjuncts1S1', 'conjuncts2S1', 'conjuncts3S1',
    'conjuncts4S1', 'conjuncts5S1',
  ];

  // ── Preferred Chakma -> Bengali ORDERING (NOT detection) ────────────────
  // Detection of collisions is fully automatic (see initialize()). This map
  // only controls, once a collision is already found: (1) which option is
  // the default, and (2) display order. Anything not listed here still
  // gets detected and shown — just with Dart's natural set order.
  static const Map<String, List<String>> _preferredOrder = {
    '𑄥𑄧': ['স', 'শ', 'ষ'],
    '𑄥': ['সা', 'শা', 'ষা'],
    '𑄥𑄨': ['সি', 'শি', 'ষি'],
    '𑄥𑄩': ['সী', 'শী', 'ষী'],
    '𑄥𑄪': ['সু', 'শু', 'ষু'],
    '𑄥𑄫': ['সূ', 'শূ', 'ষূ'],
    '𑄥𑄬': ['সে', 'শে', 'ষে'],
    '𑄥𑄰': ['সৈ', 'শৈ', 'ষৈ'],
    '𑄥𑄮': ['সো', 'শো', 'ষো'],
    '𑄥𑄯': ['সৌ', 'শৌ', 'ষৌ'],
    '𑄥𑄧𑄁': ['সং', 'শং', 'ষং'],
    '𑄥𑄧𑄂': ['সঃ', 'শঃ', 'ষঃ'],
    '𑄥𑄧𑄀': ['সঁ', 'শঁ', 'ষঁ'],
    '𑄥𑄴': ['স্', 'শ্', 'ষ্'],

    '𑄢𑄧': ['র', 'ড়', 'ঢ়'],
    '𑄢': ['রা', 'ড়া', 'ঢ়া'],
    '𑄢𑄨': ['রি', 'ঋ', 'ড়ি', 'ঢ়ি'],
    '𑄢𑄩': ['রী', 'ড়ী', 'ঢ়ী'],
    '𑄢𑄪': ['রু', 'ড়ু', 'ঢ়ু'],
    '𑄢𑄫': ['রূ', 'ড়ূ', 'ড়ূ'],
    '𑄢𑄬': ['রে', 'ড়ে', 'ঢ়ে'],
    '𑄢𑄮': ['রো', 'ড়ো', 'ঢ়ো'],
    '𑄢𑄴': ['র্', 'ড়্', 'ঢ়্'],
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    final syllBn = await _loadJson('assets/data/syllabary_Bengali.json');
    final syllCk = await _loadJson('assets/data/syllabary_Chakma.json');

    final Map<String, String> rawMap = {};

    // 1. Vowels — entries like ' ং' have a leading space we strip.
    _addParallelListsStripSpace(
      rawMap,
      _asList(syllBn['vowels']),
      _asList(syllCk['vowels']),
    );

    // 2. Consonants — parallel zip (both arrays 45 entries)
    _addParallelLists(
      rawMap,
      _asList(syllBn['consonants']),
      _asList(syllCk['consonants']),
    );

    // 3. Compounds — parallel zip (both arrays 810 entries, fully aligned)
    _addParallelLists(
      rawMap,
      _asList(syllBn['compounds']),
      _asList(syllCk['compounds']),
    );

    // 4. Conjuncts — loaded in parallel for speed
    final conjResults = await Future.wait(
      _conjunctFilePairs.map((p) => _loadConjunctPair(p.$1, p.$2)),
    );
    for (final m in conjResults) {
      rawMap.addAll(m);
    }

    // 5. Numerals + punctuation
    rawMap.addAll(_extras);

    // Strip & prefix (variant marker), deduplicate
    final Map<String, String> cleaned = {};
    rawMap.forEach((k, v) {
      final cleanK = k.startsWith('&') ? k.substring(1) : k;
      final cleanV = v.startsWith('&') ? v.substring(1) : v;
      if (cleanK.isNotEmpty && cleanV.isNotEmpty) cleaned[cleanK] = cleanV;
    });

    // Sort longest-key-first for greedy matching (Bengali -> Chakma)
    final sorted = cleaned.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    _bengaliToChakma
      ..clear()
      ..addAll(sorted);

    // ── Build reverse map + collect ALL ambiguities along the way ────────
    // Every Chakma value produced by more than one Bengali key is ambiguous
    // when going Chakma -> Bengali, because the Chakma script doesn't
    // distinguish those Bengali letters.
    final Map<String, Set<String>> collisions = {};
    for (final e in sorted) {
      collisions.putIfAbsent(e.value, () => {}).add(e.key);
    }

    _chakmaAmbiguities.clear();
    final Map<String, String> rev = {};

    collisions.forEach((chakmaVal, bengaliOptions) {
      if (bengaliOptions.length <= 1) {
        rev[chakmaVal] = bengaliOptions.first;
        return;
      }
      final preferred = _preferredOrder[chakmaVal];
      final ordered = preferred != null
          ? [
        ...preferred.where(bengaliOptions.contains),
        ...bengaliOptions.where((o) => !preferred.contains(o)),
      ]
          : bengaliOptions.toList();
      _chakmaAmbiguities[chakmaVal] = ordered;
      rev[chakmaVal] = ordered.first; // default = first preferred option
    });

    _chakmaToBengali
      ..clear()
      ..addAll(rev.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length)));

    _isInitialized = true;
  }

  // ── Extras ───────────────────────────────────────────────────────────────
  static const Map<String, String> _extras = {
    'ং': '𑄁', 'ঃ': '𑄂', 'ঁ': '𑄀', '্': '𑄴',
    '০': '𑄶', '১': '𑄷', '২': '𑄸', '৩': '𑄹', '৪': '𑄺',
    '৫': '𑄻', '৬': '𑄼', '৭': '𑄽', '৮': '𑄾', '৯': '𑄿',
    '।': '𑅃',
  };

  // All Bengali consonants that can follow a hasanta and form a conjunct —
  // used to detect the joined-ligature-vs-ZWNJ-separated ambiguity.
  static const String _bengaliConsonants =
      'ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ৎ ড় ঢ় য়';

  static final Set<int> _bengaliConsonantCodes =
  _bengaliConsonants.split(' ').map((c) => c.runes.first).toSet();

  /// Simple one-direction transliteration with no ambiguity info — picks
  /// the default/preferred option everywhere. Use
  /// [transliterateWithSuggestions] when you want to surface alternatives.
  String transliterate(String input, TransliterationDirection direction) {
    return _rawTransliterate(input, direction);
  }

  String _rawTransliterate(String input, TransliterationDirection direction) {
    if (!_isInitialized || input.isEmpty) return input;

    final table = direction == TransliterationDirection.bengaliToChakma
        ? _bengaliToChakma
        : _chakmaToBengali;

    final buffer = StringBuffer();
    final runes = input.runes.toList();
    int i = 0;

    while (i < runes.length) {
      bool matched = false;
      for (final entry in table) {
        final keyRunes = entry.key.runes.toList();
        if (i + keyRunes.length <= runes.length) {
          bool eq = true;
          for (int j = 0; j < keyRunes.length; j++) {
            if (runes[i + j] != keyRunes[j]) {
              eq = false;
              break;
            }
          }
          if (eq) {
            buffer.write(entry.value);
            i += keyRunes.length;
            matched = true;
            break;
          }
        }
      }
      if (!matched) {
        buffer.writeCharCode(runes[i]);
        i++;
      }
    }

    return buffer.toString();
  }

  /// Kept for backwards-compatible call sites that only need plain text.
  String rawTransliterate(String input, TransliterationDirection direction) =>
      _rawTransliterate(input, direction);

  /// Transliterates [input] and, for Chakma -> Bengali, also returns EVERY
  /// ambiguous segment found — consonant collisions (স/শ/ষ, ড/ড়, ঢ/ঢ়, ঋ/রি,
  /// etc.) AND hasanta+consonant joined-vs-separated — all in one list, so
  /// the UI can resolve every ambiguity in a single inline view.
  TransliterationResult transliterateWithSuggestions(
      String input,
      TransliterationDirection direction,
      ) {
    input = input
        .replaceAll('\u09AF\u09BC', '\u09DF')
        .replaceAll('\u09A1\u09BC', '\u09DC')
        .replaceAll('\u09A2\u09BC', '\u09DD');

    if (!_isInitialized || input.isEmpty) {
      return TransliterationResult(text: input, segments: const []);
    }

    if (direction == TransliterationDirection.bengaliToChakma) {
      return TransliterationResult(
        text: _rawTransliterate(input, direction),
        segments: const [],
      );
    }

    // ── Chakma -> Bengali: match token-by-token, recording every collision ─
    final table = _chakmaToBengali;
    final runes = input.runes.toList();
    final outBuffer = StringBuffer();
    final segments = <AmbiguousSegment>[];
    int i = 0;
    int outRuneIndex = 0; // tracks position in OUTPUT (rune count so far)

    while (i < runes.length) {
      bool matched = false;
      for (final entry in table) {
        final keyRunes = entry.key.runes.toList();
        if (i + keyRunes.length <= runes.length) {
          bool eq = true;
          for (int j = 0; j < keyRunes.length; j++) {
            if (runes[i + j] != keyRunes[j]) {
              eq = false;
              break;
            }
          }
          if (eq) {
            final defaultValue = entry.value;
            outBuffer.write(defaultValue);
            outRuneIndex += defaultValue.runes.length;
            i += keyRunes.length;
            matched = true;
            break;
          }
        }
      }
      if (!matched) {
        final ch = String.fromCharCode(runes[i]);
        outBuffer.write(ch);
        outRuneIndex += 1;
        i++;
      }
    }

    final text = outBuffer.toString();

    // Hasanta+consonant ambiguity: joined ligature vs ZWNJ-separated.
    // Detected AFTER the main pass since it depends on adjacency of two
    // already-placed Bengali characters, not a single Chakma token.
    segments.addAll(_findHasantaSegments(text));

    return TransliterationResult(text: text, segments: segments);
  }

  /// Scans [text] for hasanta (্) immediately followed by a consonant and
  /// returns one [AmbiguousSegment] per occurrence: option[0] = joined
  /// ligature (current text as-is), option[1] = ZWNJ-separated form.
  List<AmbiguousSegment> _findHasantaSegments(String text) {
    final result = <AmbiguousSegment>[];
    final runes = text.runes.toList();
    const hasanta = '্';
    final hasantaCode = hasanta.runes.first;

    for (int i = 0; i < runes.length; i++) {
      if (runes[i] == hasantaCode &&
          i + 1 < runes.length &&
          _bengaliConsonantCodes.contains(runes[i + 1])) {
        final joined = String.fromCharCode(hasantaCode);
        final separated = '$joined\u200c';
        result.add(AmbiguousSegment(
          startIndex: i,
          length: 1, // just the hasanta char; separated option adds ZWNJ after it
          chakmaSource: '𑄴', // Chakma hasanta, for display context
          options: [joined, separated],
          current: joined,
        ));
      }
    }
    return result;
  }

  /// Applies a chosen replacement for one ambiguous segment within [text],
  /// given the segment's original startIndex/length and the new value.
  /// Returns the updated full string.
  String applySegmentChoice({
    required String text,
    required AmbiguousSegment segment,
    required String newValue,
  }) {
    final runes = text.runes.toList();
    final before = String.fromCharCodes(runes.sublist(0, segment.startIndex));
    final after = String.fromCharCodes(
      runes.sublist(segment.startIndex + segment.length),
    );
    return before + newValue + after;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, String>> _loadConjunctPair(
      String bnPath, String ckPath) async {
    final result = <String, String>{};
    try {
      final conjBn = await _loadJson(bnPath);
      final conjCk = await _loadJson(ckPath);
      for (final cat in _conjunctCategories) {
        _addParallelLists(result, _asList(conjBn[cat]), _asList(conjCk[cat]));
      }
    } catch (_) {
      // file missing — skip
    }
    return result;
  }

  void _addParallelListsStripSpace(
      Map<String, String> map,
      List<String> keys,
      List<String> values,
      ) {
    final len = keys.length < values.length ? keys.length : values.length;
    for (int i = 0; i < len; i++) {
      var k = keys[i];
      final v = values[i];
      if (k.startsWith(' ')) k = k.substring(1);
      if (k.isNotEmpty && v.isNotEmpty) map[k] = v;
    }
  }

  void _addParallelLists(
      Map<String, String> map, List<String> keys, List<String> values) {
    final len = keys.length < values.length ? keys.length : values.length;
    for (int i = 0; i < len; i++) {
      if (keys[i].isNotEmpty && values[i].isNotEmpty) map[keys[i]] = values[i];
    }
  }

  Future<Map<String, dynamic>> _loadJson(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return json.decode(raw) as Map<String, dynamic>;
  }

  List<String> _asList(dynamic value) {
    if (value == null) return [];
    return (value as List).map((e) => e.toString()).toList();
  }

  int get mappingCount => _bengaliToChakma.length;
  bool get isInitialized => _isInitialized;
}