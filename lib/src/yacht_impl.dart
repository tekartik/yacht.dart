library yacht.src.yacht_impl;

import 'transformer.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:yacht/src/html_printer.dart';
import 'package:html/dom.dart';
import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'common_import.dart';

class _YachtIsPrimaryTransform extends AssetTransform
    implements IsPrimaryTransform {
  final AssetId primaryId;
  _YachtIsPrimaryTransform(this.primaryId);
}

abstract class YachtTransformerMixin {
  BarbackSettings get settings;
  // YachtTransformer.asPlugin([BarbackSettings settings]) : super.asPlugin(settings);

  // Override to set a flag
  bool setIsPrimary(bool isPrimary) => isPrimary;

  YachtTransformOption _option;
  YachtTransformOption get option {
    if (_option == null) {
      _option = new YachtTransformOption.fromBarbackSettings(settings);
    }
    return _option;
  }

  set htmlLines(HtmlLines lines) {}

  HtmlPrinterOptions _options;
  HtmlPrinterOptions get options {
    if (_options == null) {
      _options = new HtmlPrinterOptions.fromBarbackSettings(settings);
    }
    return _options;
  }

  runElementTransform(Transform transform) async {
    String input = await transform.readPrimaryAsString();

    // only for testing
    if (input == null) {
      return null;
    }

    // trim extra spaces
    Element element = new Element.html(input.trim());

    //devPrint('before: ${element.outerHtml}');
    // element =
    await handleElement(transform, transform.primaryId, element);

    //devPrint('after: ${element.outerHtml}');
    // extract lines
    HtmlElementPrinter printer = new HtmlElementPrinter();
    await printer.visitElement(element);
    HtmlLines outHtmlLines = printer.lines;
    // test subclass may override this to get the lines emitted
    htmlLines = outHtmlLines;
  }

  run(AssetTransform transform) {
    AssetId primaryId = transform.primaryId;
    String basename = posix.basename(primaryId.path);
    String extension = posix.extension(basename);

    bool isPrimary = true;
    // handle part
    if (!(extension == '.html' || extension == '.css')) {
      isPrimary = false;
    }

    if (transform is IsPrimaryTransform) {
      // return as primary
      return setIsPrimary(isPrimary);
    } else if (!isPrimary) {
      // abort here
      return null;
    }

    bool isMaster = true;
    if (basename.startsWith('_')) {
      isMaster = false;
    }
    if (isMaster) {
      String basenameWithoutExtenstion =
          posix.basenameWithoutExtension(basename);
      String subExtension = posix.extension(basenameWithoutExtenstion);

      // handle part
      if (subExtension == '.part') {
        isMaster = false;
      }
    }

    // if not master, consume it
    if (!isMaster) {
      if (transform is ConsumableTransform) {
        transform.consumePrimary();
      }
      return null;
    }

    if (transform is DeclaringTransform) {
      transform.declareOutput(primaryId);
      return null;
    }

    // Need to read content now...
    return new Future.sync(() async {
      if (transform is Transform) {
        if (extension == '.html') {
          return transformHtml(transform);
        } else if (extension == '.css') {
          return transformCss(transform);
        }
      } else {
        throw 'should not get there';
      }
    });

/*
    if (transform is DeclaringTransform) {
      transform.declareOutput(transform.primaryId);
    } else if (transform is Transform) {
      // let it go
      // transform.a

    }
    // handle part - sub
    // declare ourself as output
    //transform.declareOutput(transform.primaryId);
*/
  }

  // @override
  String get allowedExtensions => '.html .css';

  // @override
  isPrimary(AssetId id) {
    IsPrimaryTransform transform = new _YachtIsPrimaryTransform(id);
    return run(transform);
  }

  Future transformCss(Transform transform) async {
    String input = await transform.readPrimaryAsString();

    AssetId assetId = transform.primaryId;
    // only for testing
    if (input == null) {
      return null;
    }

    String newCss = await _transformCss(transform, assetId, input);
    if (newCss != null) {
      transform.addOutputFromString(assetId, newCss);
    }
  }

  // copied from dart_2_js_script_rewriter
  void removeDartDotJsTags(Document document) {
    document.querySelectorAll('script').where((tag) {
      return tag.attributes['src'] != null &&
          tag.attributes['src'].endsWith('browser/dart.js');
    }).forEach((tag) => tag.remove());
  }

