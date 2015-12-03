@TestOn("vm")
library yacht.test.yacht_test;

import 'package:dev_test/test.dart';
import 'package:yacht/yacht.dart';

main() {
  group('yacht', () {
    test('create', () {
      YachtTransformer transformer = new YachtTransformer.asPlugin();
      expect(transformer, isNotNull);
    });
  });
}
