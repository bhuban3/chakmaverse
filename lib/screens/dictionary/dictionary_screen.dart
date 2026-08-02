import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDictionary();
    _searchController.addListener(_onSearch);
  }

  Future<void> _loadDictionary() async {
    try {
      final String response = await rootBundle.loadString('assets/data/dictionary.json');
      final data = await json.decode(response) as List;
      setState(() {
        _entries = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _filtered = _entries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading dictionary: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _entries
          : _entries.where((e) =>
              e['chakma']!.toString().contains(q) ||
              e['bangla']!.toString().contains(q) ||
              e['meaning']!.toString().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('অভিধান')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontFamily: 'NotoSansBengali'),
                    decoration: InputDecoration(
                      hintText: 'চাকমা বা বাংলায় খুঁজুন…',
                      hintStyle: const TextStyle(fontFamily: 'NotoSansBengali'),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'কোনো ফলাফল পাওয়া যায়নি',
                            style: TextStyle(
                              fontFamily: 'NotoSansBengali',
                              color: AppTheme.textHint,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _DictionaryCard(entry: _filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _DictionaryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _DictionaryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkDivider : AppTheme.divider),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry['chakma']!,
                style: TextStyle(
                  fontFamily: 'NotoSansChakma',
                  fontSize: 24,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primaryDark,
                ),
              ),
              Text(
                entry['bangla']!,
                style: TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry['meaning']!,
              style: TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
