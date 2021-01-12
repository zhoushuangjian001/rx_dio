import 'package:dio/dio.dart';
import 'package:idkit_rxdio/idkit_rxdio.dart';

class TestRx extends Rxdio {
  @override
  BaseOptions baseOptions() {
    return BaseOptions(baseUrl: "https://api.apiopen.top");
  }
}
