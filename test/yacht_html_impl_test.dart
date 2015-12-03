library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer.dart';

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
      test('basic', () async {
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
  });
}
