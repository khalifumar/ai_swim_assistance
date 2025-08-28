// File: dashboard_feature.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async'; // Diperlukan untuk simulasi data real-time

// --- DUMMY DATA ---
// Data untuk grafik perenang
class PerformanceData {
  final int lap;
  final double speed;
  final double strokeRate;

  PerformanceData(this.lap, this.speed, this.strokeRate);
}

// Data untuk analisis turn
class TurnData {
  final int lap;
  final double turnTime;

  TurnData(this.lap, this.turnTime);
}

// Data untuk efisiensi stroke
class EfficiencyData {
  final double speed;
  final double efficiency;

  EfficiencyData(this.speed, this.efficiency);
}

// Data untuk profil perenang (Radar Chart)
class ProfileData {
  final String metric;
  final double value;

  ProfileData(this.metric, this.value);
}
// --- END DUMMY DATA ---

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Data aktual yang akan diperbarui oleh IoT
  List<PerformanceData> performanceData = [
    PerformanceData(1, 1.5, 30),
    PerformanceData(2, 1.6, 31),
    PerformanceData(3, 1.7, 32),
  ];

  // Placeholder untuk logika koneksi MQTT
  // Di sini Anda akan menginisialisasi klien MQTT dan berlangganan topik
  // Ketika data baru datang, Anda akan memanggil setState untuk memperbarui grafik
  
  @override
  void initState() {
    super.initState();
    // Contoh: Mulai simulasi untuk memperbarui data
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        final newLap = performanceData.last.lap + 1;
        performanceData.add(
          PerformanceData(newLap, 1.5 + (newLap * 0.1), 30 + (newLap * 0.5)),
        );
        if (performanceData.length > 10) {
          performanceData.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pelatih'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPerformanceLineChart(),
              const SizedBox(height: 20),
              _buildTurnBarChart(),
              const SizedBox(height: 20),
              _buildEfficiencyScatterPlot(),
              const SizedBox(height: 20),
              _buildProfileRadarChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceLineChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performa Sesi (Kecepatan & Stroke Rate)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: performanceData.map((data) => FlSpot(data.lap.toDouble(), data.speed)).toList(),
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: performanceData.map((data) => FlSpot(data.lap.toDouble(), data.strokeRate / 10)).toList(), // Skala untuk stroke rate
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnBarChart() {
    final List<TurnData> turnData = [
      TurnData(1, 1.5),
      TurnData(2, 1.3),
      TurnData(3, 1.4),
      TurnData(4, 1.1),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analisis Waktu Turn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: turnData.map((data) => BarChartGroupData(
                  x: data.lap,
                  barRods: [BarChartRodData(toY: data.turnTime, color: Colors.green)]
                )).toList(),
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                alignment: BarChartAlignment.spaceAround,
                maxY: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyScatterPlot() {
    final List<EfficiencyData> efficiencyData = [
      EfficiencyData(1.5, 0.8),
      EfficiencyData(1.6, 0.9),
      EfficiencyData(1.7, 0.85),
      EfficiencyData(1.8, 0.75),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Efisiensi Stroke vs Kecepatan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: efficiencyData.map((data) => ScatterSpot(data.speed, data.efficiency)).toList(),
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRadarChart() {
    final List<ProfileData> profileData = [
      ProfileData('Stroke Rate', 0.8),
      ProfileData('Turn Time', 0.9),
      ProfileData('Efficiency', 0.7),
      ProfileData('Pace', 0.85),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Kekuatan Perenang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: Colors.blue.withOpacity(0.4),
                    borderColor: Colors.blue,
                    dataEntries: profileData.map((data) => RadarEntry(value: data.value)).toList(),
                  ),
                ],
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                gridBorderData: const BorderSide(color: Colors.black, width: 0.5),
                titleTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}