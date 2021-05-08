import 'package:dio/dio.dart';

class RxInterceptor extends Interceptor {
  final InterceptorSendCallback _onRequest;
  final InterceptorSuccessCallback _onResponse;
  final InterceptorErrorCallback _onError;

  RxInterceptor({
    InterceptorSendCallback onRequest,
    InterceptorSuccessCallback onResponse,
    InterceptorErrorCallback onError,
  })  : _onRequest = onRequest,
        _onResponse = onResponse,
        _onError = onError;

  @override
  Future onRequest(RequestOptions options) async {
    if (_onRequest != null) {
      return _onRequest(options);
    }
  }

  @override
  Future onResponse(Response response) async {
    if (_onResponse != null) {
      return _onResponse(response);
    }
  }

  @override
  Future onError(DioError err) async {
    if (_onError != null) {
      return _onError(err);
    }
  }
}
