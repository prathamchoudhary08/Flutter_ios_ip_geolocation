import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:flutter_system_proxy/flutter_system_proxy.dart';

class MyAdapter extends HttpClientAdapter {
  final DefaultHttpClientAdapter _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    var uri = options.uri;
    var proxy = await FlutterSystemProxy.findProxyFromEnvironment(uri.toString());

    _adapter.onHttpClientCreate = (HttpClient client) {
      client.findProxy = (uri) => proxy;
    };

    return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}
