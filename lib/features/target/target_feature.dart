// import 'package:flutter/material.dart';
// import '../../main.dart';

// class TargetFeaturePage extends StatefulWidget {
//   const TargetFeaturePage({super.key});

//   @override
//   State<TargetFeaturePage> createState() => _TargetFeaturePageState();
// }

// class _TargetFeaturePageState extends State<TargetFeaturePage> {
//   final TextEditingController _searchCtl = TextEditingController();
//   final TextEditingController _nameCtl = TextEditingController();
//   final TextEditingController _distanceCtl = TextEditingController();
//   final List<Map<String, String>> _targets = [
//     {'name': '5K Swim', 'distance': '5000 m', 'status': 'Planned'},
//     {'name': 'Endurance Month', 'distance': '20 km', 'status': 'On Going'},
//   ];

//   void _createTarget() {
//     if (_nameCtl.text.isEmpty) return;
//     setState(() {
//       _targets.add({
//         'name': _nameCtl.text,
//         'distance': _distanceCtl.text.isEmpty ? '-' : _distanceCtl.text,
//         'status': 'Planned',
//       });
//       _nameCtl.clear();
//       _distanceCtl.clear();
//     });
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target created')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Target')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Planning & Searching', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _searchCtl,
//               decoration: InputDecoration(
//                 hintText: 'Search training plans or goals…',
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
//               ),
//               onChanged: (_) => setState(() {}),
//             ),
//             const SizedBox(height: 16),

//             Text('Create Target', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: _nameCtl,
//                       decoration: const InputDecoration(labelText: 'Target name'),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _distanceCtl,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(labelText: 'Distance / Time / Pace (optional)'),
//                     ),
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       width: double.infinity,
//                       child: FilledButton.icon(
//                         onPressed: _createTarget,
//                         icon: const Icon(Icons.add),
//                         label: const Text('Create Target'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             Text('Target List', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             ..._targets
//                 .where((t) => t['name']!.toLowerCase().contains(_searchCtl.text.toLowerCase()))
//                 .map((t) => Card(
//                       child: ListTile(
//                         leading: const Icon(Icons.flag),
//                         title: Text(t['name']!),
//                         subtitle: Text('${t['distance']} • ${t['status']}'),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (v) {
//                             if (v == 'done') {
//                               setState(() => t['status'] = 'Completed');
//                             } else if (v == 'delete') {
//                               setState(() => _targets.remove(t));
//                             }
//                           },
//                           itemBuilder: (_) => const [
//                             PopupMenuItem(value: 'done', child: Text('Mark as completed')),
//                             PopupMenuItem(value: 'delete', child: Text('Delete')),
//                           ],
//                         ),
//                       ),
//                     )),
//             if (_targets.isEmpty) const Text('No target yet.'),
//           ],
//         ),
//       ),
//       bottomNavigationBar: buildBottomNav(context, 1),
//     );
//   }
// }
