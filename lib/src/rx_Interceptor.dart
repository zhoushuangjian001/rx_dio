import 'package:dio/dio.dart';

class RxInterceptor extends Interceptor {
  RxInterceptor({
    InterceptorSendCallback onRequest,
    InterceptorSuccessCallback onResponse,
    InterceptorErrorCallback onError,
  })  : _onRequest = onRequest,
        _onResponse = onResponse,
        _onError = onError;

  final InterceptorSendCallback _onRequest;
  final InterceptorSuccessCallback _onResponse;
  final InterceptorErrorCallback _onError;

  @override
  Future<dynamic> onRequest(RequestOptions options) async {
    if (_onRequest != null) {
      return _onRequest(options);
    }
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response) async {
    if (_onResponse != null) {
      return _onResponse(response);
    }
  }

  @override
  Future<dynamic> onError(DioError err) async {
    if (_onError != null) {
      return _onError(err);
    }
  }
}
