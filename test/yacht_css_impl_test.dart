import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';
import 'yacht_transformer_impl_test.dart';
import 'transformer_memory_test.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  BarbackSettings settings;
  YachtTransformer([this.settings]);
}

assetId(String path) => new MemoryAssetId(null, path);
main() {
  //YachtTransformer transformer;
  group('yacht_css_impl', () {
    group('css', () {
      setUp(() {});

      test('simple', () async {
        await checkYachtTransformCss(
            'body { color : red; }', null, 'body { color:red; }');
      });

      test('short', () async {
        await checkYachtTransformCss(
            'body{color:red}', null, null); //'body { color: red; }');
      });

      test('media query', () async {
        await checkYachtTransformCss(
            '@media screen { .red { color: red ; } }',
            null,
            '@media screen{ .red { color:red; } }'); //'body { color: red; }');
      });

      test('import', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)',
            stringAssets(['_included.css', 'body{color:red}']),
            'body { color:red; }');
      });

      test('import_sub', () async {
        await checkYachtTransformCss(
            '@import url(_included.css)',
            stringAssets([
              ['_included.css', '@import url(_subincluded.css)'],
              ['_subincluded.css', 'body{color:red}']
            ]),
            'body { color:red; }');
      });

      test('import_missing', () async {
        try {
          await checkYachtTransformCss('@import url(_included.css)', null,
              '@import url(_included.css);');
          fail('shoud fail');
        } on ArgumentError catch (_) {}
      });

      test('var', () async {
        await checkYachtTransformCss('@color1: red; body { color : @color1; }',
            null, 'body { color:red; }');
      });
      test('import_var', () async {
        await checkYachtTransformCss(
            '@import url(_included.css); body { color : @color1; }',
            stringAssets(['_included.css', '@color1: red']),
            'body { color:red; }');
      });

      test('import_with_var', () async {
        await checkYachtTransformCss(
            '@import url(_defs.css); @import url(_included.css);',
            stringAssets([
              ['_defs.css', '@color1: red;'],
              ['_included.css', 'body { color : @color1; }']
            ]),
            'body { color:red; }');
      });

      test('import_with_media_inner', () async {
        await checkYachtTransformCss(
            '@import url(_defs.css); .blue { @extend .red; };',
            stringAssets([
              ['_defs.css', '@media screen { .red { color: red; } }']
            ]),
            '@media screen{ .red,.blue { color:red; } } .blue { }');
      });
      test('import_import with_media_inner', () async {
        await checkYachtTransformCss(
            '@import url(_included.css);',
            stringAssets([
              [
                '_included.css',
                '@import url(_defs.css); .blue { @extend .red; };'
              ],
              ['_defs.css', '@media screen { .red { color: red; } }']
            ]),
            '@media screen{ .red,.blue { color:red; } } .blue { }');
      });
      /*
      not wokring
      solo_test('import_within_media_queries', () async {
        await checkYachtTransformCss(
            '@import url(_defs.css); @media screen { @import url(_included.css); }',
            stringAssets([
              ['_defs.css', '@color1: red;'],
              ['_included.css', 'body { color : @color1; }']
            ]),
            'body { color: red; }');
      });
      */
    });
  });
}
