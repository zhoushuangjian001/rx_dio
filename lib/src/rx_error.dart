part of idkit_rxdio;

/// RxDio 请求异常类
class RxError1 implements Exception {
  /// 异常码
  final int code;

  /// 异常信息
  final String message;

  /// 异常数据
  final dynamic data;

  const RxError1(this.code, this.message, {this.data});
}
