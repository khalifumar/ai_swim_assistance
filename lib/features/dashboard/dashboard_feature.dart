// import 'dart:async';
// import 'dart:math' as math;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../services/live_data.dart';
// import '../../widgets/gradient_background.dart';

// class DashboardFeature extends StatefulWidget {
//   const DashboardFeature({super.key});

//   @override
//   State<DashboardFeature> createState() => _DashboardFeatureState();
// }

// class _DashboardFeatureState extends State<DashboardFeature> {
//   Timer? _tick;

//   // Series Stroke Rate (spm)
//   final List<FlSpot> _spmSeries = [];
//   double _t = 0;
//   DateTime? _lastUpdate;

//   @override
//   void initState() {
//     super.initState();
//     _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
//   }

//   @override
//   void dispose() {
//     _tick?.cancel();
//     super.dispose();
//   }

//   void _onTick() {
//     if (!mounted) return;
//     final live = context.read<LiveData>();
//     final aim = live.last['aimotionscema'] ?? {};

//     // Ambil stroke_rate_spm; jika null → tahan nilai terakhir
//     double spm = _n(aim['stroke_rate_spm']);
//     if (!spm.isFinite) {
//       spm = _spmSeries.isNotEmpty ? _spmSeries.last.y : 0.0;
//     }

//     _t += 1.0;

//     setState(() {
//       _spmSeries.add(FlSpot(_t, spm));

//       // jaga window 30 detik
//       if (_spmSeries.length > 30) {
//         _spmSeries.removeAt(0);
//         final base = _spmSeries.first.x;
//         for (var i = 0; i < _spmSeries.length; i++) {
//           _spmSeries[i] = FlSpot(_spmSeries[i].x - base, _spmSeries[i].y);
//         }
//         _t = _spmSeries.last.x;
//       }

//       _lastUpdate = live.lastTick ?? DateTime.now();
//     });
//   }

//   double _n(dynamic v, [double d = 0]) {
//     if (v is num) return v.toDouble();
//     if (v is String) {
//       final p = num.tryParse(v.trim());
//       if (p != null) return p.toDouble();
//     }
//     return d;
//   }

//   double _deg(double v) {
//     if (!v.isFinite) return 0;
//     var x = v % 360;
//     if (x > 180) x -= 360;
//     if (x < -180) x += 360;
//     return x;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final live = context.watch<LiveData>();
//     final aim = live.last['aimotionscema'] ?? {};
//     final tap = live.last['ai_tapper'] ?? {};

//     // KPI
//     final distWallM = tap['time_to_wall_s'] != null
//         ? _n(tap['time_to_wall_s']) / 100.0
//         : _n(tap['distance_cm']);
//     final tapCount = _n(tap['tap_count'], _n(tap['tap'])).toInt();

//     final strokeRate = _n(aim['stroke_rate_spm']);
//     final lapSpeed = _n(aim['lap_speed_mps']);
//     final strokeType = (aim['stroke_type'] ?? '-').toString();

//     final roll = _deg(_n(aim['body_roll_deg']));
//     final pitch = _deg(_n(aim['pitch_deg']));
//     final yaw = _deg(_n(aim['yaw_deg']));

//     final ax = _n(aim['accel_x']);
//     final ay = _n(aim['accel_y']);
//     final az = _n(aim['accel_z']);
//     final gx = _n(aim['gyro_x']);
//     final gy = _n(aim['gyro_y']);
//     final gz = _n(aim['gyro_z']);

//     // ===== Auto-scale chart untuk spm (PERBAIKAN: bertipe double) =====
//     final double windowMax = _spmSeries.isEmpty
//         ? 0.0
//         : _spmSeries.map((e) => e.y).reduce((a, b) => a > b ? a : b);

//     // minimal 40 spm agar grid enak dilihat, tapi tidak lebih dari 200
//     final double chartMaxY =
//         math.max(40.0, (windowMax * 1.2).clamp(0.0, 200.0).toDouble());

//     final double leftInterval =
//         chartMaxY <= 30.0 ? 10.0 : (chartMaxY / 6.0).ceilToDouble();

