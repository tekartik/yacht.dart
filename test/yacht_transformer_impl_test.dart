library yacht_transformer.test.yacht_transformer_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht_transformer/src/yacht_transformer_impl.dart';
import 'package:yacht_transformer/src/transformer_memory.dart';
import 'package:yacht_transformer/src/transformer.dart';
import 'dart:async';
import 'transformer_memory_test.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  BarbackSettings settings;
  YachtTransformer([this.settings]);
}

assetId(String path) => new AssetId(null, path);
main() {
  group('StringAssets', () {});
  group('yacht_transformer_impl', () {
    test('isPrimary', () {
      void _checkPrimary(AssetId id, Matcher expected) {
        YachtTransformer transformer = new YachtTransformer();

        // no await here in our implementation
        expect(transformer.isPrimary(id), expected);

        var transform = new StringIsPrimaryTransform(id);

        // no await here in our implementation
        expect(transformer.run(transform), expected);
      }
      _checkPrimary(assetId('in'), isFalse);
      _checkPrimary(assetId('test.js'), isFalse);
      _checkPrimary(assetId('test.html'), isTrue);
      _checkPrimary(assetId('_test.html'), isTrue);
      _checkPrimary(assetId('test.part.html'), isTrue);
      _checkPrimary(assetId('test.css'), isTrue);
      _checkPrimary(assetId('_test.css'), isTrue);
      _checkPrimary(assetId('test.part.css'), isTrue);
    });

    test('DeclaringTransform', () {
      Future _checkDeclaring(
          AssetId id, Matcher isConsumed, List<AssetId> outputsExpected) async {
        YachtTransformer transformer = new YachtTransformer();

        var transform = new StringDeclaringTransform(id);
        expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

        expect(transform.isConsumed, isNull);
        expect(transform.outputs, []);

        // no await here in our implementation
        transformer.run(transform);

        expect(transform.isConsumed, isConsumed, reason: "isConsumed($id)");
        expect(transform.outputs, outputsExpected, reason: "outputs($id)");
      }
      _checkDeclaring(assetId('in'), isNull, []);
      AssetId id = assetId('test.html');
      _checkDeclaring(id, isNull, [id]);
      _checkDeclaring(assetId('test.part.html'), isTrue, []);
    });

    test('Transform', () {
      Future _checkTransform(StringAsset primaryAsset, StringAssets inputAssets,
          Matcher isConsumed, StringAssets outputsExpected) async {
        YachtTransformer transformer = new YachtTransformer();

        var transform = new StringTransform(primaryAsset, inputAssets);
        expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

        expect(transform.isConsumed, isNull);
        expect(transform.outputs, {});

        // await needed here
        await transformer.run(transform);

        expect(transform.isConsumed, isConsumed,
            reason: "isConsumed(${primaryAsset.id})");
        expect(transform.outputs, outputsExpected,
            reason: "outputs(${primaryAsset.id})");
      }
      AssetId id = assetId('test.html');
      _checkTransform(
          stringAsset(id, ''),
          null,
          isNull,
          stringAssets([
            id.path,
            '''
<!doctype html>
<html>
<head>
</head>
<body>
</body>
</html>'''
          ]));

      _checkTransform(
          stringAsset(
              id, '<!doctype html><html><head></head><body></body></html>'),
          null,
          isNull,
          stringAssets([
            id.path,
            '''
<!doctype html>
<html>
<head>
</head>
<body>
</body>
</html>'''
          ]));

      // important check for new line before and after
      _checkTransform(
          stringAsset(
              id, '\n<!doctype html><html><head></head><body></body></html>\n'),
          null,
          isNull,
          stringAssets([
            id.path,
            '''
<!doctype html>
<html>
<head>
</head>
<body>
</body>
</html>'''
          ]));
    });
  });
}
