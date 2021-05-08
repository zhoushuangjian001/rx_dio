extension RxString on String {
  /// 判断是否是空或者Null
  bool isEmptyAndNull() {
    if (this == null) {
      return true;
    }
    return this.isEmpty;
  }
}

extension RxList on List {
  /// 判断是否是空或者Null
  bool isEmptyAndNull() {
    if (this == null) {
      return true;
    }
    return this.isEmpty;
  }
}
