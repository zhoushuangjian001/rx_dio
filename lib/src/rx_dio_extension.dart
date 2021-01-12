part of idkit_rxdio;

extension RxDioExtension on Dio {
  /// 是否证书检验
  Dio addSSL({bool enabled = false, String certificate}) {
    if (enabled) {
      DefaultHttpClientAdapter _defaultHttpClientAdapter =
          this.httpClientAdapter as DefaultHttpClientAdapter;
      _defaultHttpClientAdapter.onHttpClientCreate = (client) {
        client.badCertificateCallback =
            (X509Certificate _certificate, String host, int port) {
          if (_certificate.pem == certificate) {
            return true;
          }
          return false;
        };
      };
    }
    return this;
  }

  /// 是否代理转发
  Dio addProxy({bool enabled = false, String url}) {
    if (enabled) {
      DefaultHttpClientAdapter _defaultHttpClientAdapter =
          this.httpClientAdapter as DefaultHttpClientAdapter;
      _defaultHttpClientAdapter.onHttpClientCreate = (client) {
        client.findProxy = (_url) {
          return url;
        };
      };
    }
    return this;
  }
}
