import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

/// CsvLiveFeed: memutar baris CSV seperti data realtime.
/// Bentuk keluaran meniru UbidotsMqtt: last['ai_tapper'][var], last['aimotionscema'][var]
class CsvLiveFeed extends ChangeNotifier {
  final List<Map<String, dynamic>> _tapper = [];
  final List<Map<String, dynamic>> _motion = [];
  int _iTap = 0, _iMot = 0;
  Timer? _timer;

  /// Nilai terakhir per device/variable
  Map<String, Map<String, dynamic>> last = {
    'ai_tapper': <String, dynamic>{},
    'aimotionscema': <String, dynamic>{},
  };

  DateTime? lastTick;

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
    _applyRow(); // set nilai awal
  }

  /// Mulai playback; interval detik (default 1.0). Jika mencapai akhir → loop ke awal.
  void start({double intervalSeconds = 1.0}) {
    stop();
    _timer = Timer.periodic(Duration(milliseconds: (intervalSeconds * 1000).round()), (_) {
      _step();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // ---- internal helpers ----
  Future<List<Map<String, dynamic>>> _loadCsvAsMaps(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw);
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

  double _toD(dynamic v, [double d = 0]) {
    if (v == null) return d;
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = num.tryParse(v.trim());
      if (p != null) return p.toDouble();
    }
    return d;
  }

  int _toI(dynamic v, [int d = 0]) {
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

    // ---- map ai_tapper ----
    final distanceM = tap.containsKey('distance_m')
        ? _toD(tap['distance_m'])
        : _toD(tap['distance_to_wall_cm']) / 100.0;

    last['ai_tapper'] = {
      'distance_m': distanceM,
      'tap_count'  : _toI(tap['tap_count']),
      'tap'        : _toI(tap['tap']),
      'servo_deg'  : _toD(tap['servo_deg']),
      'distance_to_wall_cm': _toD(tap['distance_to_wall_cm']),
    };

    // ---- map aimotionscema ----
    last['aimotionscema'] = {
      'accel_x': _toD(mot['accel_x']),
      'accel_y': _toD(mot['accel_y']),
      'accel_z': _toD(mot['accel_z']),
      'gyro_x' : _toD(mot['gyro_x']),
      'gyro_y' : _toD(mot['gyro_y']),
      'gyro_z' : _toD(mot['gyro_z']),
      'body_roll_deg': _toD(mot['body_roll_deg']),
      'pitch_deg'    : _toD(mot['pitch_deg']),
      'yaw_deg'      : _toD(mot['yaw_deg']),
      'stroke_rate_spm': _toD(mot['stroke_rate_spm']),
      'lap_speed_mps'  : _toD(mot['lap_speed_mps']),
      'stroke_type'    : (mot['stroke_type'] ?? '-').toString(),
    };

    lastTick = DateTime.now();
    notifyListeners();
  }

  void _step() {
    if (_tapper.isNotEmpty) {
      _iTap++;
      if (_iTap >= _tapper.length) _iTap = 0;
    }
    if (_motion.isNotEmpty) {
      _iMot++;
      if (_iMot >= _motion.length) _iMot = 0;
    }
    _applyRow();
  }
}
