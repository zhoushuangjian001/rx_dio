import 'package:dio/dio.dart';

class RxInterceptor extends Interceptor {
  RxInterceptor({
    InterceptorSendCallback? onRequest,
    InterceptorSuccessCallback? onResponse,
    InterceptorErrorCallback? onError,
  })  : _onRequest = onRequest,
        _onResponse = onResponse,
        _onError = onError;

  final InterceptorSendCallback? _onRequest;
  final InterceptorSuccessCallback? _onResponse;
  final InterceptorErrorCallback? _onError;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_onRequest != null) {
      _onRequest!(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_onResponse != null) {
      _onResponse!(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    if (_onError != null) {
      _onError!(err, handler);
    } else {
      handler.next(err);
    }
  }
}
