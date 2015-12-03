@TestOn("vm")
library yacht_transformer.test.yacht_transformer_test;

import 'package:dev_test/test.dart';
import 'package:yacht_transformer/yacht_transformer.dart';

main() {
  group('yacht_transformer', () {
    test('create', () {
      YachtTransformer transformer = new YachtTransformer.asPlugin();
      expect(transformer, isNotNull);
    });
  });
}
