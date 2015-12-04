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
    group('css', () {
      setUp(() {});

      /*
      solo_test('basic', () async {
        await checkElementTransform('<style> body, html {\n opacity: 0; \n} </style>', null, htmlLines(['<a></a>']));
      });
      */
    });
    group('element', () {
      setUp(() {});

      test('basic', () async {
        await checkElementTransform('<a></a>', null, htmlLines(['<a></a>']));
      });
      test('style', () async {
        await checkElementTransform(
            '<style></style>', null, htmlLines(['<style></style>']));
        await checkElementTransform(
            '<style>\n</style>', null, htmlLines(['<style></style>']));
        await checkElementTransform(
            '\n<style>\n</style>\n', null, htmlLines(['<style></style>']));
        await checkElementTransform('<style amp-custom>\n\n</style>', null,
            htmlLines(['<style amp-custom></style>']));
        await checkElementTransform('<style amp-custom>\n\n</style>', null,
            htmlLines(['<style amp-custom></style>']));
      });

      test('debug', () async {
        await checkElementTransform(
            '<style>\n</style>', null, htmlLines(['<style></style>']));
      });

      test('include', () async {
        await checkElementTransform(
            '<div><meta property="yacht-include" content="_included.html"></div>',
            stringAssets(['_included.html', '<p>Simple content</p>']),
            htmlLines(['<div><p>Simple content</p></div>']));
      });
      test('include_missing', () async {
        try {
          await checkElementTransform(
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
