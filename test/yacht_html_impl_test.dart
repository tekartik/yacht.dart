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
        await checkYachtTransformDocument(
            '<yacht-html></yacht-html>', null, minHtmlLines);
      });
      test('invalid_head', () async {
        await checkYachtTransformDocument(
            '<yacht-html><head></head></yacht-html>', null, minHtmlLines);
      });

      test('head', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head></yacht-head></yacht-html>',
            null,
            minHtmlLines);
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
              [1, '<body></body>'],
              '</html>'
            ]));
      });

      test('body', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-body></yacht-body><yacht-head></yacht-head></yacht-html>',
            null,
            minHtmlLines);
      });

      test('body_content', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-body><h1>title</h1></yacht-body></yacht-html>',
            null,
            htmlLines([
              '<html>',
              [1, '<head></head>'],
              [1, '<body><h1>title</h1></body>'],
              '</html>'
            ]));
      });

      test('head_include', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head><meta one><yacht-include src="_included.html"></yacht-include><meta four></yacht-head></yacht-html>',
            stringAssets(['_included.html', '<meta two><meta three>']),
            htmlLines([
              '<html>',
              [1, '<head>'],
              [2, '<meta one>'],
              [2, '<meta two>'],
              [2, '<meta three>'],
              [2, '<meta four>'],
              [1, '</head>'],
              [1, '<body></body>'],
              '</html>'
            ]));
      });
      test('head_charset_include', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head><meta charset="utf-8"><yacht-include src="_included.html"></yacht-include></yacht-head></yacht-html>',
            stringAssets(['_included.html', '<meta>']),
            htmlLines([
              '<html>',
              [1, '<head>'],
              [2, '<meta charset="utf-8">'],
              [2, '<meta>'],
              [1, '</head>'],
              [1, '<body></body>'],
              '</html>'
            ]));
      });
      test('head_charset', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head><meta charset="utf-8"><meta one><yacht-include src="_included.html"></yacht-include><meta four></yacht-head></yacht-html>',
            stringAssets(['_included.html', '<meta two><meta three>']),
            htmlLines([
              '<html>',
              [1, '<head>'],
              [2, '<meta charset="utf-8">'],
              [2, '<meta one>'],
              [2, '<meta two>'],
              [2, '<meta three>'],
              [2, '<meta four>'],
              [1, '</head>'],
              [1, '<body></body>'],
              '</html>'
            ]));
      });
      test('head_include_charset', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-head><meta one><yacht-include src="_included.html"></yacht-include><meta four></yacht-head></yacht-html>',
            stringAssets([
              '_included.html',
              '<meta charset="utf-8"><meta two><meta three>'
            ]),
            htmlLines([
              '<html>',
              [1, '<head>'],
              [2, '<meta one>'],
              [2, '<meta charset="utf-8">'],
              [2, '<meta two>'],
              [2, '<meta three>'],
              [2, '<meta four>'],
              [1, '</head>'],
              [1, '<body></body>'],
              '</html>'
            ]));
      });
      /*
      solo_test('head_include_amp', () async {
        await checkYachtTransformDocument('''
        <yacht-html ⚡ lang="en">
<yacht-head>
    <meta charset="utf-8">
    <yacht-include src="part/app_css_js_base.part.html"></yacht-include>
</yacht-head>
<yacht-body>Hello World!</yacht-body>
</yacht-html>'''
            ,stringAssets(['part/app_css_js_base.part.html', '''
<meta>
''']),
            htmlLines([
              '<html>',
              [1, '<head>'],
              [2, '<meta one>'],
              [2, '<meta charset="utf-8">'],
              [2, '<meta two>'],
              [2, '<meta three>'],
              [2, '<meta four>'],
              [1, '</head>'],
              [1, '<body></body>'],
              '</html>'
            ]));
      });
      */

      test('body_include', () async {
        await checkYachtTransformDocument(
            '<yacht-html><yacht-body><meta one><yacht-include src="_included.html"></yacht-include><meta four></yacht-body></yacht-html>',
            stringAssets(['_included.html', '<meta two><meta three>']),
            htmlLines([
              '<html>',
              [1, '<head></head>'],
              [1, '<body>'],
              [2, '<meta one>'],
              [2, '<meta two>'],
              [2, '<meta three>'],
              [2, '<meta four>'],
              [1, '</body>'],
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

      test('code', () async {
        await checkYachtTransformElement(
            '<code>&lt;link rel=prerender&gt;</code>',
            null,
            htmlLines(['<code>&lt;link rel=prerender&gt;</code>']));
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

      test('sub_style', () async {
        await checkYachtTransformElement(
            '<div><style></style></div>',
            null,
            htmlLines([
              '<div>',
              [1, '<style></style>'],
              '</div>'
            ]));
        await checkYachtTransformElement(
            '<div><style>@color1: red; body { color: @color1; }</style></div>',
            null,
            htmlLines([
              '<div>',
              [1, '<style>body { color: red; }</style>'],
              '</div>'
            ]));

        // noscript not converted
        await checkYachtTransformElement(
            '<noscript><style>@color1: red; body { color: @color1; }</style></noscript>',
            null,
            htmlLines([
              '<noscript><style>body { color: red; }</style></noscript>'
            ]));
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

      test('sub_style_ignore', () async {
        await checkYachtTransformElement(
            '<noscript><style yacht-ignore>@color1: red; body { color: @color1; }</style></noscript>',
            null,
            htmlLines([
              '<noscript><style>@color1: red; body { color: @color1; }</style></noscript>'
            ]));
        // !yacht ignore not removed
        await checkYachtTransformElement(
            '<noscript><style yacht-ignore>\n</style></noscript>',
            null,
            htmlLines(['<noscript><style>', [1, '</style></noscript>']]));
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

      test('style_import_sub', () async {
        await checkYachtTransformElement(
            '<style>@import url(sub/_included.css)</style>',
            stringAssets(['sub/_included.css', 'body{color:red}']),
            htmlLines(['<style>body { color: red; }</style>']));
      });

      test('style_import_package', () async {
        await checkYachtTransformElement(
            '<style>@import url(packages/pkg/_included.css)</style>',
            stringAssets(['pkg', 'lib/_included.css', 'body{color:red}']),
            htmlLines(['<style>body { color: red; }</style>']));
      });

      test('style_import_package', () async {
        await checkYachtTransformElement(
            '<style>@import url(packages/pkg/sub/_included.css)</style>',
            stringAssets(['pkg', 'lib/sub/_included.css', 'body{color:red}']),
            htmlLines(['<style>body { color: red; }</style>']));
      });

      test('style_import_missing', () async {
        try {
          await checkYachtTransformElement(
              '<style>@import url(included.css)</style>',
              null,
              htmlLines(['<style>@import url(included.css);</style>']));
          fail("should fail");
        } on ArgumentError catch (_) {}
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

      test('include_from_package', () async {
        await checkYachtTransformElement(
            '<div><yacht-include src="packages/pkg/_included.html"></yacht-include></div>',
            stringAssets(
                ['pkg', 'lib/_included.html', '<p>Simple content</p>']),
            htmlLines(['<div><p>Simple content</p></div>']));
      });

      test('include_linefeed_before', () async {
        // outer
        await checkYachtTransformElement(
            '<div>\n<yacht-include src="_included.html"></yacht-include></div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines(['<div> <p>Simple content</p></div>']));
        // inner
        await checkYachtTransformElement(
            '<div><yacht-include src="_included.html"></yacht-include></div>',
            stringAssets(['_included.html', '\n<a></a>']),
            htmlLines(['<div> <a></a></div>']));
      });

      test('include_linefeed_after', () async {
        // outer
        await checkYachtTransformElement(
            '<div><yacht-include src="_included.html"></yacht-include>\n</div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines(['<div><p>Simple content</p> </div>']));
        // inner
        await checkYachtTransformElement(
            '<div><yacht-include src="_included.html"></yacht-include></div>',
            stringAssets(['_included.html', '<a></a>\n']),
            htmlLines(['<div><a></a> </div>']));
      });

      test('include_linefeed', () async {
        // outer
        await checkYachtTransformElement(
            '<div>\n<yacht-include src="_included.html"></yacht-include>\n</div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines([
              '<div>',
              [1, '<p>Simple content</p>'],
              '</div>'
            ]));
        // inner
        await checkYachtTransformElement(
            '<div><yacht-include src="_included.html"></yacht-include></div>',
            stringAssets(['_included.html', '\n<a></a>\n']),
            htmlLines([
              '<div>',
              [1, '<a></a>'],
              '</div>'
            ]));
      });

      test('include_position', () async {
        await checkYachtTransformElement(
            '<div><a></a><yacht-include src="_included.html"></yacht-include><b></b></div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines(['<div><a></a><p>Simple content</p><b></b></div>']));
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

      test('mode_debug', () async {
        await checkYachtTransformElement(
            '<a yacht-debug></a>', null, htmlLines([]));
        await checkYachtTransformElement(
            '<a yacht-debug></a>', null, htmlLines(['<a></a>']),
            option: new YachtTransformOption()..debug = true);
        await checkYachtTransformElement(
            '<a data-yacht-debug></a>', null, htmlLines([]));
        await checkYachtTransformElement(
            '<a data-yacht-debug></a>', null, htmlLines(['<a></a>']),
            option: new YachtTransformOption()..debug = true);
      });

      test('mode_release', () async {
        await checkYachtTransformElement(
            '<a data-yacht-release></a>', null, htmlLines(['<a></a>']));
        await checkYachtTransformElement(
            '<a data-yacht-release></a>', null, htmlLines([]),
            option: new YachtTransformOption()..debug = true);
      });
    });
  });
}