  // copied from dart_2_js_script_rewriter
  void rewriteDartTags(Document document) {
    document.querySelectorAll('script').where((tag) {
      return tag.attributes['type'] == 'application/dart' &&
          tag.attributes['src'] != null;
    }).forEach((tag) {
      var src = tag.attributes['src'];
      tag.attributes['src'] = src.replaceFirstMapped(
          new RegExp(r'\.dart($|[\?#])'), (match) => '.dart.js${match[1]}');
      tag.attributes.remove('type');
    });
  }

  Future transformHtml(Transform transform) async {
    AssetId primaryId = transform.primaryId;
    String input = await transform.readPrimaryAsString();

    // only for testing
    if (input == null) {
      return null;
    }

    // trim extra spaces as data after </html> might include TEXT_NODE in the body
    Document document = new Document.html(input.trim());

    HtmlPrinterOptions options =
        new HtmlPrinterOptions.fromBarbackSettings(settings);

    // Convert content
    // - include
    await handleElement(transform, primaryId, document.documentElement);

    // Rewrite script
    if (!option.isDebug) {
      removeDartDotJsTags(document);
      rewriteDartTags(document);
    }
    // extract lines
    HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
    await printer.visitDocument(document);
    HtmlLines outHtmlLines = printer.lines;
    // test subclass my override this to get the lines emitted
    htmlLines = outHtmlLines;

    // print
    String output = await htmlPrintLines(outHtmlLines, options: options);

    /*
        if (false) {
          // quick debug
          HtmlDocumentNodeLinesPrinter builder =
              new HtmlDocumentNodeLinesPrinter();
          await builder.visitDocument(document);
          print('nodes: ${builder.lines}');

          HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
          await printer.visitDocument(document);
          print('lines: ${printer.lines}');

          print('input: ${input}');
          print('output: ${output}');
        }
        */

    transform.addOutputFromString(primaryId, output);
  }

  _handleCss(_CssTransform cssTransform) async {
    AssetId assetId = cssTransform.assetId;
    StyleSheet styleSheet = cssTransform.styleSheet;
    Transform transform = cssTransform.transform;
    List<TreeNode> childNodes = new List.from(styleSheet.topLevels);
    for (TreeNode node in childNodes) {
      if (node is ImportDirective) {
        // Don't do it for debug or import option
        if (option.isImport) {
          cssTransform.hasImport = true;
          String path =
              posix.normalize(join(posix.dirname(assetId.path), node.import));
          AssetId importedAssetId = new AssetId(assetId.package, path);
          if (await transform.hasInput(importedAssetId)) {
            StyleSheet importedStyleSheet = compile(
                await transform.readInputAsString(importedAssetId),
                polyfill: true);

            await _handleCss(new _CssTransform(transform)
              ..assetId = importedAssetId
              ..styleSheet = importedStyleSheet);

            int index = styleSheet.topLevels.indexOf(node);
            styleSheet.topLevels
              ..removeAt(index)
              ..insertAll(index, importedStyleSheet.topLevels);
          }
        }
      }
    }
  }

  // return the converted string
  Future<String> _transformCss(
      Transform transform, AssetId assetId, String css) async {
    StyleSheet styleSheet = compile(css, polyfill: true);

    _CssTransform cssTransform = new _CssTransform(transform)
      ..assetId = assetId
      ..styleSheet = styleSheet;
    await _handleCss(cssTransform);
    CssPrinter printer = new CssPrinter();

    printer.visitTree(styleSheet, pretty: option.isDebug);
    String newCss = printer.toString();
    if (cssTransform.hasImport == true || newCss.length < css.length) {
      return newCss;
    }
    return null;
  }

