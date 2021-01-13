import 'package:flutter_test/flutter_test.dart';

void main() {
  test("测试", () {
    var s = "23.";
    var n = double.parse(s) ?? 0;
    var s2 = s.split(".").last ?? "0";
    var a = double.parse(s2) ?? 0;
    print(a);
  });
}
