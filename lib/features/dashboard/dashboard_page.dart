import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/aqua_background.dart';
import '../../widgets/glass_card.dart';
import '../../services/csv_live_feed.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _timer;
  final List<FlSpot> _spmSeries = [];
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    final feed = context.read<CsvLiveFeed>();
    final aim = feed.last['aimotionscema'] ?? {};
    double spm = _num(aim['stroke_rate_spm']);
    if (!spm.isFinite) {
      spm = _spmSeries.isNotEmpty ? _spmSeries.last.y : 0.0;
    }

    _t += 1.0;
    setState(() {
      _spmSeries.add(FlSpot(_t, spm));
      if (_spmSeries.length > 60) {
        _spmSeries.removeAt(0);
        final base = _spmSeries.first.x;
        for (var i = 0; i < _spmSeries.length; i++) {
          _spmSeries[i] = FlSpot(_spmSeries[i].x - base, _spmSeries[i].y);
        }
        _t = _spmSeries.last.x;
      }
    });
  }

  double _num(dynamic v, [double d = 0]) {
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = num.tryParse(v);
      if (p != null) return p.toDouble();
    }
    return d;
  }

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
    final lastTick = feed.lastTick;

    final strokeType = (aim['stroke_type'] ?? 'Freestyle').toString();
    final distWallCm = tap['time_to_wall_s'] != null
        ? _num(tap['time_to_wall_s']).toStringAsFixed(2)
        : (_num(tap['distance_cm'])).toStringAsFixed(2);
    final lapSpeed = _num(aim['lap_speed_mps']).toStringAsFixed(2);
    final strokeRate = _num(aim['stroke_rate_spm']).toStringAsFixed(1);

    final roll = _deg(_num(aim['body_roll_deg']));
    final pitch = _deg(_num(aim['pitch_deg']));
    final yaw = _deg(_num(aim['yaw_deg']));

    final double windowMax = _spmSeries.isEmpty
        ? 0.0
        : _spmSeries.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final double chartMaxY =
        math.max(40.0, (windowMax * 1.2).clamp(0.0, 200.0).toDouble());
    final double leftInterval =
        chartMaxY <= 60.0 ? 7.0 : (chartMaxY / 6.0).ceilToDouble();

    return AquaBackground(
      child: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const Text('Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),

            // ===== Body =====
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ---------- KPI 2x2 (tinggi fix -> anti overflow) ----------
                    GlassCard(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 88, // 84–96 sesuai selera
                        ),
                        itemCount: 4,
                        itemBuilder: (_, i) {
                          final items = <Map<String, String>>[
                            {'t': 'Stroke Type',      'v': strokeType},
                            {'t': 'Distance to Wall', 'v': '$distWallCm cm'},
                            {'t': 'Lap Speed',        'v': '$lapSpeed m/s'},
                            {'t': 'Stroke Rate',      'v': '$strokeRate spm'},
                          ];
                          return _KpiTile(title: items[i]['t']!, value: items[i]['v']!);
                        },
                      ),
                    ),

                    // ---------- Chart SPM ----------
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stroke Rate (spm)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: chartMaxY,
                                clipData: const FlClipData.all(),
                                gridData: const FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: leftInterval,
                                      getTitlesWidget: (v, _) =>
                                          Text(v.toInt().toString()),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      getTitlesWidget: (v, _) =>
                                          Text('${v.toInt()}s'),
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _spmSeries.isEmpty
                                        ? [const FlSpot(0, 0)]
                                        : _spmSeries,
                                    isCurved: true,
                                    color: Colors.orange,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.withValues(alpha: 0.25),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- Orientation ----------
                    GlassCard(
                      title: 'Orientation',
                      child: Row(
                        children: [
                          _chip('Roll',  '${roll.toStringAsFixed(1)}°'),
                          const SizedBox(width: 8),
                          _chip('Pitch', '${pitch.toStringAsFixed(1)}°'),
                          const SizedBox(width: 8),
                          _chip('Yaw',   '${yaw.toStringAsFixed(1)}°'),
                        ],
                      ),
                    ),

                    // ---------- Live badge ----------
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        lastTick == null
                            ? '—'
                            : 'LIVE • updated ${DateTime.now().difference(lastTick).inSeconds}s ago',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBFF),
          border: Border.all(color: const Color(0xFF9CCBFF), width: 1.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// Kartu KPI untuk grid 2x2 (anti overflow).
class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  const _KpiTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF9CCBFF), width: 1.7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
