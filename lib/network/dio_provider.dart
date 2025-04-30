import 'package:dio/dio.dart';
import 'proxy_adapter.dart';

Dio getDio() {
      print("2");   
  final dio = Dio();
    print("3");   
  dio.httpClientAdapter = MyAdapter();
  return dio;
}
