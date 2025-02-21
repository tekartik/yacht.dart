import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_html/html.dart';

/// copy element attributes
void copyElementAttributes(Element srcElement, Element trgElement) {
  trgElement.attributes.addAll(srcElement.attributes);
}

/// Replace all nodes
void replaceElementNodes(Element srcElement, Element trgElement) {
  trgElement.children.clear();
  for (var item in List.of(srcElement.childNodes)) {
    trgElement.append(item);
  }
}

/*
String getAndRemoveElementAttribute(Element element, String attribute) {
  return element.attributes.remove(attribute);
}
*/

bool checkAndRemoveElementAttribute(Element element, String attribute) =>
    checkAndRemoveAttribute(element.attributes, attribute);

bool checkAndRemoveAttribute(Map attributes, String attribute) {
  var has = attributes.containsKey(attribute);
  attributes.remove(attribute);
  return has;
}

extension HtmlProviderNoScriptExt on HtmlProvider {
  void noScriptFix(Element element, {bool? verbose}) {
    // Bug in current
    // noscript is interpreted as text!
    // try to find if it looks like html
    if (element.tagName == 'noscript') {
      var children = element.childNodes;
      if (children.length == 1 && children.first is Text) {
        var firstChild = children.first as Text;
        // try to parse html
        try {
          var child = createElementHtml(firstChild.textContent!);
          element.replaceChild(child, firstChild);
        } catch (e, st) {
          verbose ??= isDebug;
          if (verbose) {
            // ignore: avoid_print
            print('noScriptFix: $e');
            // ignore: avoid_print
            print(st);
          }
        }
      }
    }
  }
}

void noScriptFix(Element element) {
  element.htmlProvider.noScriptFix(element);
}
