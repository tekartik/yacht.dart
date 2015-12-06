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
        await checkYachtTransformCss(
            'body{color:red}', null, 'body { color: red; }');
      });

      test('import', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)',
            stringAssets(['_included.css', 'body{color:red}']),
            'body { color: red; }');
      });

      test('import_sub', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)',
            stringAssets([
              ['_included.css', '@import url(_subincluded.css)'],
              ['_subincluded.css', 'body{color:red}']
            ]),
            'body { color: red; }');
      });

      test('import_missing', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)', null, '@import url(_included.css);');
      });

      test('var', () async {
        await checkYachtTransformCss('@color1: red; body { color : @color1; }',
            null, 'body { color: red; }');
      });
      test('import_var', () async {
        await checkYachtTransformCss(
            '@import url(_included.css); body { color : @color1; }',
            stringAssets(['_included.css', '@color1: red']),
            'body { color: red; }');
      });

      test('import_with_var', () async {
        await checkYachtTransformCss(
            '@import url(_defs.css); @import url(_included.css);',
            stringAssets([
              ['_defs.css', '@color1: red;'],
              ['_included.css', 'body { color : @color1; }']
            ]),
            'body { color: red; }');
      });
    });
  });
}
