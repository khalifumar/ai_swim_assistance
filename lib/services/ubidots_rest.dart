import 'package:dio/dio.dart';

class UbidotsRest {
  final String token;
  final Dio _dio;

  UbidotsRest(this.token)
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://industrial.api.ubidots.com/api/v1.6',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'X-Auth-Token': token},
        ));

  /// contoh: ambil riwayat values untuk chart
  Future<List<Map<String, dynamic>>> lastValues({
    required String device,
    required String variable,
    int limit = 100,
  }) async {
    final r = await _dio.get('/devices/$device/$variable/values',
        queryParameters: {'page_size': limit});
    final results = (r.data['results'] as List).cast<Map<String, dynamic>>();
    return results;
  }

  /// kirim kontrol ke device (akan membuat/menulis variabel)
  Future<void> postToDevice(String device, Map<String, dynamic> data) async {
    await _dio.post('/devices/$device', data: data);
  }
}
