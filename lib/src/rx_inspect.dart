extension RxString on String {
  /// 判断是否是空或者Null
  bool isEmptyAndNull() {
    if (this == null) {
      return true;
    }
    return isEmpty;
  }
}

extension RxList<E> on List<E> {
  /// 判断是否是空或者Null
  bool isEmptyAndNull() {
    if (this == null) {
      return true;
    }
    return isEmpty;
  }
}
