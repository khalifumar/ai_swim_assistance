import 'package:flutter/foundation.dart';

/// Kontrak sumber data untuk halaman Dashboard.
/// Baik CSV playback maupun MQTT harus mengikuti interface ini.
abstract class LiveData extends ChangeNotifier {
  /// Nilai terakhir dalam struktur:
  ///   last['ai_tapper']['distance_m']
  ///   last['aimotionscema']['stroke_rate_spm']  dst.
  Map<String, Map<String, dynamic>> get last;

  /// Stempel waktu update terakhir (untuk badge LIVE).
  DateTime? get lastTick;
}
