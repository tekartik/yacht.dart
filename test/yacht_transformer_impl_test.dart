library yacht.test.yacht_impl_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer_memory.dart';
import 'package:yacht/src/html_printer.dart';
import 'package:yacht/src/transformer.dart';
import 'dart:async';
import 'transformer_memory_test.dart';
import 'html_printer_test.dart';



class YachtTransformer extends Object with YachtTransformerMixin {
  @override
  BarbackSettings settings;
  @override
  HtmlLines htmlLines;
  YachtTransformer([this.settings]);
}

// check for index.html
Future checkYachtTransform(YachtTransformer transformer,
    StringAssets inputAssets, StringAssets outputsExpected) async {
  YachtTransformer transformer = new YachtTransformer();

  AssetId primaryId = assetId("index.html");
  StringAsset primaryAsset = inputAssets[primaryId];
  var transform = new StringTransform(primaryAsset, inputAssets);
  expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));
  expect(transform, isNot(new isInstanceOf<DeclaringTransform>()));
  expect(transform.isConsumed, isNull);
  expect(transform.outputs, {});

  // await needed here
  await transformer.run(transform);

  expect(transform.outputs, outputsExpected,
      reason: "outputs(${primaryAsset.id})");
}

assetId(String path) => new AssetId(null, path);
main() {
  group('StringAssets', () {});
  group('yacht_impl', () {
    test('isPrimary', () {
      void _checkPrimary(AssetId id, Matcher expected) {
        YachtTransformer transformer = new YachtTransformer();

        // no await here in our implementation
        expect(transformer.isPrimary(id), expected);

        var transform = new StringIsPrimaryTransform(id);

        // no await here in our implementation
        expect(transformer.run(transform), expected);
      }
      _checkPrimary(assetId('in'), isFalse);
      _checkPrimary(assetId('test.js'), isFalse);
      _checkPrimary(assetId('test.html'), isTrue);
      _checkPrimary(assetId('_test.html'), isTrue);
      _checkPrimary(assetId('test.part.html'), isTrue);
      _checkPrimary(assetId('test.css'), isTrue);
      _checkPrimary(assetId('_test.css'), isTrue);
      _checkPrimary(assetId('test.part.css'), isTrue);
    });

    test('DeclaringTransform', () {
      Future _checkDeclaring(
          AssetId id, Matcher isConsumed, List<AssetId> outputsExpected) async {
        YachtTransformer transformer = new YachtTransformer();

        var transform = new StringDeclaringTransform(id);
        expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

        expect(transform.isConsumed, isNull);
        expect(transform.outputs, []);

        // no await here in our implementation
        transformer.run(transform);

        expect(transform.isConsumed, isConsumed, reason: "isConsumed($id)");
        expect(transform.outputs, outputsExpected, reason: "outputs($id)");
      }
      _checkDeclaring(assetId('in'), isNull, []);
      AssetId id = assetId('test.html');
      _checkDeclaring(id, isNull, [id]);
      _checkDeclaring(assetId('test.part.html'), isTrue, []);
    });

    test('Transform', () {
      Future _checkTransform(StringAsset primaryAsset, StringAssets inputAssets,
          Matcher isConsumed, StringAssets outputsExpected) async {
        YachtTransformer transformer = new YachtTransformer();

        var transform = new StringTransform(primaryAsset, inputAssets);
        expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

        expect(transform.isConsumed, isNull);
        expect(transform.outputs, {});

        // await needed here
        await transformer.run(transform);

        expect(transform.isConsumed, isConsumed,
            reason: "isConsumed(${primaryAsset.id})");
        expect(transform.outputs, outputsExpected,
            reason: "outputs(${primaryAsset.id})");
      }
      AssetId id = assetId('test.html');
      _checkTransform(
          stringAsset(id, ''), null, isNull, stringAssets([id.path, minHtml]));

      _checkTransform(
          stringAsset(
              id, '<!doctype html><html><head></head><body></body></html>'),
          null,
          isNull,
          stringAssets([
            id.path,
            minHtml
          ]));

      // important check for new line before and after
      _checkTransform(
          stringAsset(
              id, '\n<!doctype html><html><head></head><body></body></html>\n'),
          null,
          isNull,
          stringAssets([
            id.path,
            minHtml
          ]));
    });
    test('checkYachtTransform', () {
      //checkYachtTransform()
      Future _checkTransform(StringAsset primaryAsset, StringAssets inputAssets,
          Matcher isConsumed, StringAssets outputsExpected) async {
        YachtTransformer transformer = new YachtTransformer();

        var transform = new StringTransform(primaryAsset, inputAssets);
        expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

        expect(transform.isConsumed, isNull);
        expect(transform.outputs, {});

        // await needed here
        await transformer.run(transform);

        expect(transform.isConsumed, isConsumed,
            reason: "isConsumed(${primaryAsset.id})");
        expect(transform.outputs, outputsExpected,
            reason: "outputs(${primaryAsset.id})");
      }

      AssetId id = assetId('index.html');
      _checkTransform(stringAsset(id, minInHtml), null, isNull,
          stringAssets([id.path, minHtml]));
    });

    test('checkYachtTransformElement', () {
      //checkYachtTransform()
      Future _checkTransform(
          String html, StringAssets inputAssets, HtmlLines lines) async {
        YachtTransformer transformer = new YachtTransformer();

        AssetId id = assetId("index.html");
        StringAsset asset = stringAsset(id, html);
        var transform = new StringTransform(asset, inputAssets);

        transformer.runElementTransform(transform);
        expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

        expect(transform.isConsumed, isNull);
        expect(transform.outputs, {});
        expect(transformer.htmlLines, isNull);

        // await needed here
        await transformer.runElementTransform(transform);

        expect(transformer.htmlLines, lines);
      }

      /*
      AssetId id = assetId('index.html');
      _checkTransform(stringAsset(id, minInHtml), null, isNull,
          stringAssets([id.path, minHtml]));
          */
      _checkTransform('<a></a>', null, htmlLines(['<a></a>']));
      //TODO_checkTransform('<a>text</a>', null, htmlLines(['<a>text</a>']));
    });
  });
}