  handleElement(Transform transform, AssetId assetId, Element element) async {
    // handle styles
    // Resolve css
    _handleStyle(Element element) async {
      //print(element.text);
      String existingCss = element.text;

      String newCss = await _transformCss(transform, assetId, existingCss);
      if (newCss != null) {
        element.text = newCss;
      }
      /*
      StyleSheet styleSheet = compile(existingCss, polyfill: true);
      CssPrinter printer = new CssPrinter();
      bool hasImport = false;
      _resolveImport(AssetId assetId, StyleSheet styleSheet) async {
        List<TreeNode> childNodes = new List.from(styleSheet.topLevels);
        for (TreeNode node in childNodes) {
          if (node is ImportDirective) {
            hasImport = true;
            String path =
                posix.normalize(join(posix.dirname(assetId.path), node.import));
            AssetId importedAssetId = new AssetId(assetId.package, path);
            if (await transform.hasInput(importedAssetId)) {
              StyleSheet importedStyleSheet = compile(
                  await transform.readInputAsString(importedAssetId),
                  polyfill: true);

              await _resolveImport(importedAssetId, importedStyleSheet);

              int index = styleSheet.topLevels.indexOf(node);
              styleSheet.topLevels
                ..removeAt(index)
                ..insertAll(index, importedStyleSheet.topLevels);
            }
          }
        }
      }
      await _resolveImport(assetId, styleSheet);
      printer.visitTree(styleSheet, pretty: false);
      String newCss = printer.toString();
      if (hasImport || newCss.length < existingCss.length) {
        element.text = newCss;
      }
      */
    }
    if (element.localName == 'style') {
      await _handleStyle(element);
    }
    List<Element> styleElements = element.querySelectorAll('style');
    for (Element element in styleElements) {
      await _handleStyle(element);
    }

    _handleYachtInclude(Element element) async {
      if (element.attributes['property'] == 'yacht-include') {
        String included = element.attributes['content'];
        //print(included);
        // go relative
        // TODO handle other package
        AssetId includedAssetId = new AssetId(assetId.package,
            posix.normalize(join(posix.dirname(assetId.path), included)));
        String includedContent =
            await transform.readInputAsString(includedAssetId);

        //devPrint(includedContent);
        if (includedContent == null) {
          throw new ArgumentError('asset $includedAssetId not found');
        }

        bool multiElement = false;
        Element includedElement;

        // where to include
        int index = element.parent.children.indexOf(element);

        // try to parse if it fails, wrap it
        try {
          includedElement = new Element.html(includedContent);
        } catch (e) {
          multiElement = true;
          includedElement = new Element.html(
              '<tekartik-yacht-merge>${includedContent}</tekartik-yacht-merge>');
        }

        // Save parent (as element will be removed
        Element parent = element.parent;

        // Insert first so that it has a parent
        parent.children
          ..removeAt(index)
          ..insert(index, includedElement);

        // handle recursively first
        await handleElement(transform, includedAssetId, includedElement);

        // multi element 'un-merge'
        if (multiElement) {
          // save a copy
          List<Element> children = new List.from(includedElement.children);

          parent.children..removeAt(index);
          for (Element child in children) {
            parent.children..insert(index++, child);
          }
        }
      }
    }
    if (element.localName == 'meta') {
      await _handleYachtInclude(element);
      //throw 'meta not supported as main element';
    } else {
      List<Element> list = element.querySelectorAll('meta');
      for (Element element in list) {
        await _handleYachtInclude(element);
      }
    }
  }
}

class _CssTransform {
  Transform transform;
  bool hasImport;
  AssetId assetId;
  StyleSheet styleSheet;
  _CssTransform(this.transform);
}

class YachtTransformOption {
  bool get isDebug => _debug == true;
  bool get isRelease => !isDebug;

  bool get isImport {
    if (isSettingTrue(_import)) {
      return true;
    } else if (isSettingFalse(_import)) {
      return false;
    } else if (isSettingDebug(_import)) {
      return isDebug;
    }
    return isRelease;
  }

  bool _debug;

  // for test
  bool set debug(bool debug) => _debug = debug;

  // can be true/false/debug/release
  set import(var import) => _import = import;
  var _import;
  YachtTransformOption.fromBarbackSettings(BarbackSettings settings) {
    if (settings != null) {
      _debug = settings.mode != BarbackMode.RELEASE;
      _import = settings.configuration['import'];
    }
  }

  static bool isSettingTrue(var value) {
    return value == true;
  }

  static bool isSettingFalse(var value) {
    return value == false;
  }

  static bool isSettingDebug(var value) {
    return value == 'debug';
  }

  static bool isSettingRelease(var value) {
    return value == 'release';
  }
}
