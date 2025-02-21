library;

//import 'visitor.dart' as visitor;
import 'package:tekartik_html/html.dart';

import 'visitor.dart' show Visitor;

abstract class HtmlVisitorBase implements Visitor<Node> {
  Node visitChildren(Node node) {
    if (node is Element && node.childNodes.isNotEmpty) {
      var nodeList = node.childNodes;
      for (var node in nodeList) {
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
    void doVisitElement(Element? element) {
      if (element != null) {
        visitElement(element);
      }
    }

    doVisitElement(document.html);
    return document;
  }

  @override
  Node visit(node) => node;
}
