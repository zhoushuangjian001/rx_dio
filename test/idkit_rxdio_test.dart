import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:idkit_rxdio/idkit_rxdio.dart';

void main() {
  test("测试", () {
    Future.delayed(Duration(milliseconds: 3000), () => "hate")
        .timeout(Duration(milliseconds: 2000))
        .then(print)
        .catchError(print);
  });
}
