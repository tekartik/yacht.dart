import 'dart:async';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:path/path.dart';
import 'package:yacht/src/html_printer.dart';

Future fixCssInline(String srcHtmlFilePath, String dstHtmlFilePath) async {
  File file = new File(srcHtmlFilePath);
  String html = await file.readAsString();
  Document doc = new Document.html(html);
  List<Element> elements = doc.querySelectorAll(".yacht-inline");
  for (var element in elements) {
    //element.replaceWith(otherNode)
    if (element.localName == "link") {
      String cssPath = element.attributes['href'];
      cssPath = normalize(join(dirname(srcHtmlFilePath), cssPath));
      String css = await new File(cssPath).readAsString();
      var styleElement = new Element.tag("style");
      // Copy attributes but href, rel and type
      element.attributes.forEach((key, value) {
        if (key != 'href' && key != 'rel' && key != 'type' && key != 'class') {
          styleElement.attributes[key] = value;
        }
      });
      if (css.contains('\n')) {
        styleElement.text = "\n${css}";
      } else {
        styleElement.text = "${css}";
      }
      element.replaceWith(styleElement);
    }
  }

  html = await htmlPrintDocument(doc);
  await new File(dstHtmlFilePath).writeAsString(html);
}
