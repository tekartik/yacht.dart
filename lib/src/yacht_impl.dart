library yacht.src.yacht_impl;

import 'transformer.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:yacht/src/html_printer.dart';
import 'package:html/dom.dart';
import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'html_utils.dart';
import 'common_import.dart';
import 'csslib_utils.dart';

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
    await handleElement(new _HtmlTransform()..transform = transform,
        transform.primaryId, element);

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
    String path = primaryId.path;
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

    // To be ignored?
    path = posix.normalize(path);
    if (option.ignored.contains(path)) {
      return null;
    }

    // if not master, consume it
    if (!isMaster) {
      if (transform is ConsumableTransform) {
        // only consume in release
        if (option.isRelease) {
          transform.consumePrimary();
        }
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
    await handleElement(new _HtmlTransform()
      ..transform = transform
      ..document = document, primaryId, document.documentElement);

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
            String text = await transform.readInputAsString(importedAssetId);
            StyleSheet importedStyleSheet = parse(text);

            _CssTransform innerCssTransform = new _CssTransform(transform)
              ..assetId = importedAssetId
              ..styleSheet = importedStyleSheet;
            await _handleCss(innerCssTransform);

            // Add the imported stuff from inner transform
            cssTransform.css.addAll(innerCssTransform.css);
            cssTransform.imported.addAll(innerCssTransform.imported);

            cssTransform.css.add(text);
            cssTransform.imported.add(node.import);
          }
        }
      }
    }
  }

  // return the converted string
  Future<String> _transformCss(
      Transform transform, AssetId assetId, String css) async {
    StyleSheet styleSheet = parse(css);
    _CssTransform cssTransform = new _CssTransform(transform)
      ..assetId = assetId
      ..styleSheet = styleSheet;
    await _handleCss(cssTransform);

    // add last
    cssTransform.css.add(css);

    // build master
    String tempCss = cssTransform.css.join('\n');
    //devPrint('#${tempCss}');
    styleSheet = compile(tempCss, polyfill: true);

    // remove imported @import
    List<TreeNode> childNodes = new List.from(styleSheet.topLevels);
    for (TreeNode node in childNodes) {
      if (node is ImportDirective) {
        // Don't do it for debug or import option
        if (option.isImport) {
          String imported = node.import;
          if (cssTransform.imported.contains(imported)) {
            int index = styleSheet.topLevels.indexOf(node);
            styleSheet.topLevels..removeAt(index);
          }
        }
      }
    }

    // write

    String newCss = printStyleSheet(styleSheet, pretty: option.isDebug);

    return newCss;
  }

  handleElement(
      _HtmlTransform htmlTransform, AssetId assetId, Element element_) async {
    Element element = element_;

    Transform transform = htmlTransform.transform;

    /// If top element return the element returned by the action
    /// which could be different
    _handleTag(String tag, Future<Element> action(Element element)) async {
      if (element.localName == tag) {
        element = await action(element);
      } else {
        List<Element> list = element.querySelectorAll(tag);
        for (Element element in list) {
          await action(element);
        }
      }
      return element;
    }

    Document _getDocument() {
      Document document = htmlTransform.document;
      if (document == null) {
        throw new ArgumentError('must be in a document');
      }
      return document;
    }
    // first extract yacht-html if any
    // only works when  within a document
    Future<Element> _handleYachtHtml(Element element) async {
      Document document = _getDocument();
      Element htmlElement = document.documentElement;
      copyElementAttributes(element, htmlElement);
      replaceElementNodes(element, htmlElement);
      return htmlElement;
    }

    await _handleTag('yacht-html', _handleYachtHtml);

    // then handle head/body
    Future<Element> _handleYachtHead(Element element) async {
      Document document = _getDocument();
      Element headElement = document.head;
      if (headElement == null) {
        headElement = new Element.tag('head');
        document.documentElement.nodes.insert(0, headElement);
      }
      copyElementAttributes(element, headElement);
      replaceElementNodes(element, headElement);

      // remove head
      element.remove();

      return headElement;
    }
    await _handleTag('yacht-head', _handleYachtHead);
    // then handle head/body
    Future<Element> _handleYachtBody(Element element) async {
      Document document = _getDocument();
      Element bodyElement = document.body;
      if (bodyElement == null) {
        bodyElement = new Element.tag('body');
        document.documentElement.nodes.add(bodyElement);
      }
      copyElementAttributes(element, bodyElement);
      replaceElementNodes(element, bodyElement);

      // remove body
      element.remove();

      return bodyElement;
    }
    await _handleTag('yacht-body', _handleYachtBody);

    // handle styles
    // Resolve css
    Future<Element> _handleStyle(Element element) async {
      // ignored?
      if (element.attributes.containsKey('data-yacht-ignore')) {
        element.attributes.remove('data-yacht-ignore');
      } else if (element.attributes.containsKey('yacht-ignore')) {
        element.attributes.remove('yacht-ignore');
      } else {
        //print(element.text);
        String existingCss = element.text;

        String newCss = await _transformCss(transform, assetId, existingCss);
        if (newCss != null) {
          element.text = newCss;
        }
      }
      return element;
    }
    await _handleTag('style', _handleStyle);

    Future<Element> _handleYachtInclude(Element element, String src) async {
      //print(included);
      // go relative
      // TODO handle other package
      AssetId includedAssetId = new AssetId(assetId.package,
          posix.normalize(join(posix.dirname(assetId.path), src)));
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
      await handleElement(new _HtmlTransform()..transform = transform,
          includedAssetId, includedElement);

      // multi element 'un-merge'
      if (multiElement) {
        // save a copy
        List<Element> children = new List.from(includedElement.children);

        parent.children..removeAt(index);
        for (Element child in children) {
          parent.children..insert(index++, child);
        }
      }
      return element;
    }

    Future<Element> _handleMetaYachtInclude(Element element) async {
      if (element.attributes['property'] == 'yacht-include') {
        String src = element.attributes['content'];
        return await _handleYachtInclude(element, src);
      }
      return element;
    }

    Future<Element> _handleElementYachtInclude(Element element) async {
      String src = element.attributes['src'];
      return await _handleYachtInclude(element, src);
    }

    await _handleTag('meta', _handleMetaYachtInclude);
    await _handleTag('yacht-include', _handleElementYachtInclude);
  }
}

class _HtmlTransform {
  Transform transform;
  Document document;
}

class _CssTransform {
  Transform transform;
  bool hasImport;
  AssetId assetId;
  StyleSheet styleSheet;
  _CssTransform(this.transform);

  // list of imported css to remove
  List<String> imported = [];
  // resulting css inputs
  List<String> css = [];
}

class YachtTransformOption {
  bool get isDebug => _debug == true;
  bool get isRelease => !isDebug;

  bool get isImport {
    if (isSettingRelease(_import)) {
      return isRelease;
    } else if (isSettingFalse(_import)) {
      return false;
    } else if (isSettingDebug(_import)) {
      return isDebug;
    }
    // default is to import
    return true;
  }

  /// List of ignored files
  final List<String> ignored = [];

  bool _debug;

  // for test
  set debug(bool debug) => _debug = debug;

  // can be true/false/debug/release
  set import(var import) => _import = import;
  var _import;
  YachtTransformOption.fromBarbackSettings(BarbackSettings settings) {
    if (settings != null) {
      _debug = settings.mode != BarbackMode.RELEASE;
      _import = settings.configuration['import'];
      List<String> _ignored = settings.configuration['ignore'];
      if (_ignored != null) {
        for (String path in _ignored) {
          path = normalize(path);
          ignored.add(path);
        }
      }
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
