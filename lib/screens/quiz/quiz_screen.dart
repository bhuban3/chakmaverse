import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, String>> _pool = [];
  final _rng = Random();
  
  int _questionIndex = 0;
  int _score = 0;
  String? _selected;
  bool _answered = false;
  bool _isLoading = true;
  bool _quizCompleted = false;
  
  late List<String> _options;
  late Map<String, String> _current;
  late List<Map<String, String>> _sessionQuestions;

  static const int _maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final alphabetsJson = await rootBundle.loadString('assets/data/alphabets.json');
      final wordsJson = await rootBundle.loadString('assets/data/words.json');
      
      final alphabetsData = json.decode(alphabetsJson);
      final wordsData = json.decode(wordsJson);

      // Add consonants
      for (var item in alphabetsData['consonants']) {
        _pool.add({
          'chakma': item['letter'],
          'answer': item['meaning'],
        });
      }

      // Add vowels
      for (var item in alphabetsData['vowels']) {
        _pool.add({
          'chakma': item['letter'],
          'answer': item['meaning'],
        });
      }

      // Add words
      for (var item in wordsData) {
        _pool.add({
          'chakma': item['chakma'],
          'answer': item['bangla'],
        });
      }

      _startNewRound();
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
    }
  }

  void _startNewRound() {
    setState(() {
      _pool.shuffle(_rng);
      _sessionQuestions = _pool.take(_maxQuestions).toList();
      _questionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _isLoading = false;
      _newQuestion();
    });
  }

  void _newQuestion() {
    _current = _sessionQuestions[_questionIndex];
    
    // Generate options
    final allAnswers = _pool.map((e) => e['answer']!).toSet();
    allAnswers.remove(_current['answer']);
    
    final wrongs = allAnswers.toList()..shuffle(_rng);
    _options = [
      _current['answer']!,
      ...wrongs.take(3),
    ]..shuffle(_rng);

    _selected = null;
    _answered = false;
  }

  void _select(String option) {
    if (_answered) return;
    HapticFeedback.selectionClick();
    
    final isCorrect = option == _current['answer'];
    setState(() {
      _selected = option;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _next() {
    if (_questionIndex < _maxQuestions - 1) {
      setState(() {
        _questionIndex++;
        _newQuestion();
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizCompleted) {
      return _buildResultsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('কুইজ'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_questionIndex + 1) / _maxQuestions,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            minHeight: 6,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'প্রশ্ন ${_questionIndex + 1} / $_maxQuestions',
                        style: const TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'স্কোর: $_score',
                          style: const TextStyle(
                            fontFamily: 'NotoSansBengali',
                            fontSize: 14,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question card
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'এই চাকমা শব্দ বা বর্ণটির বাংলা কী?',
                              style: TextStyle(
                                fontFamily: 'NotoSansBengali',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _current['chakma']!,
                              style: const TextStyle(
                                fontFamily: 'NotoSansChakma',
                                fontSize: 64,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Options
                  ..._options.map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _OptionButton(
                      label: opt,
                      selected: _selected == opt,
                      correct: opt == _current['answer'],
                      answered: _answered,
                      onTap: () => _select(opt),
                    ),
                  )),

                  const SizedBox(height: 24),
                  
                  AnimatedOpacity(
                    opacity: _answered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: _answered ? _next : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _questionIndex < _maxQuestions - 1 ? 'পরবর্তী প্রশ্ন' : 'ফলাফল দেখুন',
                        style: const TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _maxQuestions) * 100;
    String message = '';
    IconData icon = Icons.emoji_events;
    Color color = AppTheme.accent;

    if (percentage >= 80) {
      message = 'অসাধারণ! আপনি দারুণ করেছেন।';
      icon = Icons.stars;
    } else if (percentage >= 50) {
      message = 'ভালো হয়েছে! আরেকটু চেষ্টা করুন।';
      icon = Icons.thumb_up;
      color = AppTheme.primary;
    } else {
      message = 'আরো অনুশীলন প্রয়োজন।';
      icon = Icons.refresh;
      color = AppTheme.errorColor;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 24),
            const Text(
              'কুইজ সম্পন্ন!',
              style: TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'আপনার স্কোর',
                    style: TextStyle(
                      fontFamily: 'NotoSansBengali',
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score / $_maxQuestions',
                    style: TextStyle(
                      fontFamily: 'NotoSansBengali',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: _startNewRound,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'আবার শুরু করুন',
                style: TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ফিরে যান',
                style: TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool correct;
  final bool answered;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.selected,
    required this.correct,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppTheme.divider;
    Color bgColor = AppTheme.cardBg;
    Color textColor = AppTheme.textPrimary;

    if (answered) {
      if (correct) {
        borderColor = const Color(0xFF1A6B45);
        bgColor = const Color(0xFFE8F5EE);
        textColor = const Color(0xFF0F4A2F);
      } else if (selected) {
        borderColor = const Color(0xFFD32F2F);
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: answered ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: selected || (answered && correct) ? 2.5 : 1.5,
            ),
            boxShadow: selected ? [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NotoSansBengali',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (answered && correct)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF1A6B45), size: 28),
              if (answered && selected && !correct)
                const Icon(Icons.cancel_rounded, color: Color(0xFFD32F2F), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
