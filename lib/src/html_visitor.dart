library yacht.src.html_visitor;

//import 'visitor.dart' as visitor;
import 'package:html/dom.dart';

import 'visitor.dart' show Visitor;

abstract class HtmlVisitorBase implements Visitor<Node> {
  Node visitChildren(Node node) {
    if (node.hasChildNodes()) {
      NodeList nodeList = node.nodes;
      for (Node node in nodeList) {
        visit(node);
      }
    }
    return node;
  }
}

abstract class HtmlElementVisitor extends HtmlVisitorBase {
  HtmlElementVisitor();

  // public API to call
  Node visitElement(Element element) => visit(element);
}

class HtmlDocumentVisitor extends HtmlElementVisitor {
  HtmlDocumentVisitor();

  // public API to call
  Document visitDocument(Document document) {
    void _visitElement(Element element) {
      if (element != null) {
        visitElement(element);
      }
    }

    _visitElement(document.documentElement);
    return document;
  }

  @override
  Node visit(node) => node;
}
