import 'package:dio/dio.dart';

class HomeApi {
  final Dio _dio;
  HomeApi(this._dio);

  Future<String> health() async {
    final res = await _dio.get('/health');
    return res.data.toString();
  }

// TODO: fetchNewest(), fetchHot(), fetchByCategory()
}
