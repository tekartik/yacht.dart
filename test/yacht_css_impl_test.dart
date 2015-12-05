library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';
import 'yacht_transformer_impl_test.dart';
import 'transformer_memory_test.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  BarbackSettings settings;
  YachtTransformer([this.settings]);
}

assetId(String path) => new AssetId(null, path);
main() {
  //YachtTransformer transformer;
  group('yacht_css_impl', () {
    group('css', () {
      setUp(() {});

      test('simple', () async {
        await checkYachtTransformCss(
            'body { color : red; }', null, 'body { color: red; }');
      });

      test('short', () async {
        await checkYachtTransformCss('body{color:red}', null, null);
      });

      test('import', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)',
            stringAssets(['_included.css', 'body{color:red}']),
            'body { color: red; }');
      });

      test('import_missing', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)', null, '@import url(_included.css);');
      });
    });
  });
}
