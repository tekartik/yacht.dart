library;

//import 'visitor.dart' as visitor;
import 'package:tekartik_html/html.dart';

import 'visitor.dart' show Visitor;

/// Base class for HTML visitors.
abstract class HtmlVisitorBase implements Visitor<Node> {
  /// Visit children of a node.
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

/// HTML element visitor.
abstract class HtmlElementVisitor extends HtmlVisitorBase {
  /// Create an HTML element visitor.
  HtmlElementVisitor();

  // public API to call
  /// Visit an element.
  Node visitElement(Element element) => visit(element);
}

/// HTML document visitor.
class HtmlDocumentVisitor extends HtmlElementVisitor {
  /// Create an HTML document visitor.
  HtmlDocumentVisitor();

  // public API to call
  /// Visit a document.
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
