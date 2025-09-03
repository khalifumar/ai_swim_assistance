import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/csv_live_feed.dart';

class DashboardFeature extends StatefulWidget {
  const DashboardFeature({super.key});
  @override
  State<DashboardFeature> createState() => _DashboardFeatureState();
}

class _DashboardFeatureState extends State<DashboardFeature> {
  Timer? _tick;
  final List<FlSpot> _distanceSeries = [];
  double _t = 0;

  DateTime? _lastUpdate;
  double? _prevDist, _prevSR;
  int? _prevTap;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
      final feed = context.watch<CsvLiveFeed>();
      final aim = feed.last['aimotionscema'] ?? {};
      final tap = feed.last['ai_tapper'] ?? {};


    final dist = _n(tap['distance_m']);
    final sr   = _n(aim['stroke_rate_spm']);
    final taps = _ni(tap['tap_count']);

    var changed = false;
    if (_prevDist == null || (dist - (_prevDist ?? dist)).abs() > 1e-9) changed = true;
    if (_prevSR == null   || (sr   - (_prevSR   ?? sr)).abs()   > 1e-9) changed = true;
    if (_prevTap == null  || taps != _prevTap) changed = true;
    if (changed) _lastUpdate = DateTime.now();
    _prevDist = dist; _prevSR = sr; _prevTap = taps;

    _t += 1.0;
    final y = dist.isFinite ? dist : (_distanceSeries.isNotEmpty ? _distanceSeries.last.y : 0.0);
    setState(() {
      _distanceSeries.add(FlSpot(_t, y));
      if (_distanceSeries.length > 60) {
        _distanceSeries.removeAt(0);
        final base = _distanceSeries.first.x;
        for (var i = 0; i < _distanceSeries.length; i++) {
          _distanceSeries[i] = FlSpot(_distanceSeries[i].x - base, _distanceSeries[i].y);
        }
        _t = _distanceSeries.last.x;
      }
    });
  }

  double _n(dynamic v, [double d = 0]) {
    if (v is num) return v.toDouble();
    if (v is String) { final p = num.tryParse(v.trim()); if (p != null) return p.toDouble(); }
    return d;
  }
  int _ni(dynamic v, [int d = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) { final p = num.tryParse(v.trim()); if (p != null) return p.toInt(); }
    return d;
  }
  // normalisasi sudut ke [-180, 180]
  double _deg(double v) {
    if (!v.isFinite) return 0;
    var x = v % 360;
    if (x > 180) x -= 360;
    if (x < -180) x += 360;
    return x;
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<CsvLiveFeed>();
    final aim = feed.last['aimotionscema'] ?? {};
    final tap = feed.last['ai_tapper'] ?? {};

    // KPI
    final distM = _n(tap['distance_m']);
    final tapCount = _ni(tap['tap_count']);
    final strokeRate = _n(aim['stroke_rate_spm']);
    final lapSpeed = _n(aim['lap_speed_mps']);
    final strokeType = (aim['stroke_type'] ?? '-').toString();

    // Orientation
    final roll = _deg(_n(aim['body_roll_deg']));
    final pitch = _deg(_n(aim['pitch_deg']));
    final yaw = _deg(_n(aim['yaw_deg']));

    // RAW
    final ax = _n(aim['accel_x']);
    final ay = _n(aim['accel_y']);
    final az = _n(aim['accel_z']);
    final gx = _n(aim['gyro_x']);
    final gy = _n(aim['gyro_y']);
    final gz = _n(aim['gyro_z']);

    final width = MediaQuery.of(context).size.width;
    final cardW = (width - 16*2 - 12) / 2; // 2 kolom, padding 16, spacing 12

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard (Live)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LiveBadge(lastUpdate: _lastUpdate),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== KPI grid (2 kolom) =====
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(title: 'Distance to Wall', value: '${distM.toStringAsFixed(2)} m', icon: Icons.social_distance, color: Colors.blue, width: cardW),
                MetricCard(title: 'Tap Count', value: '$tapCount', icon: Icons.touch_app, color: Colors.teal, width: cardW),
                MetricCard(title: 'Stroke Rate', value: '${strokeRate.toStringAsFixed(1)} spm', icon: Icons.speed, color: Colors.orange, width: cardW),
                MetricCard(title: 'Lap Speed', value: '${lapSpeed.toStringAsFixed(2)} m/s', icon: Icons.pool, color: Colors.indigo, width: cardW),
                MetricCard(title: 'Stroke Type', value: strokeType, icon: Icons.label, color: Colors.purple, width: cardW),
                // Orientation as chips
                SizedBox(
                  width: cardW,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: const [
                            Icon(Icons.explore, color: Color(0xFF9E9E9E)),
                            SizedBox(width: 8),
                            Text('Orientation'),
                          ]),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: [
                              _chip('Roll', '${roll.toStringAsFixed(1)}°'),
                              _chip('Pitch', '${pitch.toStringAsFixed(1)}°'),
                              _chip('Yaw', '${yaw.toStringAsFixed(1)}°'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===== Chart: distance_m =====
            Text('Distance (last 60s)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      minY: 0, maxY: 5,
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, reservedSize: 36, interval: 1,
                            getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, interval: 10,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}s'),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _distanceSeries.isEmpty ? [const FlSpot(0, 0)] : _distanceSeries,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [Colors.blue.withValues(alpha: 0.30), Colors.transparent],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== Raw Sensors =====
            Text('Raw Sensors (aimotionscema)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(children: [
                      _sensorCell('Accel X (g)', ax.toStringAsFixed(3)),
                      _sensorCell('Accel Y (g)', ay.toStringAsFixed(3)),
                      _sensorCell('Accel Z (g)', az.toStringAsFixed(3)),
                    ]),
                    const TableRow(children: [
                      SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8),
                    ]),
                    TableRow(children: [
                      _sensorCell('Gyro X (°/s)', gx.toStringAsFixed(1)),
                      _sensorCell('Gyro Y (°/s)', gy.toStringAsFixed(1)),
                      _sensorCell('Gyro Z (°/s)', gz.toStringAsFixed(1)),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Debug panel =====
            ExpansionTile(
              title: const Text('Debug: MQTT last values'),
              children: [
                _kvTable('aimotionscema', aim),
                const SizedBox(height: 6),
                _kvTable('aitapperscema', tap),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black12.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _sensorCell(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black12.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvTable(String title, Map data) {
    final rows = data.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(e.key, style: const TextStyle(color: Colors.black54))),
          Flexible(child: Text(e.value.toString(), textAlign: TextAlign.right)),
        ]),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              const Text('(kosong)', style: TextStyle(color: Colors.black45))
            else
              ...rows,
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final double width;
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76, maxHeight: 92),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                // nilai aman, auto-scale down bila kepanjangan
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

/// Badge "LIVE": merah jika ada update ≤3s, abu-abu jika tidak
class LiveBadge extends StatelessWidget {
  final DateTime? lastUpdate;
  const LiveBadge({super.key, this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    final alive = lastUpdate != null && DateTime.now().difference(lastUpdate!).inSeconds <= 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: alive ? Colors.red : Colors.grey),
        const SizedBox(width: 6),
        Text('LIVE', style: TextStyle(fontWeight: FontWeight.bold, color: alive ? Colors.red : Colors.grey)),
      ],
    );
  }
}
