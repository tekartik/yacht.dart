library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';
import 'yacht_transformer_impl_test.dart';
import 'html_printer_test.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  BarbackSettings settings;
  YachtTransformer([this.settings]);
}

assetId(String path) => new AssetId(null, path);
main() {
  //YachtTransformer transformer;
  group('yacht_html_impl', () {
    group('element', () {
      setUp(() {});
      test('style', () async {
        await checkElementTransform(
            '<style></style>', null, htmlLines(['<style></style>']));
        await checkElementTransform(
            '<style>\n</style>', null, htmlLines(['<style>', '</style>']));
        await checkElementTransform(
            '\n<style>\n</style>\n', null, htmlLines(['<style>', '</style>']));
        await checkElementTransform('<style amp-custom>\n\n</style>', null,
            htmlLines(['<style amp-custom>', '</style>']));
        await checkElementTransform('<style amp-custom>\n\n</style>', null,
            htmlLines(['<style amp-custom>', '</style>']));
        /*
          await checkElementTransform('''
          <style amp-custom>
          </style>
''', null, htmlLines(['<style amp-custom>', '</style>']));
*/

        //TODO_checkTransform('<a>text</a>', null, htmlLines(['<a>text</a>']));
      });
      /*
        transformer = new YachtTransformer();
        String content = '<div></div>';

        AssetId assetId = ctx.addStringAsset('basic.html', content);
        Transform transform = ctx.newTransform(null);
        Element element = html.createElementHtml(content, noValidate: true);
        await transformer.handleElement(transform, assetId, element);
        expect(element.outerHtml, content);
        */
    });
  });
}
