library yacht.src.html_visitor;

//import 'visitor.dart' as visitor;
import 'visitor.dart' show Visitor, VisitorAsync;
import 'package:html/dom.dart';

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
  visitElement(Element element) => visit(element);
}

class HtmlDocumentVisitor extends HtmlElementVisitor {
  HtmlDocumentVisitor();

  // public API to call
  Document visitDocument(Document document) {
    _visitElement(Element element) {
      if (element != null) {
        visitElement(element);
      }
    }

    _visitElement(document.documentElement);
    return document;
  }

  @override
  visit(node) async => node;
}