//     final width = MediaQuery.of(context).size.width;
//     final cardW = (width - 16 * 2 - 12) / 2; // 2 kolom

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text('Dashboard (Live CSV)'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: LiveBadge(lastUpdate: _lastUpdate),
//           ),
//         ],
//       ),
//       body: GradientBackground(
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               // ===== KPI =====
//               Wrap(spacing: 12, runSpacing: 12, children: [
//                 MetricCard(
//                   title: 'Distance to Wall',
//                   value: '${distWallM.toStringAsFixed(2)} cm',
//                   icon: Icons.social_distance,
//                   color: Colors.blue,
//                   width: cardW,
//                 ),
//                 MetricCard(
//                   title: 'Tap Count',
//                   value: '$tapCount',
//                   icon: Icons.touch_app,
//                   color: Colors.teal,
//                   width: cardW,
//                 ),
//                 MetricCard(
//                   title: 'Stroke Rate',
//                   value: '${strokeRate.toStringAsFixed(1)} spm',
//                   icon: Icons.speed,
//                   color: Colors.orange,
//                   width: cardW,
//                 ),
//                 MetricCard(
//                   title: 'Lap Speed',
//                   value: '${lapSpeed.toStringAsFixed(2)} m/s',
//                   icon: Icons.pool,
//                   color: Colors.indigo,
//                   width: cardW,
//                 ),
//                 MetricCard(
//                   title: 'Stroke Type',
//                   value: strokeType,
//                   icon: Icons.label,
//                   color: Colors.purple,
//                   width: cardW,
//                 ),
//                 SizedBox(
//                   width: cardW,
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(children: const [
//                             Icon(Icons.explore, color: Colors.grey),
//                             SizedBox(width: 8),
//                             Text('Orientation'),
//                           ]),
//                           const SizedBox(height: 8),
//                           Wrap(spacing: 8, runSpacing: 8, children: [
//                             _chip('Roll', '${roll.toStringAsFixed(1)}°'),
//                             _chip('Pitch', '${pitch.toStringAsFixed(1)}°'),
//                             _chip('Yaw', '${yaw.toStringAsFixed(1)}°'),
//                           ]),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ]),

//               const SizedBox(height: 16),

//               // ===== Stroke Rate Chart =====
//               Text('Stroke Rate (spm) – last 60s',
//                   style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: SizedBox(
//                     height: 220,
//                     child: LineChart(
//                       LineChartData(
//                         minY: 0,
//                         maxY: chartMaxY,
//                         clipData: const FlClipData.all(),
//                         gridData: const FlGridData(show: true),
//                         titlesData: FlTitlesData(
//                           leftTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               reservedSize: 40,
//                               interval: leftInterval,
//                               getTitlesWidget: (v, _) =>
//                                   Text(v.toStringAsFixed(0)),
//                             ),
//                           ),
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               interval: 10,
//                               getTitlesWidget: (v, _) => Text('${v.toInt()}s'),
//                             ),
//                           ),
//                           topTitles: const AxisTitles(
//                               sideTitles: SideTitles(showTitles: false)),
//                           rightTitles: const AxisTitles(
//                               sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: _spmSeries.isEmpty
//                                 ? [const FlSpot(0, 0)]
//                                 : _spmSeries,
//                             isCurved: true, // tren SPM lebih halus
//                             color: Colors.orange,
//                             barWidth: 3,
//                             dotData: const FlDotData(show: false),
//                             belowBarData: BarAreaData(
//                               show: true,
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.orange.withValues(alpha: 0.25),
//                                   Colors.transparent
//                                 ],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // ===== Raw Sensors =====
//               Text('Raw Sensors (aimotionscema)',
//                   style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Table(
//                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                     columnWidths: const {
//                       0: FlexColumnWidth(1),
//                       1: FlexColumnWidth(1),
//                       2: FlexColumnWidth(1),
//                     },
//                     children: [
//                       TableRow(children: [
//                         _sensorCell('Accel X (g)', ax.toStringAsFixed(3)),
//                         _sensorCell('Accel Y (g)', ay.toStringAsFixed(3)),
//                         _sensorCell('Accel Z (g)', az.toStringAsFixed(3)),
//                       ]),
//                       const TableRow(children: [
//                         SizedBox(height: 8),
//                         SizedBox(height: 8),
//                         SizedBox(height: 8),
//                       ]),
//                       TableRow(children: [
//                         _sensorCell('Gyro X (°/s)', gx.toStringAsFixed(1)),
//                         _sensorCell('Gyro Y (°/s)', gy.toStringAsFixed(1)),
//                         _sensorCell('Gyro Z (°/s)', gz.toStringAsFixed(1)),
//                       ]),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget _chip(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(100),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Text('$label: ', style: const TextStyle(color: Colors.black54)),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//       ]),
//     );
//   }

//   Widget _sensorCell(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.04),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.black12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Colors.black54)),
//           const SizedBox(height: 6),
//           Align(
//             alignment: Alignment.centerRight,
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 value,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MetricCard extends StatelessWidget {
//   final String title, value;
//   final IconData icon;
//   final Color color;
//   final double width;
//   const MetricCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//     required this.width,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       child: Card(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(minHeight: 76, maxHeight: 92),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 Icon(icon, color: color),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(title,
//                       maxLines: 2, overflow: TextOverflow.ellipsis),
//                 ),
//                 const SizedBox(width: 8),
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     value,
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LiveBadge extends StatelessWidget {
//   final DateTime? lastUpdate;
//   const LiveBadge({super.key, this.lastUpdate});

//   @override
//   Widget build(BuildContext context) {
//     final alive = lastUpdate != null &&
//         DateTime.now().difference(lastUpdate!).inSeconds <= 3;
//     return Row(mainAxisSize: MainAxisSize.min, children: [
//       Icon(Icons.circle, size: 10, color: alive ? Colors.red : Colors.grey),
//       const SizedBox(width: 6),
//       Text('LIVE',
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: alive ? Colors.red : Colors.grey)),
//     ]);
//   }
// }
