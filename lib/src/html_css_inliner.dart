import 'dart:async';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:path/path.dart';
import 'package:yacht/src/html_printer.dart';

Future fixCssInline(String srcHtmlFilePath, String dstHtmlFilePath) async {
  var file = File(srcHtmlFilePath);
  var html = await file.readAsString();
  var doc = Document.html(html);
  var elements = doc.querySelectorAll('.yacht-inline');
  for (var element in elements) {
    //element.replaceWith(otherNode)
    if (element.localName == 'link') {
      var cssPath = element.attributes['href'];
      cssPath = normalize(join(dirname(srcHtmlFilePath), cssPath));
      var css = await File(cssPath).readAsString();
      var styleElement = Element.tag('style');
      // Copy attributes but href, rel and type
      element.attributes.forEach((key, value) {
        if (key != 'href' && key != 'rel' && key != 'type' && key != 'class') {
          styleElement.attributes[key] = value;
        }
      });
      if (css.contains('\n')) {
        styleElement.text = '\n${css}';
      } else {
        styleElement.text = '${css}';
      }
      element.replaceWith(styleElement);
    }
  }

  html = htmlPrintDocument(doc);
  await File(dstHtmlFilePath).writeAsString(html);
}
