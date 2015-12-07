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
