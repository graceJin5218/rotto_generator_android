import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotto_app/models/draw_result_data_provider.dart';
import 'package:rotto_app/screens/compare_result_screen.dart';
import 'package:rotto_app/theme.dart';
import 'screens/generator_screen.dart';
import 'screens/saved_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LottoApp()));
}

class LottoApp extends ConsumerStatefulWidget {
  const LottoApp({super.key});

  @override
  ConsumerState<LottoApp> createState() => _LottoAppState();
}

class _LottoAppState extends ConsumerState<LottoApp> {

  @override
  Widget build(BuildContext context) {

    ref.read(drawResultDataProvider);

    return MaterialApp(
      title: '로또 번호 생성기',
      theme: lottoTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = [
    const GeneratorScreen(),
    const SavedScreen(),
    const CompareResultScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: kAccentColor,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: '생성'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: '저장됨'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '당첨확인'),
        ],
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
      ),
    );
  }
}
