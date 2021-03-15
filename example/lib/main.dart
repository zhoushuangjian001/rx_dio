import 'package:dio/dio.dart';
import 'package:idkit_rxdio/idkit_rxdio.dart';

void main1() {
  RxDio()
      .addInterceptors((Dio _, call) => [])
      .addProxy("")
      .getRequest("")
      .listen((value) {});
}
