// import 'package:flutter/material.dart';
// import '../../widgets/gradient_background.dart';

// class HomePage extends StatelessWidget {
//   HomePage({Key? key}) : super(key: key);

//   final BorderRadius _radius = BorderRadius.circular(18);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       // penting agar gradient tampak juga di area bawah (di balik NavigationBar)
//       extendBody: true,
//       backgroundColor: Colors.transparent,

//       body: GradientBackground(
//         // kalau mau sudut gradasi miring: begin: Alignment.topLeft, end: Alignment.bottomRight,
//         child: SafeArea(
//           child: Column(
//             children: [
//               // ===== Header =====
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                 child: Row(
//                   children: [
//                     Text(
//                       'Hi, Coach Umar',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       onPressed: () {},
//                       icon: const Icon(Icons.notifications_none),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pushNamed(context, '/settings'),
//                       icon: const Icon(Icons.settings_outlined),
//                     ),
//                   ],
//                 ),
//               ),

//               // ===== Body scrollable =====
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Athlete card
//                       Card(
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(borderRadius: _radius),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             radius: 22,
//                             backgroundColor: Colors.blue.shade50,
//                             child: const Icon(Icons.person, color: Colors.black87),
//                           ),
//                           title: const Text('Darlen Swimmers'),
//                           subtitle: const Text('Last Training • 300 m • 1:00:00 • 2:50/100m'),
//                           trailing: const Icon(Icons.chevron_right),
//                           onTap: () {},
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Target Renang
//                       Card(
//                         elevation: 1,
//                         color: const Color(0xFFF2EDF9),
//                         shape: RoundedRectangleBorder(borderRadius: _radius),
//                         child: ListTile(
//                           leading: const Icon(Icons.flag, color: Colors.black87),
//                           title: const Text('Target Renang'),
//                           trailing: const Icon(Icons.chevron_right),
//                           onTap: () => Navigator.pushNamed(context, '/target'),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Mini Dashboard + tombol
//                       Row(
//                         children: [
//                           Text(
//                             'Mini Dashboard',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),

//                       // 3 mini stats
//                       Row(
//                         children: const [
//                           _MiniStatCard(value: '300 m', label: 'Distance'),
//                           SizedBox(width: 10),
//                           _MiniStatCard(value: '50 min', label: 'Time'),
//                           SizedBox(width: 10),
//                           _MiniStatCard(value: '2:50/100m', label: 'Pace'),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       TextButton.icon(
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.blue.shade700,
//                           backgroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                         ),
//                         onPressed: () => Navigator.pushNamed(context, '/dashboard'),
//                         icon: const Icon(Icons.show_chart, size: 18),
//                         label: const Text('Open Dashboard'),
//                       ),

//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),

//               // ===== Bottom nav transparan =====
//               NavigationBarTheme(
//                 data: NavigationBarThemeData(
//                   backgroundColor: Colors.white, // tipis supaya gradasi tetap terlihat
//                   surfaceTintColor: Colors.transparent,
//                   indicatorColor: Colors.white,
//                   shadowColor: Colors.transparent,
//                 ),
//                 child: NavigationBar(
//                   selectedIndex: 0,
//                   onDestinationSelected: (i) {
//                     switch (i) {
//                       case 0:
//                         break;
//                       case 1:
//                         Navigator.pushNamed(context, '/target');
//                         break;
//                       case 2:
//                         Navigator.pushNamed(context, '/dashboard');
//                         break;
//                       case 3:
//                         Navigator.pushNamed(context, '/settings');
//                         break;
//                     }
//                   },
//                   destinations: const [
//                     NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
//                     NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Target'),
//                     NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
//                     NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _MiniStatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   const _MiniStatCard({required this.value, required this.label, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               const Divider(height: 10),
//               Text(label, style: const TextStyle(color: Colors.black54)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
