import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../translator_screen.dart';
import '../alphabet/alphabet_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../quiz/quiz_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreetingCard(context),
                const SizedBox(height: 28),
                _buildSectionLabel(context, 'প্রধান সুবিধাসমূহ'),
                const SizedBox(height: 14),
                _buildMainGrid(context),
                const SizedBox(height: 28),
                _buildSectionLabel(context, 'অন্যান্য'),
                const SizedBox(height: 14),
                _buildOthersRow(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.primaryDark,
      title: Text(
        'ChakmaVerse: Learn Chakma Language',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.primaryDark.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.primary.withValues(alpha: 0.12),
                  AppTheme.accent.withValues(alpha: 0.08),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   '𑄃𑄧𑄟𑄧𑄚𑄴𑄖𑄳𑄢𑄧',
                //   style: TextStyle(
                //     fontFamily: 'NotoSansChakma',
                //     fontSize: 22,
                //     color: isDark ? AppTheme.primaryLight : AppTheme.primaryDark,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
                const SizedBox(height: 4),
                Text(
                  'চাকমা লিপি শিখুন ও ব্যবহার করুন',
                  style: TextStyle(
                    fontFamily: 'NotoSansBengali',
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.light 
            ? AppTheme.textSecondary 
            : AppTheme.darkTextSecondary,
        letterSpacing: 0.8,
        fontFamily: 'NotoSansBengali',
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        englishLabel: 'Alphabet',
        banglaLabel: 'বর্ণমালা শিখুন',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF1A6B45),
        onTap: () => _go(context, const AlphabetScreen()),
      ),
      _FeatureItem(
        englishLabel: 'Script Converter',
        banglaLabel: 'লিপি রূপান্তর',
        icon: Icons.translate_rounded,
        color: const Color(0xFF0F6B8F),
        onTap: () => _go(context, const TranslatorScreen()),
      ),
      _FeatureItem(
        englishLabel: 'Dictionary',
        banglaLabel: 'অভিধান',
        icon: Icons.library_books_rounded,
        color: const Color(0xFF6B3A1A),
        onTap: () => _go(context, const DictionaryScreen()),
      ),
      _FeatureItem(
        englishLabel: 'Quiz',
        banglaLabel: 'কুইজ',
        icon: Icons.quiz_rounded,
        color: const Color(0xFF8F6B0F),
        onTap: () => _go(context, const QuizScreen()),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: features.map((f) => _MainFeatureCard(item: f)).toList(),
    );
  }

  // Widget _buildSecondaryRow(BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _SecondaryCard(
  //           chakmaLabel: '𑄈𑄬𑄣𑄧',
  //           banglaLabel: 'কুইজ',
  //           icon: Icons.quiz_rounded,
  //           color: const Color(0xFF8F6B0F),
  //           onTap: () => _go(context, const QuizScreen()),
  //         ),
  //       ),
  //       const SizedBox(width: 14),
  //       // Expanded(
  //       //   child: _SecondaryCard(
  //       //     chakmaLabel: '𑄥𑄬𑄖𑄨𑄁',
  //       //     banglaLabel: 'সেটিংস',
  //       //     icon: Icons.settings_rounded,
  //       //     color: const Color(0xFF3A3A3A),
  //       //     onTap: () => _go(context, const SettingsScreen()),
  //       //   ),
  //       // ),
  //     ],
  //   );
  // }

  void _go(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildOthersRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildFeedbackCard(context)),
          const SizedBox(width: 12),
          _buildSettingsCard(context),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _go(context, const SettingsScreen()),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 64,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardBg : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.settings_rounded,
              color: AppTheme.primary,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchEmail(),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardBg : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.feedback_rounded,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'মতামত দিন',
                        style: TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'আপনার মূল্যবান মতামত আমাদের জানান',
                        style: TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'chakmaverse@gmail.com',
      query: encodeQueryParameters({
        'subject': 'Feedback for ChakmaVerse App',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint('Could not launch email client');
    }
  }
}

class _FeatureItem {
  final String englishLabel;
  final String banglaLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.englishLabel,
    required this.banglaLabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _MainFeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _MainFeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardBg : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: item.color.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const Spacer(),
                Text(
                  item.englishLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: item.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.banglaLabel,
                  style: TextStyle(
                    fontFamily: 'NotoSansBengali',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

