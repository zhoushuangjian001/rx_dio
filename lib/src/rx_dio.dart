part of idkit_rxdio;

/// Rxdio 请求主体
class Rxdio {
  /// Get 请求
  void get<T>({
    String url,
    Map<String, dynamic> params,
    bool isProxy = false,
    String proxyUrl,
    bool isSSL = true,
    String certificate,
    Method method,
    int timeout = 15,
    Function onStart,
    Function(T) onFinish,
    Function(dynamic, StackTrace) onFail,
    Function onEnd,
    Function onTimeout,
    Function onCancel,
  }) {
    _requestMethod(
      url: url,
      params: params,
      isProxy: isProxy,
      proxy: proxyUrl,
      isSSL: isSSL,
      cer: certificate,
      method: Method.Get,
      timeout: timeout,
      onStart: onStart,
      onFinish: onFinish,
      onFail: onFail,
      onEnd: onEnd,
      onTimeout: onTimeout,
      onCancel: onCancel,
    );
  }

  /// Post 请求
  void post<T>({
    String url,
    dynamic data,
    Map<String, dynamic> params,
    bool isProxy = false,
    String proxyUrl,
    bool isSSL = true,
    String certificate,
    Method method,
    int timeout = 15,
    Function onStart,
    Function(T) onFinish,
    Function(dynamic, StackTrace) onFail,
    Function onEnd,
    Function onTimeout,
    Function onCancel,
  }) {
    _requestMethod(
      url: url,
      data: data,
      params: params,
      isProxy: isProxy,
      proxy: proxyUrl,
      isSSL: isSSL,
      cer: certificate,
      method: Method.Post,
      timeout: timeout,
      onStart: onStart,
      onFinish: onFinish,
      onFail: onFail,
      onEnd: onEnd,
      onTimeout: onTimeout,
      onCancel: onCancel,
    );
  }

  /// 公共请求
  void _requestMethod<T>({
    String url,
    dynamic data,
    Map<String, dynamic> params,
    bool isProxy,
    String proxy,
    bool isSSL,
    String cer,
    Method method,
    int timeout,
    Function onStart,
    Function(dynamic) onFinish,
    Function(dynamic, StackTrace) onFail,
    Function onEnd,
    Function onTimeout,
    Function onCancel,
  }) {
    // 创建观察者
    PublishSubject _publishSubject = PublishSubject<T>();
    _publishSubject
        .doOnListen(onStart ?? doOnListen)
        .doOnData(onFinish ?? doOnData)
        .doOnDone(onEnd ?? doOnDone)
        .doOnError(onFail ?? onError)
        .doOnCancel(onCancel ?? doOnCancel)
        .listen(null);

    // 请求拦截
    var _dio = Dio(baseOptions());
    _dio.interceptors.addAll(interceptorIterables(_dio));

    // 请求方式区分
    switch (method) {
      case Method.Get:
        _dio
            .addProxy(enabled: isProxy, url: proxy ?? proxyUrl())
            .addSSL(enabled: isSSL, certificate: cer ?? certificate())
            .get(url, queryParameters: params)
            .then((value) => _publishSubject.add(value.data))
            .catchError((e) => _publishSubject.addError(e))
            .whenComplete(() => _publishSubject.close())
            .timeout(Duration(seconds: timeout),
                onTimeout: onTimeout ?? doOnTimeout);
        break;
      case Method.Post:
        _dio
            .addProxy(enabled: isProxy, url: proxy ?? proxyUrl())
            .addSSL(enabled: isSSL, certificate: certificate ?? certificate())
            .post(url, data: data, queryParameters: params)
            .then((value) => _publishSubject.add(value.data))
            .catchError((e) => _publishSubject.addError(e))
            .whenComplete(() => _publishSubject.close())
            .timeout(Duration(seconds: timeout),
                onTimeout: onTimeout ?? doOnTimeout);
        break;
      default:
    }
  }

  /// 请求拦截配置
  Iterable<Interceptor> interceptorIterables(Dio dio) {
    return [];
  }

  /// 请求体配置
  BaseOptions baseOptions() {
    return BaseOptions();
  }

  /// 请求代理地址
  String proxyUrl() {
    return "";
  }

  /// 证书校验
  String certificate() {
    return "";
  }

  /// 开始监听
  void doOnListen() {}

  /// 返回数据
  void doOnData(dynamic data) {}

  /// 请求失败
  void onError(
    dynamic err,
    StackTrace trace,
  ) {}

  /// 请求完成
  void doOnDone() {}

  /// 监控取消
  void doOnCancel() {}

  /// 请求超时
  void doOnTimeout() {}
}

/// 请求类型
enum Method {
  Get,
  Post,
}
