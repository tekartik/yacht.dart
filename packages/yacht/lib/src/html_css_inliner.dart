import 'dart:async';

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_html/html.dart';
import 'package:tekartik_yacht/src/html_printer_common.dart';
export 'html_css_inliner_html5lib.dart' show fixCssInline;

typedef HtmlCssHrefInlinerFunction = Future<String?> Function(String href);

/// Css inliner
class HtmlCssInliner {
  final HtmlCssHrefInlinerFunction inliner;
  final HtmlProvider htmlProvider;

  HtmlCssInliner({required this.htmlProvider, required this.inliner});
  Future<String> build(String source) async {
    var doc = htmlProvider.createDocument(html: source);
    var elements = doc.html.queryAll(byClass: 'yacht-inline');
    for (var element in List.of(elements)) {
      //element.replaceWith(otherNode)
      if (element.tagName == 'link') {
        var cssPath = element.attributes['href'];
        if (cssPath != null) {
          var css = await inliner(cssPath);
          if (css == null) {
            if (isDebug) {
              // ignore: avoid_print
              print('Css not found: $cssPath');
            }
            continue;
          }
          var styleElement = htmlProvider.createElementTag('style');
          // Copy attributes but href, rel and type
          element.attributes.forEach((key, value) {
            if (key != 'href' &&
                key != 'rel' &&
                key != 'type' &&
                key != 'class') {
              styleElement.attributes[key] = value;
            }
          });
          if (css.contains('\n')) {
            styleElement.text = '\n$css';
          } else {
            styleElement.text = css;
          }
          element.replaceWith(styleElement);
        }
      }
    }

    var html = htmlPrintDocument(doc);
    return html;
  }
}
