import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/transliteration_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_selector.dart';
import '../widgets/text_input_card.dart';
import '../widgets/output_card.dart';
import '../widgets/example_chips.dart';
import '../widgets/ambiguity_suggestions_card.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with SingleTickerProviderStateMixin {
  final _service = TransliterationService();
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();

  TransliterationDirection _direction =
      TransliterationDirection.bengaliToChakma;
  String _output = '';
  bool _loading = true;
  String? _error;

  // ── Ambiguity state (Chakma -> Bengali only) ───────────────────────────
  // Holds EVERY ambiguous segment found (স/শ/ষ, ড/ড়, ঢ/ঢ়, ঋ/রি, hasanta
  // joined/separated, etc.) so the inline AmbiguitySuggestionsCard can let
  // the user resolve all of them at once, right under the output.
  TransliterationResult? _suggestionResult;

  late AnimationController _swapAnimCtrl;

  @override
  void initState() {
    super.initState();
    _swapAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initService();
    _inputController.addListener(_onInputChanged);
  }

  Future<void> _initService() async {
    try {
      await _service.initialize();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load mapping data: $e';
      });
    }
  }

  void _onInputChanged() {
    final text = _inputController.text;
    if (text.isEmpty) {
      setState(() {
        _output = '';
        _suggestionResult = null;
      });
      return;
    }

    // Use transliterateWithSuggestions instead of transliterate so we get
    // every ambiguous segment (consonant collisions + hasanta) whenever
    // direction is chakmaToBengali. For bengaliToChakma it returns no
    // segments since that direction has no ambiguity.
    final result = _service.transliterateWithSuggestions(text, _direction);

    setState(() {
      _suggestionResult = result;
      _output = result.text; // default to the preferred/most-common choices
    });
  }

  void _swapDirection() {
    _swapAnimCtrl.forward(from: 0);
    HapticFeedback.lightImpact();

    setState(() {
      // Put the current output back as the new input
      final newInput = _output;
      _direction = _direction == TransliterationDirection.bengaliToChakma
          ? TransliterationDirection.chakmaToBengali
          : TransliterationDirection.bengaliToChakma;
      _inputController.text = newInput;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: newInput.length),
      );
    });
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _inputController.clear();
      _output = '';
      _suggestionResult = null;
    });
  }

  void _copyOutput() {
    if (_output.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _output));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _direction == TransliterationDirection.bengaliToChakma
                  ? 'চাকমা লিপি কপি হয়েছে'
                  : 'বাংলা লিপি কপি হয়েছে',
              style: const TextStyle(fontFamily: 'NotoSansBengali'),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _useExample(String example) {
    HapticFeedback.selectionClick();
    setState(() {
      _inputController.text = example;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: example.length),
      );
    });
  }

  /// Called whenever the user taps any option chip in
  /// AmbiguitySuggestionsCard — updates the output immediately, no
  /// confirm step needed since the card is inline, not a modal.
  void _onSuggestionChoiceChanged(String value) {
    HapticFeedback.selectionClick();
    setState(() => _output = value);
  }

  bool get _isBengaliToChakma =>
      _direction == TransliterationDirection.bengaliToChakma;

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _inputFocus.dispose();
    _swapAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'চাকমা ↔ বাংলা লিপি রূপান্তর',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'NotoSansBengali',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About',
            onPressed: _showAbout,
          ),
        ],
      ),
      body: _loading
          ? _buildLoader()
          : _error != null
          ? _buildError()
          : _buildBody(),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 20),
          Text(
            'ম্যাপিং লোড হচ্ছে…',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'NotoSansBengali',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 56),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.errorColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Show the inline ambiguity card only when converting Chakma -> Bengali
    // AND the service found at least one ambiguous segment (consonant
    // collision and/or hasanta) in this output.
    final showAmbiguityCard = !_isBengaliToChakma &&
        _suggestionResult != null &&
        _suggestionResult!.hasAmbiguity;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Direction indicator + swap
            LanguageSelector(
              isBengaliToChakma: _isBengaliToChakma,
              animController: _swapAnimCtrl,
              onSwap: _swapDirection,
            ),
            const SizedBox(height: 16),

            // Input card
            TextInputCard(
              controller: _inputController,
              focusNode: _inputFocus,
              isBengaliSource: _isBengaliToChakma,
              onClear: _clearAll,
            ),
            const SizedBox(height: 12),

            // Example chips
            ExampleChips(
              isBengaliSource: _isBengaliToChakma,
              onSelected: _useExample,
            ),
            const SizedBox(height: 16),

            // Output card
            OutputCard(
              output: _output,
              isChakmaOutput: _isBengaliToChakma,
              onCopy: _copyOutput,
              mappingCount: _service.mappingCount,
            ),

            // Ambiguity card — appears only for hasanta joined/separated choices.
            if (showAmbiguityCard)
              AmbiguitySuggestionsCard(
                variants: _suggestionResult!.wordVariants(),
                selected: _output,
                onSelected: _onSuggestionChoiceChanged,
              ),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardBg : AppTheme.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkDivider : AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'চাকমা ↔ বাংলা লিপি রূপান্তর',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                fontFamily: 'NotoSansBengali',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'এই অ্যাপটি চাকমা ও বাংলা লিপির মধ্যে স্ক্রিপ্ট-স্তরের রূপান্তর করে। '
                  'এটি শব্দ-স্তরের অনুবাদ নয় — উচ্চারণ একই থাকে, শুধু লিপি পরিবর্তন হয়।',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                height: 1.6,
                fontFamily: 'NotoSansBengali',
              ),
            ),
            const SizedBox(height: 16),
            _aboutRow(Icons.translate_rounded,
                'ব্যঞ্জন, স্বর ও যুক্তবর্ণ সহ ${_service.mappingCount}টি ম্যাপিং'),
            const SizedBox(height: 8),
            _aboutRow(Icons.swap_horiz_rounded,
                'উভয় দিকে রূপান্তর সম্ভব'),
            const SizedBox(height: 8),
            _aboutRow(Icons.font_download_outlined,
                'Noto Sans Chakma ও Bengali ফন্ট ব্যবহার করা হয়েছে'),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 15, color: isDark ? AppTheme.primaryLight : AppTheme.primary),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              fontFamily: 'NotoSansBengali',
            ),
          ),
        ),
      ],
    );
  }
}
