import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class TypingScreen extends StatefulWidget {
  const TypingScreen({super.key});

  @override
  State<TypingScreen> createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  final _controller = TextEditingController();
  int _currentIndex = 0;
  int _correct = 0;
  int _attempted = 0;

  static const List<Map<String, String>> _targets = [
    {'chakma': '𑄌𑄦𑄟𑄧', 'bangla': 'চাকমা'},
    {'chakma': '𑄚𑄟𑄥𑄴𑄇𑄢𑄧', 'bangla': 'নমস্কার'},
    {'chakma': '𑄝𑄁𑄣', 'bangla': 'বাংলা'},
    {'chakma': '𑄥𑄮𑄚𑄢𑄧', 'bangla': 'সোনার'},
    {'chakma': '𑄟𑄧𑄚𑄴', 'bangla': 'মন'},
  ];

  String get _targetChakma => _targets[_currentIndex]['chakma']!;
  String get _targetBangla => _targets[_currentIndex]['bangla']!;

  void _check() {
    final typed = _controller.text.trim();
    final correct = typed == _targetChakma;
    HapticFeedback.lightImpact();
    setState(() {
      _attempted++;
      if (correct) _correct++;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          correct ? '✅ সঠিক!' : '❌ ভুল',
          style: const TextStyle(fontFamily: 'NotoSansBengali'),
        ),
        content: Text(
          correct
              ? 'চমৎকার! সঠিক লিখেছেন।'
              : 'সঠিক উত্তর ছিল:\n$_targetChakma',
          style: const TextStyle(
            fontFamily: 'NotoSansBengali',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _next();
            },
            child: const Text(
              'পরবর্তী',
              style: TextStyle(fontFamily: 'NotoSansBengali'),
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _targets.length;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('টাইপিং অনুশীলন'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_correct/$_attempted',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target word to type
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  const Text(
                    'এই শব্দটি চাকমায় লিখুন:',
                    style: TextStyle(
                      fontFamily: 'NotoSansBengali',
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _targetBangla,
                    style: const TextStyle(
                      fontFamily: 'NotoSansBengali',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '(চাকমা: $_targetChakma)',
                    style: const TextStyle(
                      fontFamily: 'NatoSansChakma',
                      fontSize: 18,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input field
            TextField(
              controller: _controller,
              style: const TextStyle(
                fontFamily: 'NatoSansChakma',
                fontSize: 22,
              ),
              decoration: const InputDecoration(
                hintText: 'এখানে চাকমায় টাইপ করুন…',
                hintStyle: TextStyle(fontFamily: 'NotoSansBengali', fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _next,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'এড়িয়ে যান',
                      style: TextStyle(
                        fontFamily: 'NotoSansBengali',
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _controller.text.isEmpty ? null : _check,
                    child: const Text(
                      'জমা দিন',
                      style: TextStyle(fontFamily: 'NotoSansBengali'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
