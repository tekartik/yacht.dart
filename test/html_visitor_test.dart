library yacht.test.html_visitor_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/html_printer.dart';
import 'package:html/dom.dart';

main() {
  group('html_visitor', () {
    test('empty', () {
      HtmlElementNodeLinesBuilder builder = new HtmlElementNodeLinesBuilder();
      expect(builder.lines, isEmpty);
    });

    group('element', () {
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

      test('element_with_head', () async {
        Element element = new Element.html('<div><head>link</head></div>');
        HtmlElementNodeLinesBuilder builder = new HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, new isInstanceOf<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, isNot(new isInstanceOf<Element>()));
        expect(builder.lines[1].node.nodeType, Node.TEXT_NODE);
        expect(builder.lines[1].depth, 1);
      });

      test('head_element', () async {
        // The first meta is recognized
        // Remaining is ignored
        Element element =
            new Element.html('<head><meta><div></div><meta></head>');
        HtmlElementNodeLinesBuilder builder = new HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, new isInstanceOf<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, new isInstanceOf<Element>());
        ;
        expect(builder.lines[1].depth, 1);
      });
    });

    group('document', () {
      test('document', () async {
        Document document = new Document();
        HtmlDocumentNodeLinesPrinter builder =
            new HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        expect(builder.lines, isEmpty);
      });

      test('document_html_empty', () async {
        Document document = new Document.html('');
        HtmlDocumentNodeLinesPrinter builder =
            new HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
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
        HtmlDocumentNodeLinesPrinter builder =
            new HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
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
        HtmlDocumentNodeLinesPrinter builder =
            new HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
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
        expect(builder.lines[3].depth, 2);
        //
      });

      test('document_html_tag_in_head', () async {
        // somehow the tag in head is moved to body
        Document document = new Document.html(
            '<!DOCTYPE html><html><head><my-tag></my-tag></head><body></body></html>\n');
        HtmlDocumentNodeLinesPrinter builder =
            new HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        //print(builder.lines);
        //print(builder.lines[3].node.nodeType);
        expect((builder.lines[0].node as Element).localName, 'html');
        expect(builder.lines[0].depth, 0);
        expect((builder.lines[1].node as Element).localName, 'head');
        expect(builder.lines[1].depth, 1);
        expect((builder.lines[2].node as Element).localName, 'body');
        expect(builder.lines[2].depth, 1);
        // head tag move here
        expect((builder.lines[3].node as Element).localName, 'my-tag');
        expect(builder.lines[3].depth, 2);
        expect(builder.lines[4].node.nodeType, Node.TEXT_NODE);
        expect(builder.lines[4].node.text, '\n');
        expect(builder.lines[4].depth, 2);
        //
      });
    });
  });
}
