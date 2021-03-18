part of idkit_rxdio;

class RxDio with Inspect {
  /// 请求开始
  Function _start;

  /// 请求结束
  Function _end;

  /// 请求体
  Dio _dio;

  /// 初始化
  RxDio({BaseOptions options}) {
    _dio = Dio(options);
  }

  /// 请求开始回调
  RxDio addStart(Function() start) {
    _start = start;
    return this;
  }

  /// 请求结束回调
  RxDio addEnd(Function() end) {
    _end = end;
    return this;
  }

  /// 添加请求配置
  RxDio addOptions({BaseOptions options}) {
    if (options != null) {
      _dio.options = options;
    }
    return this;
  }

  /// 添加代理转发
  RxDio addProxy(String url) {
    if (inspectNullAndEmpty(url)) {
      DefaultHttpClientAdapter defaultHttpClientAdapter =
          _dio.httpClientAdapter as DefaultHttpClientAdapter;
      defaultHttpClientAdapter.onHttpClientCreate = (client) {
        client.findProxy = (_) {
          return url;
        };
      };
    }
    return this;
  }

  /// 证书校验
  RxDio addSSL(String cer) {
    if (inspectNullAndEmpty(cer)) {
      DefaultHttpClientAdapter _defaultHttpClientAdapter =
          _dio.httpClientAdapter as DefaultHttpClientAdapter;
      _defaultHttpClientAdapter.onHttpClientCreate = (client) {
        client.badCertificateCallback =
            (X509Certificate _certificate, String host, int port) {
          if (_certificate.pem == cer) {
            return true;
          }
          return false;
        };
      };
    }
    return this;
  }

  /// 添加请求拦截
  RxDio addInterceptors(Function(Dio, Function(Iterable<Interceptor>)) call) {
    call(_dio, (list) {
      _dio.interceptors.addAll(list);
    });
    return this;
  }

  /// Get
  PublishSubject<T> getRequest<T>(String url,
      {Map<String, dynamic> parameter}) {
    // 创建观察序列
    PublishSubject<T> _publishSubject = PublishSubject();
    if (inspectNullAndEmpty(url)) {
      _start?.call;
      _request(_dio.get(url, queryParameters: parameter), _publishSubject);
    } else {
      _publishSubject.addError(RxError("请求地址为 null", type: RxErrorType.NOURL));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Post
  PublishSubject<T> postRequest<T>(String url,
      {dynamic data, Map<String, dynamic> parameter}) {
    // 创建观察序列
    PublishSubject<T> _publishSubject = PublishSubject();
    if (inspectNullAndEmpty(url)) {
      _request(_dio.post(url, data: data, queryParameters: parameter),
          _publishSubject);
    } else {
      _publishSubject.addError(RxError("请求地址为 null", type: RxErrorType.NOURL));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Upload
  PublishSubject<T> uploadRequest<T>(String url, String name, List<File> files,
      {Map<String, dynamic> parameter,
      Function(int, int) onSendProgress,
      Function(int, int) onReceiveProgress}) {
    // 创建观察序列
    PublishSubject<T> _publishSubject = PublishSubject();
    if (inspectNullAndEmpty(url) &&
        inspectNullAndEmpty(files) &&
        inspectNullAndEmpty(name)) {
      _start?.call;
      FormData data = FormData();
      files.map((file) async* {
        final _file = await MultipartFile.fromFile(file.path);
        data.files.add(
          MapEntry(name, _file),
        );
      });
      _request(
          _dio.post(url,
              queryParameters: parameter,
              data: data,
              onSendProgress: onSendProgress,
              onReceiveProgress: onReceiveProgress),
          _publishSubject);
    } else {
      _publishSubject.addError(RxError("请求参数异常", type: RxErrorType.PARAMETER));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Put 请求
  PublishSubject<T> putRequest<T>(String url,
      {dynamic data, Map<String, dynamic> parameter}) {
    // 创建观察序列
    PublishSubject<T> _publishSubject = PublishSubject();
    if (inspectNullAndEmpty(url)) {
      _request(_dio.put(url, data: data, queryParameters: parameter),
          _publishSubject);
    } else {
      _publishSubject.addError(RxError("请求参数异常", type: RxErrorType.PARAMETER));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// 文件下载
  PublishSubject<T> downloadRequest<T>(String url, String savePath,
      {Map<String, dynamic> parameter,
      bool deleteOnError,
      String lengthHeader,
      Function(int, int) onSendProgress,
      Function(int, int) onReceiveProgress}) {
    // 创建观察序列
    PublishSubject<T> _publishSubject = PublishSubject();
    if (inspectNullAndEmpty(url) && inspectNullAndEmpty(savePath)) {
      _start?.call;
      _request(
          _dio.download(
            url,
            savePath,
            lengthHeader: lengthHeader,
            queryParameters: parameter,
            deleteOnError: deleteOnError,
            onReceiveProgress: onReceiveProgress,
          ),
          _publishSubject);
    } else {
      _publishSubject.addError(RxError("请求地址为 null", type: RxErrorType.NOURL));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  // 公共方法处理
  void _request<T>(Future<Response<T>> future, PublishSubject _publishSubject) {
    future.then((value) {
      final data = value.data;
      _publishSubject.add(data);
    }).onError((error, stackTrace) {
      if (error is DioError) {
        switch (error.type) {
          case DioErrorType.CANCEL:
            _publishSubject.addError(RxError("请求取消", type: RxErrorType.CANCLE));
            break;
          case DioErrorType.RECEIVE_TIMEOUT:
            _publishSubject
                .addError(RxError("客户端接收数据超时", type: RxErrorType.TIMEOUT));
            break;
          case DioErrorType.CONNECT_TIMEOUT:
            _publishSubject
                .addError(RxError("客户端连接服务器超时", type: RxErrorType.TIMEOUT));
            break;
          case DioErrorType.SEND_TIMEOUT:
            _publishSubject
                .addError(RxError("服务器确认数据发送超时", type: RxErrorType.TIMEOUT));
            break;
          default:
            _publishSubject
                .addError(RxError("Dio 未知错误", type: RxErrorType.UNKNOWN));
        }
      } else {
        _publishSubject.addError(RxError("未知错误", type: RxErrorType.UNKNOWN));
      }
      _dio.close(force: true);
    }).whenComplete(() {
      _end?.call;
      _publishSubject.close();
      _dio.close(force: true);
    });
  }
}

/// 对象检查
class Inspect {
  /// 判断是否为空
  /// [inspect] : 要检查的对象
  /// [true] : 对象可用 ; [false] : 对象不可用
  bool inspectNullAndEmpty(Object inspect) {
    if (inspect == null) return false;
    if (inspect is String) {
      String string = inspect;
      return string.isNotEmpty;
    } else if (inspect is List) {
      List list = inspect;
      return list.isNotEmpty;
    } else if (inspect is Map) {
      Map map = inspect;
      return map.isNotEmpty;
    }
    return false;
  }
}

/// 错误对象
class RxError implements Exception {
  final String message;
  final RxErrorType type;
  const RxError(this.message, {this.type});

  /// 获取状态
  RxErrorType get state => this.type;

  /// 错误信息
  String toString() {
    Object message = this.message;
    if (message == null) return "RxException: 错误信息为 null";
    return "RxException: $message";
  }
}

/// 错误类型
enum RxErrorType {
  NOURL,
  TIMEOUT,
  CANCLE,
  UNKNOWN,
  PARAMETER,
}
