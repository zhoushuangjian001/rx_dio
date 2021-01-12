import 'package:idkit_rxdio/idkit_rxdio.dart';

import 'test.dart';

void main() {
  TestRx().get(
    url: "/todayVideo",
    onFinish: (data) {
      print(data);
    },
  );
}
