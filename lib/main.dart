// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // untuk debugPaint* flags
import 'package:provider/provider.dart';

import 'features/home/home_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/target/target_page.dart';
import 'features/profile/profile_page.dart';
import 'features/settings/settings_page.dart';

import 'services/csv_live_feed.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan SEMUA overlay debug dimatikan di debug mode.
  assert(() {
    debugPaintSizeEnabled = false;       // <- matikan Debug Paint (kotak & label merah)
    debugPaintBaselinesEnabled = false;  // <- matikan baseline kuning
    debugPaintPointersEnabled = false;
    debugRepaintRainbowEnabled = false;
    return true;
  }());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CsvLiveFeed>(
      create: (_) {
        final feed = CsvLiveFeed();
        feed
            .loadFromAssets(
              tapperCsv: 'assets/data/ai_tapper_v2.csv',
              motionCsv: 'assets/data/ai_motion_v2.csv',
            )
            .then((_) => feed.start(intervalSeconds: 1.0));
        return feed;
      },
      child: MaterialApp(
        title: 'AI Swim Assistance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF3BA7FF),
          fontFamily: 'Roboto',
        ),

        // Jaga layout stabil & matikan overlay dari sisi app
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        showPerformanceOverlay: false,
        checkerboardOffscreenLayers: false,
        checkerboardRasterCacheImages: false,
        debugShowMaterialGrid: false,
        showSemanticsDebugger: false,

        home: const _Shell(),
        routes: {
          ProfilePage.route: (_) => const ProfilePage(),
          '/dashboard': (_) => const DashboardPage(),
          '/target': (_) => const TargetPage(),
          '/settings': (_) => const SettingsPage(),
        },
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomePage(),
      const TargetPage(),
      const DashboardPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'Target'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
