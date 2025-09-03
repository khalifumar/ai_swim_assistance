import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class UbidotsMqtt with ChangeNotifier {
  final String token; // gunakan API Token Ubidots sebagai username
  final String host = 'industrial.api.ubidots.com';
  final int port = 1883;

  late MqttServerClient _client;
  bool _connected = false;
  bool get isConnected => _connected;

  // cache nilai terakhir per-device -> per-variable
  final Map<String, Map<String, dynamic>> last = {
    'aimotionscema': {},
    'ai_tapper': {},
  };

  UbidotsMqtt(this.token);

  Future<void> connect() async {
    _client = MqttServerClient(host, 'flutter-${DateTime.now().millisecondsSinceEpoch}');
    _client.logging(on: false);
    _client.port = port;
    _client.keepAlivePeriod = 60;
    _client.secure = false;
    _client.onDisconnected = () {
      _connected = false;
      notifyListeners();
    };

    final msg = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .authenticateAs(token, '') // password boleh kosong
        .startClean();
    _client.connectionMessage = msg;

    await _client.connect();
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      throw Exception('MQTT connect failed: ${_client.connectionStatus}');
    }
    _connected = true;

    // daftar variabel yang kita pantau
    const aimotionVars = [
      'timestamp_s','device_id','sensor_type',
      'accel_x','accel_y','accel_z','gyro_x','gyro_y','gyro_z',
      'body_roll_deg','pitch_deg','yaw_deg',
      'stroke_rate_spm','lap_speed_mps','stroke_type',
    ];
    const tapperVars = [
      'tap','tap_count','servo_deg','distance_to_wall_cm','distance_m',
      // kontrol (kalau ingin lihat terakhirnya juga)
      'tap_enable','tap_threshold_cm','tap_cmd','buzzer',
    ];

    for (final v in aimotionVars) {
      _client.subscribe('/v1.6/devices/aimotionscema/$v/lv', MqttQos.atMostOnce);
    }
    for (final v in tapperVars) {
      _client.subscribe('/v1.6/devices/ai_tapper/$v/lv', MqttQos.atMostOnce);
    }

    _client.updates?.listen(_onMessage);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final e in events) {
      final topic = e.topic; // /v1.6/devices/<device>/<variable>/lv
      final rec = e.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(rec.payload.message);

      final parts = topic.split('/');
      if (parts.length < 6) continue;
      final device = parts[3];
      final variable = parts[4];

      dynamic value;
      // variabel string khusus
      if (variable == 'device_id' || variable == 'sensor_type' || variable == 'stroke_type') {
        value = payload;
      } else {
        final n = num.tryParse(payload.trim());
        value = n ?? payload;
      }

      last.putIfAbsent(device, () => {});
      last[device]![variable] = value;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    try { _client.disconnect(); } catch (_) {}
    super.dispose();
  }
}
