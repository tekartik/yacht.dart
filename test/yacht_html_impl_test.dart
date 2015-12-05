library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';
import 'package:yacht/src/transformer_memory.dart';
import 'yacht_transformer_impl_test.dart';
import 'html_printer_test.dart';
import 'transformer_memory_test.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  BarbackSettings settings;
  YachtTransformer([this.settings]);
}

assetId(String path) => new AssetId(null, path);
main() {
  //YachtTransformer transformer;
  group('yacht_html_impl', () {
    group('document', () {
      test('basic', () async {
        await checkYachtTransformDocument(minInHtml, null, minHtmlLines);
      });
      test('rewrite', () async {
        await checkYachtTransformDocument(
            '''
<!doctype html>
<html>
<head>
  <script async type="application/dart" src="test.dart"></script>
  <script async src="packages/browser/dart.js"></script>
</head>
<body></body>
</html>''',
            null,
            htmlLines([
              [0, '<html>'],
              [1, '<head>'],
              [2, '<script async src="test.dart.js"></script>'],
              [1, '</head>'],
              [1, '<body>'],
              [1, '</body>'],
              [0, '</html>']
            ]));
      });
    });
    group('element', () {
      setUp(() {});

      test('basic', () async {
        await checkYachtTransformElement(
            '<a></a>', null, htmlLines(['<a></a>']));
      });
      test('style', () async {
        await checkYachtTransformElement(
            '<style></style>', null, htmlLines(['<style></style>']));
        await checkYachtTransformElement(
            '<style>\n</style>', null, htmlLines(['<style></style>']));
        await checkYachtTransformElement(
            '\n<style>\n</style>\n', null, htmlLines(['<style></style>']));
        await checkYachtTransformElement('<style amp-custom>\n\n</style>', null,
            htmlLines(['<style amp-custom></style>']));
        await checkYachtTransformElement('<style amp-custom>\n\n</style>', null,
            htmlLines(['<style amp-custom></style>']));
      });

      test('style_import', () async {
        await checkYachtTransformElement(
            '<style>@import url(_included.css)</style>',
            stringAssets(['_included.css', 'body{color:red}']),
            htmlLines(['<style>body { color: red; }</style>']));
      });

      test('style_import_missing', () async {
        await checkYachtTransformElement(
            '<style>@import url(included.css)</style>',
            null,
            htmlLines(['<style>@import url(included.css);</style>']));
      });

      test('debug', () async {
        // copy what you test here with solo_test
      });

      test('include', () async {
        await checkYachtTransformElement(
            '<div><meta property="yacht-include" content="_included.html"></div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines(['<div><p>Simple content</p></div>']));
      });
      test('include_missing', () async {
        try {
          await checkYachtTransformElement(
              '<div><meta property="yacht-include" content="_included.html"></div>',
              null,
              htmlLines(['<div></div>']));
          fail('should fail');
        } on ArgumentError catch (_) {}
        ;
      });
    });
    group('options', () {
      test('default', () {
        YachtTransformOption option =
            new YachtTransformOption.fromBarbackSettings(null);
        expect(option.isDebug, isFalse);
        expect(option.isRelease, isTrue);
        expect(option.isImport, isTrue);
        option.import = false;
        expect(option.isImport, isFalse);
        option.import = 'debug';
        expect(option.isImport, isFalse);
        option.import = true;
        expect(option.isImport, isTrue);
        option.import = 'release';
        expect(option.isImport, isTrue);

        // import
        option.debug = true;
        expect(option.isImport, isFalse);
        option.import = true;
        expect(option.isImport, isTrue);
        option.import = 'debug';
        expect(option.isImport, isTrue);
        option.import = 'release';
        expect(option.isImport, isFalse);
        option.import = false;
        expect(option.isImport, isFalse);
      });
      test('barback', () {
        YachtTransformOption option =
            new YachtTransformOption.fromBarbackSettings(
                new BarbackSettings({'import': 'debug'}, BarbackMode.DEBUG));
        expect(option.isDebug, isTrue);
        expect(option.isRelease, isFalse);
        expect(option.isImport, isTrue);
      });
    });
  });
}
