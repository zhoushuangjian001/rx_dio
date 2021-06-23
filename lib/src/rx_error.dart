/// RxDio 请求异常类
/// 参数
/// -1 : 其他异常
/// 422: 参数缺失
class RxError<T> implements Exception {
  /// 异常类初始化
  const RxError(this.code, this.message, {this.data});

  /// 异常码
  final int code;

  /// 异常信息
  final String message;

  /// 异常数据
  final T? data;
}
