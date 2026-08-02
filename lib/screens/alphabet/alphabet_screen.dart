import 'package:flutter/material.dart';
import '../../widgets/chakma_alphabet_chart.dart';
import '../../widgets/majharapat_chart.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বর্ণমালা শিখুন'),
        backgroundColor: const Color(0xFF1B5E20),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD600),
          indicatorWeight: 4,
          labelColor: const Color(0xFFFFD600),
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            fontFamily: 'NotoSansBengali',
          ),
          tabs: const [
            Tab(text: 'অঝাপাত'),
            Tab(text: 'মাজারাপাত'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF2E7D32),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OjhapathWidget(),
          MajharapathWidget(),
        ],
      ),
    );
  }
}

class OjhapathWidget extends StatelessWidget {
  const OjhapathWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Keeping alphabets in Ojhapath section as requested
    return const ChakmaAlphabetChart();
  }
}

class MajharapathWidget extends StatelessWidget {
  const MajharapathWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MajharaPatEntry>>(
      future: MajharaPatData.load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD600)),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          child: MajharaPatSection(entries: snapshot.data!),
        );
      },
    );
  }
}
