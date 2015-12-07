library yacht.src.html_tag_utils.dart;

import 'package:html/dom.dart';

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
  bool has = attributes.containsKey(attribute);
  attributes.remove(attribute);
  return has;
}
