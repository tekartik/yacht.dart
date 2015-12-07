library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';
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

    group('yacht-html', () {
      test('basic', () async {
        await checkYachtTransformDocument('<yacht-html></yacht-html>', null,
            htmlLines(['<html>', '</html>']));
      });
      test('invalid_head', () async {
        await checkYachtTransformDocument(
            '<yacht-html><head></head></yacht-html>',
            null,
            htmlLines(['<html>', '</html>']));
      });

      test('head', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head></yacht-head></yacht-html>',
            null,
            htmlLines([
              '<html>',
              [1, '<head></head>'],
              '</html>'
            ]));
      });
      test('head_content', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head><meta></yacht-head></yacht-html>',
            null,
            htmlLines([
              '<html>',
              [1, '<head>'],
              [2, '<meta>'],
              [1, '</head>'],
              '</html>'
            ]));
      });

      test('body', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-body></yacht-body><yacht-head></yacht-head></yacht-html>',
            null,
            htmlLines([
              '<html>',
              [1, '<head></head>'],
              [1, '<body></body>'],
              '</html>'
            ]));
      });

      test('body_contet', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-body><h1>title</h1></yacht-body></yacht-html>',
            null,
            htmlLines([
              '<html>',
              [1, '<body><h1>title</h1></body>'],
              '</html>'
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
        await checkYachtTransformElement(
            '<style>@color1: red; body { color: @color1; }</style>',
            null,
            htmlLines(['<style>body { color: red; }</style>']));
      });

      test('style_ignore', () async {
        await checkYachtTransformElement(
            '<style yacht-ignore>@color1: red; body { color: @color1; }</style>',
            null,
            htmlLines(
                ['<style>@color1: red; body { color: @color1; }</style>']));
        await checkYachtTransformElement('<style yacht-ignore>\n</style>', null,
            htmlLines(['<style>', '</style>']));
      });

      test('style_data_ignore', () async {
        await checkYachtTransformElement(
            '<style data-yacht-ignore>@color1: red; body { color: @color1; }</style>',
            null,
            htmlLines(
                ['<style>@color1: red; body { color: @color1; }</style>']));
        await checkYachtTransformElement('<style data-yacht-ignore>\n</style>',
            null, htmlLines(['<style>', '</style>']));
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
            '<div><yacht-include src="_included.html"></yacht-include></div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines(['<div><p>Simple content</p></div>']));
      });

      test('include_meta', () async {
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
  });
}
