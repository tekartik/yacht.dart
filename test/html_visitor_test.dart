library yacht_transformer.test.html_visitor_test;

import 'package:dev_test/test.dart';
import 'package:yacht_transformer/src/html_visitor.dart';
import 'package:html/dom.dart';
import 'dart:async';

abstract class NodeListBuilderMixin {
  List<Node> nodes = [];

  // implemented by BaseVisitor
  Future<Node> visitChildren(Node node);

  // @override
  Future<Node> visit(Node node) async {
    nodes.add(node);
    return visitChildren(node);
  }
}

class HtmlElementNodeListBuilder extends HtmlElementVisitor
    with NodeListBuilderMixin {}

class HtmlDocumentNodeListBuilder extends HtmlDocumentVisitor
    with NodeListBuilderMixin {}

main() {
  group('html_visitor', () {
    test('empty', () {
      HtmlElementNodeListBuilder builder = new HtmlElementNodeListBuilder();
      expect(builder.nodes, isEmpty);
    });
    test('element', () async {
      Element element = new Element.html('<a>link</a>');
      HtmlElementNodeListBuilder builder = new HtmlElementNodeListBuilder();
      await builder.visitElement(element);
      expect(builder.nodes, hasLength(2));
      expect(builder.nodes[0], new isInstanceOf<Element>());
      expect(builder.nodes[1], isNot(new isInstanceOf<Element>()));
    });
    test('document', () async {
      Document document = new Document();
      HtmlDocumentNodeListBuilder builder = new HtmlDocumentNodeListBuilder();
      await builder.visitDocument(document);
      //print(builder.nodes);
    });

    test('document_html', () async {
      Document document = new Document.html('');
      HtmlDocumentNodeListBuilder builder = new HtmlDocumentNodeListBuilder();
      await builder.visitDocument(document);
      expect(builder.nodes, hasLength(3));
      expect((builder.nodes[0] as Element).localName, 'html');
      expect((builder.nodes[1] as Element).localName, 'head');
      expect((builder.nodes[2] as Element).localName, 'body');
      //print(builder.nodes);
    });
  });
}
