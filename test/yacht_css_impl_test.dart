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

      test('simple_property', () async {
        await checkElementTransform('<style> body {\n opacity: 0; \n} </style>',
            null, htmlLines(['<style>body { opacity: 0; }</style>']));
      });

      test('two_properties', () async {
        await checkElementTransform(
            '<style> html, body {\n opacity: 0; \ncolor: red;} </style>',
            null,
            htmlLines(
                ['<style>html,body { opacity: 0; color: red; }</style>']));
      });

      test('import', () async {
        await checkElementTransform(
            '<style> @import url(_included.css)</style>',
            stringAssets(['_included.css', 'body{color:red}']),
            htmlLines(['<style>body { color: red; }</style>']));
      });

      test('missing_import', () async {
        await checkElementTransform(
            '<style> @import url(_included.css)</style>',
            null,
            htmlLines(['<style>@import url(_included.css);</style>']));
      });
    });
  });
}
