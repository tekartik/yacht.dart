import 'package:dev_test/test.dart';
import 'package:yacht/src/yacht_impl.dart';
import 'package:yacht/src/transformer_memory.dart';
import 'package:yacht/src/html_printer.dart';
import 'package:yacht/src/transformer.dart';
import 'dart:async';
import 'transformer_memory_test.dart';
import 'html_printer_test.dart';
import 'package:html/dom.dart';

class YachtTransformer extends Object with YachtTransformerMixin {
  YachtTransformOption option =
      new YachtTransformOption.fromBarbackSettings(null);
  @override
  BarbackSettings settings;
  @override
  HtmlLines htmlLines;
  YachtTransformer([this.settings]);
}

Future checkTransform(StringAsset primaryAsset, StringAssets inputAssets,
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

// main input is style.css
// null means no transform result
Future checkYachtTransformCss(
    String css, StringAssets inputAssets, String expectedCss) async {
  YachtTransformer transformer = new YachtTransformer();

  AssetId primaryId = assetId("style.css");
  StringAsset primaryAsset = stringAsset(primaryId, css);
  var transform = new StringTransform(primaryAsset, inputAssets);
  expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));
  expect(transform, isNot(new isInstanceOf<DeclaringTransform>()));

  expect(transform.isConsumed, isNull);
  expect(transform.outputs, {});

  // await needed here
  await transformer.run(transform);

  // expect empty
  if (expectedCss == null) {
    expect(transform.outputs, isEmpty);
  } else {
    try {
      expect(transform.outputs[primaryId].content, expectedCss,
          reason: "outputs(${primaryId})");
    } catch (e) {
      print("output ${primaryId} not found");
      print(transform.outputs);
      rethrow;
    }
  }
}

//checkYachtTransform()
Future<Element> checkYachtTransformElement(
    String html, StringAssets inputAssets, HtmlLines lines,
    {YachtTransformOption option}) async {
  YachtTransformer transformer = new YachtTransformer();
  if (option != null) {
    transformer.option = option;
  }
  AssetId id = assetId("index.html");
  StringAsset asset = stringAsset(id, html);
  var transform = new StringTransform(asset, inputAssets);

  //await transformer.runElementTransform(transform);
  expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

  expect(transform.isConsumed, isNull);
  expect(transform.outputs, {});
  expect(transformer.htmlLines, isNull);

  // await needed here
  Element element = await transformer.runElementTransform(transform);

  expect(transformer.htmlLines, lines);

  return element;
}

Future checkYachtTransformDocument(
    String html, StringAssets inputAssets, HtmlLines lines) async {
  YachtTransformer transformer = new YachtTransformer();

  AssetId id = assetId("index.html");
  StringAsset asset = stringAsset(id, html);
  var transform = new StringTransform(asset, inputAssets);

  //await transformer.runElementTransform(transform);
  expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

  expect(transform.isConsumed, isNull);
  expect(transform.outputs, {});
  expect(transformer.htmlLines, isNull);

  // await needed here
  await transformer.run(transform);

  expect(transformer.htmlLines, lines);
}

Future checkYachtTransformMarkdown(
    String markdown, StringAssets inputAssets, HtmlLines lines) async {
  YachtTransformer transformer = new YachtTransformer();

  AssetId id = assetId("index.md");
  StringAsset asset = stringAsset(id, markdown);
  var transform = new StringTransform(asset, inputAssets);

  //await transformer.runElementTransform(transform);
  expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));

  expect(transform.isConsumed, isNull);
  expect(transform.outputs, {});
  expect(transformer.htmlLines, isNull);

  // await needed here
  await transformer.run(transform);

  expect(transformer.htmlLines, lines);
}

assetId(String path) => new MemoryAssetId(null, path);
main() {
  group('yacht_impl', () {
    test('isPrimary', () {
      void _checkPrimary(AssetId id, Matcher expected) {
        YachtTransformer transformer = new YachtTransformer();

        // no await here in our implementation
        expect(transformer.isAssetPrimary(id), expected);

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

    Future __checkDeclaring(YachtTransformer transformer, AssetId id,
        Matcher isConsumed, List<AssetId> outputsExpected) async {
      var transform = new StringDeclaringTransform(id);
      expect(transform, isNot(new isInstanceOf<IsPrimaryTransform>()));
      expect(transform, isNot(new isInstanceOf<Transform>()));

      expect(transform.isConsumed, isNull);
      expect(transform.outputs, []);

      // no await here in our implementation
      transformer.run(transform);

      expect(transform.isConsumed, isConsumed, reason: "isConsumed($id)");
      expect(transform.outputs, outputsExpected, reason: "outputs($id)");
    }

    Future _checkDeclaring(
        AssetId id, Matcher isConsumed, List<AssetId> outputsExpected) async {
      YachtTransformer transformer = new YachtTransformer();
      return __checkDeclaring(transformer, id, isConsumed, outputsExpected);
    }

    Future _checkDebugDeclaring(
        AssetId id, Matcher isConsumed, List<AssetId> outputsExpected) async {
      YachtTransformer transformer = new YachtTransformer()
        ..option.debug = true;
      return __checkDeclaring(transformer, id, isConsumed, outputsExpected);
    }

    test('DeclaringTransformHtml', () {
      _checkDeclaring(assetId('in'), isNull, []);
      AssetId id = assetId('test.html');
      _checkDeclaring(id, isNull, [id]);
      _checkDeclaring(assetId('test.part.html'), isTrue, []);
      _checkDebugDeclaring(assetId('test.part.html'), isNull, []);
    });

    test('DeclaringTransformCss', () {
      AssetId id = assetId('test.css');
      _checkDeclaring(id, isNull, [id]);
      _checkDeclaring(assetId('test.part.css'), isTrue, []);
      _checkDebugDeclaring(assetId('test.part.css'), isNull, []);
    });

    test('TransformHtml', () {
      AssetId id = assetId('test.html');
      checkTransform(
          stringAsset(id, ''), null, isNull, stringAssets([id.path, minHtml]));

      checkTransform(
          stringAsset(
              id, '<!doctype html><html><head></head><body></body></html>'),
          null,
          isNull,
          stringAssets([id.path, minHtml]));

      // important check for new line before and after
      checkTransform(
          stringAsset(
              id, '\n<!doctype html><html><head></head><body></body></html>\n'),
          null,
          isNull,
          stringAssets([id.path, minHtml]));
    });

    test('checkYachtTransformCss', () async {
      // css
      AssetId id = assetId('test.css');
      /*
      _checkTransform(
          stringAsset(id, 'body{color:red}'),
          null,
          isNull,
          stringAssets([id.path, 'body{color:red}'])); // short kept as is
          */

      await checkTransform(
          stringAsset(id, 'body { color : red; }'),
          null,
          isNull,
          stringAssets([id.path, 'body { color:red; }'])); // short kept as is

      await checkYachtTransformCss(
          'body { color : red; }', null, 'body { color:red; }');
    });

    test('checkYachtTransformHtml', () async {
      //checkYachtTransform()

      AssetId id = assetId('index.html');

      await checkTransform(stringAsset(id, minInHtml), null, isNull,
          stringAssets([id.path, minHtml]));
      await checkYachtTransformDocument(minInHtml, null, minHtmlLines);
    });

    test('checkYachtTransformElement', () async {
      await checkYachtTransformElement('<a></a>', null, htmlLines(['<a></a>']));
    });
  });
}
