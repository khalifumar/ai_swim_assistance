import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'live_data.dart';

/// Memutar dua CSV sebagai stream "live".
/// - ai_tapper_v2.csv
/// - ai_motion_v2.csv
class CsvLiveFeed extends LiveData {
  final List<Map<String, dynamic>> _tapper = [];
  final List<Map<String, dynamic>> _motion = [];
  int _iTap = 0, _iMot = 0;
  Timer? _timer;

  final Map<String, Map<String, dynamic>> _last = {
    'ai_tapper': <String, dynamic>{},
    'aimotionscema': <String, dynamic>{},
  };
  @override
  Map<String, Map<String, dynamic>> get last => _last;

  DateTime? _lastTick;
  @override
  DateTime? get lastTick => _lastTick;

  Future<void> loadFromAssets({
    required String tapperCsv,
    required String motionCsv,
  }) async {
    _tapper
      ..clear()
      ..addAll(await _loadCsvAsMaps(tapperCsv));
    _motion
      ..clear()
      ..addAll(await _loadCsvAsMaps(motionCsv));

    _iTap = 0;
    _iMot = 0;
    _applyRow();
  }

  /// Mulai "live": 1 baris per [intervalSeconds] (default 1s).
  void start({double intervalSeconds = 1.0}) {
    stop();
    _timer = Timer.periodic(
      Duration(milliseconds: (intervalSeconds * 1000).round()),
      (_) => _step(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<List<Map<String, dynamic>>> _loadCsvAsMaps(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final rows =
        const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw);
    if (rows.isEmpty) return [];
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final out = <Map<String, dynamic>>[];
    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      final m = <String, dynamic>{};
      for (var c = 0; c < headers.length && c < row.length; c++) {
        m[headers[c]] = row[c];
      }
      out.add(m);
    }
    return out;
  }

  double _d(v, [double d = 0]) {
    if (v == null) return d;
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = num.tryParse(v.trim());
      if (p != null) return p.toDouble();
    }
    return d;
  }

  int _i(v, [int d = 0]) {
    if (v == null) return d;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final p = num.tryParse(v.trim());
      if (p != null) return p.toInt();
    }
    return d;
  }

  void _applyRow() {
    final tap = (_tapper.isEmpty) ? <String, dynamic>{} : _tapper[_iTap];
    final mot = (_motion.isEmpty) ? <String, dynamic>{} : _motion[_iMot];

    // ai_tapper
    final distanceM = tap.containsKey('distance_cm')
        ? _d(tap['distance_cm'])
        : _d(tap['distance_to_wall_cm']) / 100.0;

    _last['ai_tapper'] = {
      'distance_cm': distanceM,
      'tap_count': _i(tap['tap_count']),
      'tap': _i(tap['tap']),
      'servo_deg': _d(tap['servo_deg']),
      'distance_to_wall_cm': _d(tap['distance_to_wall_cm']),
    };

    // aimotionscema
    _last['aimotionscema'] = {
      'accel_x': _d(mot['accel_x']),
      'accel_y': _d(mot['accel_y']),
      'accel_z': _d(mot['accel_z']),
      'gyro_x': _d(mot['gyro_x']),
      'gyro_y': _d(mot['gyro_y']),
      'gyro_z': _d(mot['gyro_z']),
      'body_roll_deg': _d(mot['body_roll_deg']),
      'pitch_deg': _d(mot['pitch_deg']),
      'yaw_deg': _d(mot['yaw_deg']),
      'stroke_rate_spm': _d(mot['stroke_rate_spm']),
      'lap_speed_mps': _d(mot['lap_speed_mps']),
      'stroke_type': (mot['stroke_type'] ?? '-').toString(),
    };

    _lastTick = DateTime.now();
    notifyListeners();
  }

  void _step() {
    if (_tapper.isNotEmpty) _iTap = (_iTap + 1) % _tapper.length;
    if (_motion.isNotEmpty) _iMot = (_iMot + 1) % _motion.length;
    _applyRow();
  }
}
