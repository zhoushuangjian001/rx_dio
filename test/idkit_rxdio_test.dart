import 'package:flutter_test/flutter_test.dart';

void main() {
  test("测试", () {});
}

extension RxInspect on String {
  bool isEmptyAndNull() {
    if (this == null) {
      return true;
    }
    return this.isEmpty;
  }
}
