import 'package:html/dom.dart';
import 'package:tekartik_common_utils/env_utils.dart';

/// copy element attributes
void copyElementAttributes(Element srcElement, Element trgElement) {
  trgElement.attributes.addAll(srcElement.attributes);
}

/// Replace all nodes
void replaceElementNodes(Element srcElement, Element trgElement) {
  trgElement.nodes.clear();
  trgElement.nodes.addAll(srcElement.nodes);
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

void noScriptFix(Element element) {
  // Bug in current
  // noscript is interpreted as text!
  // try to find if it looks like html
  if (element.localName == 'noscript') {
    if (element.nodes.length == 1 &&
        element.nodes.first.nodeType == Node.TEXT_NODE) {
      // try to parse html
      try {
        var child = Element.html(element.nodes.first.text!);
        element.nodes
          ..removeAt(0)
          ..insert(0, child);
        // print(element.nodes);
      } catch (e) {
        if (isDebug) {
          // print('html5lib noScriptFix: $e');
        }
      }
    }
  }
}
