import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSuggest = true;
  bool _showRoman = false;
  bool _hapticFeedback = true;
  double _fontSize = 1.0; // multiplier

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.themeNotifier.value == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel(context, 'রূপান্তর'),
          _card(context, [
            _switchTile(
              icon: Icons.auto_awesome_rounded,
              title: 'স্বয়ংক্রিয় সুপারিশ',
              subtitle: 'অস্পষ্ট শব্দে স্বয়ংক্রিয় পপআপ',
              value: _autoSuggest,
              onChanged: (v) => setState(() => _autoSuggest = v),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel(context, 'প্রদর্শন'),
          _card(context, [
            _switchTile(
              icon: Icons.dark_mode_rounded,
              title: 'ডার্ক মোড',
              subtitle: 'অন্ধকারে ব্যবহারের জন্য উপযুক্ত',
              value: AppTheme.themeNotifier.value == ThemeMode.dark,
              onChanged: (v) {
                setState(() {
                  AppTheme.themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
            const Divider(height: 1, color: AppTheme.divider),
            _switchTile(
              icon: Icons.abc_rounded,
              title: 'রোমান উচ্চারণ দেখান',
              subtitle: 'বর্ণমালায় রোমান হরফ দেখাবে',
              value: _showRoman,
              onChanged: (v) => setState(() => _showRoman = v),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_size_rounded,
                          color: isDark ? AppTheme.primaryLight : AppTheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'ফন্ট সাইজ',
                        style: TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _fontSize == 0.8
                            ? 'ছোট'
                            : _fontSize == 1.0
                                ? 'স্বাভাবিক'
                                : 'বড়',
                        style: TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    activeColor: AppTheme.primaryLight,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel(context, 'অন্যান্য'),
          _card(context, [
            _switchTile(
              icon: Icons.vibration_rounded,
              title: 'হ্যাপটিক ফিডব্যাক',
              subtitle: 'ট্যাপে কম্পন অনুভব করুন',
              value: _hapticFeedback,
              onChanged: (v) => setState(() => _hapticFeedback = v),
            ),
            Divider(height: 1, color: isDark ? AppTheme.darkDivider : AppTheme.divider),
            ListTile(
              leading: Icon(Icons.info_outline_rounded,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primary),
              title: Text(
                'সংস্করণ',
                style: TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              trailing: Text(
                '1.0.0',
                style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'NotoSansBengali',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.light 
                ? AppTheme.textSecondary 
                : AppTheme.darkTextSecondary,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _card(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppTheme.darkDivider : AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = AppTheme.themeNotifier.value == ThemeMode.dark;
    return SwitchListTile(
      secondary: Icon(icon, color: isDark ? AppTheme.primaryLight : AppTheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'NotoSansBengali',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'NotoSansBengali',
          fontSize: 12,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      value: value,
      activeThumbColor: AppTheme.primaryLight,
      onChanged: onChanged,
    );
  }
}
