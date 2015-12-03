library yacht_transformer.src.html_visitor;

//import 'visitor.dart' as visitor;
import 'visitor.dart' show Visitor, VisitorAsync;
import 'package:html/dom.dart';
import 'dart:async';

abstract class HtmlVisitorBase implements VisitorAsync<Node> {
  Future<Node> visitChildren(Node node) async {
    if (node.hasChildNodes()) {
      NodeList nodeList = node.nodes;
      for (Node node in nodeList) {
        await visit(node);
      }
    }
    return node;
  }
}

abstract class HtmlElementVisitor extends HtmlVisitorBase {
  HtmlElementVisitor();

  // public API to call
  visitElement(Element element) => visit(element);

  /*
  /// must call base to go deeper
  @override
  Future<Node> visit(Node node) async {
    if (node.hasChildNodes()) {
      NodeList nodeList = node.nodes;
      for (Node node in nodeList) {
        await visit(node);
      }
    }
    return node;
  }
  */

}

class HtmlDocumentVisitor extends HtmlElementVisitor {
  HtmlDocumentVisitor();

  // public API to call
  Future<Document> visitDocument(Document document) async {
    _visitElement(Element element) async {
      if (element != null) {
        await visitElement(element);
      }
    }

    await _visitElement(document.documentElement);
    return document;
  }

  @override
  visit(node) async => node;
}
