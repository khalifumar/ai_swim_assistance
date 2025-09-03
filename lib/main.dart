import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/dashboard/dashboard_feature.dart';
import 'services/csv_live_feed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // siapkan feed CSV
  final feed = CsvLiveFeed();
  await feed.loadFromAssets(
    tapperCsv: 'assets/data/ai_tapper_v2.csv',
    motionCsv: 'assets/data/ai_motion_v2.csv',
  );
  feed.start(intervalSeconds: 1.0); // 1 baris per detik (simulasi realtime)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => feed),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Swim Assistance',
      routes: {
        '/': (_) => const DashboardFeature(),
        '/dashboard': (_) => const DashboardFeature(),
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'features/target/target_feature.dart';
// import 'features/dashboard/dashboard_feature.dart';
// import 'services/ubidots_mqtt.dart';
// import 'services/ubidots_rest.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';



// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 1) Muat token dari .env
//   await dotenv.load(fileName: '.env');
//   final token = dotenv.env['UBIDOTS_TOKEN'] ?? '';

//   // 2) Buat service
//   final mqtt = UbidotsMqtt(token);
//   final rest = UbidotsRest(token);

//   // 3) Koneksikan MQTT terlebih dulu (biar halaman dapat data sejak awal)
//   await mqtt.connect();

//   // 4) Bungkus app-mu dengan Provider
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => mqtt),
//         Provider(create: (_) => rest),
//       ],
//       child: const CoachingSwimmingApp(),
//     ),
//   );
// }

// class CoachingSwimmingApp extends StatelessWidget {
//   const CoachingSwimmingApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Coaching Swimming',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.indigo,
//         scaffoldBackgroundColor: const Color(0xFFF7F7FA),
//         cardTheme: const CardThemeData(   // ✅ gunakan CardThemeData
//           elevation: 0.5,
//           margin: EdgeInsets.symmetric(vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(16)),
//           ),
//         ),
//       ),

//       routes: {
//         '/': (_) => const HomePage(),
//         '/target': (_) => const TargetFeaturePage(),
//         '/dashboard': (_) => const DashboardFeature(),
//         '/settings': (_) => const SettingsPage(),
//       },
//       initialRoute: '/',
//     );
//   }
// }

// /// ---------- HOME PAGE ----------
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 82, 197, 255),
//       appBar: AppBar(
//         toolbarHeight: 110, // default 56, bisa disesuaikan
//         title: const Padding(
//           padding: EdgeInsets.only(top: 10, left: 10),
//            // geser judul sedikit ke bawah
//           child: Text(
//             'Hi, Coach Umar',
//             style: TextStyle(fontFamily: "Lexend", color: Colors.black),
//           ),
//         ),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
//           IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),

//           const SizedBox(width: 10),
//         ],
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // COACH PROFILE
//             _ProfileCard(
//               name: 'Darlen Swimmers',
//               subtitle: 'Last Training • 300 m • 1:00:00 • 2:50/100m',
//               onTap: () {},
//             ),

//             // FEATURE TARGET RENANG
//             _FeatureButton(
//               icon: Icons.flag_outlined,
//               title: 'Target Renang',
//               onPressed: () {
//                 Navigator.pushNamed(context, '/target');
//               },
//             ),

//             const SizedBox(height: 12),

//             // FEATURE MINI DASHBOARD ANALISIS
//             _MiniDashboard(
//               onOpenDetail: () => Navigator.pushNamed(context, '/dashboard'),
//             ),

//             const SizedBox(height: 8),

//             // REKOMENDASI (contoh tambahan, opsional)
//             Text('Recommended', style: Theme.of(context).textTheme.titleMedium),
            
//             // FEATURE SEARCHING
//             _FeatureButton(
//               icon: Icons.search,
//               title: 'Search plan / workout',
//               onPressed: () {
//                 Navigator.pushNamed(context, '/target'); // arahkan ke planning/target
//               },
//             ),

//             Card(
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(16),
//                 leading: const CircleAvatar(child: Icon(Icons.pool)),
//                 title: const Text('Speed & Endurance Triathlon'),
//                 subtitle: const Text('Beginner • Complete a speed and endurance triathlon.'),
//                 trailing: IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
//                 onTap: () => Navigator.pushNamed(context, '/target'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: buildBottomNav(context, 0),
//     );
//   }
// }

// /// ---------- REUSABLE WIDGETS ----------
// class _ProfileCard extends StatelessWidget {
//   final String name;
//   final String subtitle;
//   final VoidCallback onTap;
//   const _ProfileCard({required this.name, required this.subtitle, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Row(
//             children: [
//               const CircleAvatar(radius: 25, child: Icon(Icons.person)),
              
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(name, style: Theme.of(context).textTheme.titleMedium),
//                     const SizedBox(height: 4),
//                     Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FeatureButton extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onPressed;
//   const _FeatureButton({
//     required this.icon,
//     required this.title,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: Icon(icon, size: 20),
//         title: Text(title, style: Theme.of(context).textTheme.titleMedium),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 13),
//         onTap: onPressed,
//       ),
//     );
//   }
// }

// class _MiniDashboard extends StatelessWidget {
//   final VoidCallback onOpenDetail;
//   const _MiniDashboard({required this.onOpenDetail});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Mini Dashboard', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               Row(
//                 children: const [
//                   Expanded(child: _MetricTile(label: 'Distance', value: '300 m')),
//                   SizedBox(width: 8),
//                   Expanded(child: _MetricTile(label: 'Time', value: '50 min')),
//                   SizedBox(width: 8),
//                   Expanded(child: _MetricTile(label: 'Pace', value: '2:50/100m')),
//                 ],
//               ),
              
//             ],
//           ),
//         ),
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton.icon(
//             onPressed: onOpenDetail,
//             icon: const Icon(Icons.insights, color: Colors.black),
//             label: const Text('Open Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _MetricTile extends StatelessWidget {
//   final String label;
//   final String value;
//   const _MetricTile({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//         child: Column(
//           children: [
//             Text(value, style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 4),
//             Text(label, style: Theme.of(context).textTheme.bodySmall),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ---------- BOTTOM NAV (dipakai semua halaman) ----------
// Widget buildBottomNav(BuildContext context, int currentIndex) {
//   void go(int i) {
//     switch (i) {
//       case 0:
//         if (currentIndex != 0) Navigator.pushReplacementNamed(context, '/');
//         break;
//       case 1:
//         if (currentIndex != 1) Navigator.pushReplacementNamed(context, '/target');
//         break;
//       case 2:
//         if (currentIndex != 2) Navigator.pushReplacementNamed(context, '/dashboard');
//         break;
//       case 3:
//         if (currentIndex != 3) Navigator.pushReplacementNamed(context, '/settings');
//         break;
//     }
//   }

//   return NavigationBar(
//     selectedIndex: currentIndex,
//     onDestinationSelected: go,
//     destinations: const [
//       NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
//       NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Target'),
//       NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
//       NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
//     ],
//   );
// }

// /// ---------- SETTINGS (placeholder) ----------
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: const Center(child: Text('Settings placeholder')),
//       bottomNavigationBar: buildBottomNav(context, 3),
//     );
//   }
// }
