library yacht_transformer.test.html_visitor_test;

import 'package:dev_test/test.dart';
import 'package:yacht_transformer/src/html_printer.dart';
import 'package:html/dom.dart';

main() {
  group('html_visitor', () {
    test('empty', () {
      HtmlElementNodeLinesBuilder builder = new HtmlElementNodeLinesBuilder();
      expect(builder.lines, isEmpty);
    });
    test('element', () async {
      Element element = new Element.html('<a>link</a>');
      HtmlElementNodeLinesBuilder builder = new HtmlElementNodeLinesBuilder();
      await builder.visitElement(element);
      expect(builder.lines, hasLength(2));
      expect(builder.lines[0].node, new isInstanceOf<Element>());
      expect(builder.lines[0].depth, 0);
      expect(builder.lines[1].node, isNot(new isInstanceOf<Element>()));
      expect(builder.lines[1].node.nodeType, Node.TEXT_NODE);
      expect(builder.lines[1].depth, 1);
    });
    test('document', () async {
      Document document = new Document();
      HtmlDocumentNodeLinesPrinter builder = new HtmlDocumentNodeLinesPrinter();
      await builder.visitDocument(document);
      expect(builder.lines, isEmpty);
    });

    test('document_html_empty', () async {
      Document document = new Document.html('');
      HtmlDocumentNodeLinesPrinter builder = new HtmlDocumentNodeLinesPrinter();
      await builder.visitDocument(document);
      expect(builder.lines, hasLength(3));
      expect((builder.lines[0].node as Element).localName, 'html');
      expect(builder.lines[0].depth, 0);
      expect((builder.lines[1].node as Element).localName, 'head');
      expect(builder.lines[1].depth, 1);
      expect((builder.lines[2].node as Element).localName, 'body');
      expect(builder.lines[2].depth, 1);
      //print(builder.nodes);
    });

    test('document_html_basic', () async {
      Document document = new Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>');
      HtmlDocumentNodeLinesPrinter builder = new HtmlDocumentNodeLinesPrinter();
      await builder.visitDocument(document);
      expect(builder.lines, hasLength(3));
      expect((builder.lines[0].node as Element).localName, 'html');
      expect(builder.lines[0].depth, 0);
      expect((builder.lines[1].node as Element).localName, 'head');
      expect(builder.lines[1].depth, 1);
      expect((builder.lines[2].node as Element).localName, 'body');
      expect(builder.lines[2].depth, 1);
      //print(builder.nodes);
    });

    test('document_html_basic_new_line', () async {
      // somehow the last new line was get converted to body...
      Document document = new Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>\n');
      HtmlDocumentNodeLinesPrinter builder = new HtmlDocumentNodeLinesPrinter();
      await builder.visitDocument(document);
      //print(builder.lines);
      //print(builder.lines[3].node.nodeType);
      expect((builder.lines[0].node as Element).localName, 'html');
      expect(builder.lines[0].depth, 0);
      expect((builder.lines[1].node as Element).localName, 'head');
      expect(builder.lines[1].depth, 1);
      expect((builder.lines[2].node as Element).localName, 'body');
      expect(builder.lines[2].depth, 1);
      expect(builder.lines[3].node.nodeType, Node.TEXT_NODE);
      expect(builder.lines[3].node.text, '\n');
      //
    });
  });
}
