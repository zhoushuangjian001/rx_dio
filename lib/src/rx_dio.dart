import 'dart:async';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dio/adapter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dio/dio.dart';
import 'package:idkit_rxdio/src/rx_error.dart';
import 'package:idkit_rxdio/src/rx_inspect.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:rxdart/rxdart.dart';

class RxDio {
  /// 初始化
  RxDio({BaseOptions? options}) {
    _dio = Dio(options);
  }

  /// 请求开始
  late Function() _start;

  /// 请求结束
  late Function() _end;

  /// 请求体
  late Dio _dio;

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
  RxDio addOptions({BaseOptions? options}) {
    if (options != null) {
      _dio.options = options;
    }
    return this;
  }

  /// 添加代理转发
  RxDio addProxy(String url) {
    if (!url.isEmptyAndNull()) {
      final DefaultHttpClientAdapter defaultHttpClientAdapter =
          _dio.httpClientAdapter as DefaultHttpClientAdapter;
      defaultHttpClientAdapter.onHttpClientCreate = (HttpClient client) {
        client.findProxy = (_) {
          return url;
        };
      };
    }
    return this;
  }

  /// 证书校验
  RxDio addSSL(String cer) {
    if (!cer.isEmptyAndNull()) {
      final DefaultHttpClientAdapter _defaultHttpClientAdapter =
          _dio.httpClientAdapter as DefaultHttpClientAdapter;
      _defaultHttpClientAdapter.onHttpClientCreate = (HttpClient client) {
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
  RxDio addInterceptors<T>(T Function(Dio dio) call) {
    final T interceptor = call(_dio);
    if (interceptor != null) {
      if (interceptor is Iterable<Interceptor>) {
        _dio.interceptors.addAll(interceptor);
      } else if (interceptor is Interceptor) {
        _dio.interceptors.add(interceptor);
      }
    }
    return this;
  }

  /// Get 请求
  PublishSubject<Response<T>> getRequest<T>(String url,
      {Map<String, dynamic>? parameter}) {
    // 创建观察序列
    final PublishSubject<Response<T>> _publishSubject =
        PublishSubject<Response<T>>();
    if (!url.isEmptyAndNull()) {
      _start.call();
      _request(
        _dio.get<T>(url, queryParameters: parameter),
        _publishSubject,
      );
    } else {
      _publishSubject.addError(
          const RxError<dynamic>(422, "The url is't empty and null !!!"));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Post 请求
  PublishSubject<Response<T>> postRequest<T>(String url,
      {dynamic data, Map<String, dynamic>? parameter}) {
    // 创建观察序列
    final PublishSubject<Response<T>> _publishSubject =
        PublishSubject<Response<T>>();
    if (!url.isEmptyAndNull()) {
      _start.call();
      _request(
        _dio.post<T>(url, data: data, queryParameters: parameter),
        _publishSubject,
      );
    } else {
      _publishSubject.addError(
          const RxError<dynamic>(422, "The url is't empty and null !!!"));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Upload 请求
  PublishSubject<Response<T>> uploadRequest<T>(
      String url, String name, List<File> files,
      {Map<String, dynamic>? parameter,
      Function(int, int)? onSendProgress,
      Function(int, int)? onReceiveProgress}) {
    // 创建观察序列
    final PublishSubject<Response<T>> _publishSubject =
        PublishSubject<Response<T>>();
    if (!url.isEmptyAndNull() &&
        !files.isEmptyAndNull() &&
        !name.isEmptyAndNull()) {
      _start.call();
      final FormData data = FormData();
      files.map((File file) async* {
        final MultipartFile _file = await MultipartFile.fromFile(file.path);
        data.files.add(MapEntry<String, MultipartFile>(name, _file));
      });
      _request(
        _dio.post<T>(url,
            queryParameters: parameter,
            data: data,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress),
        _publishSubject,
      );
    } else {
      _publishSubject.addError(const RxError<dynamic>(
          422, "The url or name or files is't empty and null !!!"));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Put 请求
  PublishSubject<Response<T>> putRequest<T>(String url,
      {dynamic data, Map<String, dynamic>? parameter}) {
    // 创建观察序列
    final PublishSubject<Response<T>> _publishSubject =
        PublishSubject<Response<T>>();
    if (!url.isEmptyAndNull()) {
      _start.call();
      _request(
        _dio.put<T>(url, data: data, queryParameters: parameter),
        _publishSubject,
      );
    } else {
      _publishSubject.addError(
          const RxError<dynamic>(422, "The url is't empty and null !!!"));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// Delete 请求
  PublishSubject<Response<T>> deleteRequest<T>(String url,
      {dynamic data, Map<String, dynamic>? parameter}) {
    // 创建观察序列
    final PublishSubject<Response<T>> _publishSubject =
        PublishSubject<Response<T>>();
    if (!url.isEmptyAndNull()) {
      _start.call();
      _request(
        _dio.delete<T>(url, data: data, queryParameters: parameter),
        _publishSubject,
      );
    } else {
      _publishSubject.addError(
          const RxError<dynamic>(422, "The url is't empty and null !!!"));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  /// 文件下载
  PublishSubject<Response<T>> downloadRequest<T>(String url, String savePath,
      {Map<String, dynamic>? parameter,
      bool deleteOnError = true,
      String lengthHeader = Headers.contentLengthHeader,
      Function(int, int)? onSendProgress,
      Function(int, int)? onReceiveProgress}) {
    // 创建观察序列
    final PublishSubject<Response<T>> _publishSubject =
        PublishSubject<Response<T>>();
    if (!url.isEmptyAndNull() && !savePath.isEmptyAndNull()) {
      _start.call();
      _request<dynamic>(
        _dio.download(
          url,
          savePath,
          lengthHeader: lengthHeader,
          queryParameters: parameter,
          deleteOnError: deleteOnError,
          onReceiveProgress: onReceiveProgress,
        ),
        _publishSubject,
      );
    } else {
      _publishSubject.addError(const RxError<dynamic>(
          422, "The url or savePath is't empty and null !!!"));
      _publishSubject.close();
    }
    return _publishSubject;
  }

  // 公共方法处理
  void _request<T>(
      Future<Response<T>> future, PublishSubject<Response<T>> _publishSubject) {
    try {
      future.then((Response<T> response) {
        _publishSubject.add(response);
      }).whenComplete(() {
        _end.call();
        _publishSubject.close();
      });
    } on DioError catch (error) {
      _publishSubject.addError(
        RxError<dynamic>(
          error.response!.statusCode,
          error.response.statusMessage,
          data: error.response.data,
        ),
      );
      _publishSubject.close();
    } catch (error) {
      _publishSubject.addError(RxError<dynamic>(-1, error.toString()));
      _publishSubject.close();
    }
  }

  /// 清除请求 Task, 释放资源
  void close({bool? force}) => _dio.close;

  /// 清除 dio 队列等待
  void clear() => _dio.clear;
}
