import 'package:yacht/src/html_printer.dart';
import 'package:html/dom.dart';
import 'test_common.dart';

void main() {
  group('html_visitor', () {
    test('empty', () {
      var builder = HtmlElementNodeLinesBuilder();
      expect(builder.lines, isEmpty);
    });

    group('element', () {
      test('element', () async {
        var element = Element.html('<a>link</a>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(element.text, 'link');
        expect(element.innerHtml, 'link');
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, const TypeMatcher<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, isNot(const TypeMatcher<Element>()));
        expect(builder.lines[1].node.nodeType, Node.TEXT_NODE);
        expect(builder.lines[1].depth, 1);
      });

      test('element_with_innner', () {
        var element = Element.html('<div><a></a></div>');
        expect(element.text, '');
        expect(element.nodes.first.text, '');
        expect(element.innerHtml, '<a></a>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      test('element_with_innner_2', () {
        var element = Element.html('<div>1<a>2</a>3</div>');
        expect(element.text, '123');
        expect(element.nodes.first.text, '1');
        expect(element.innerHtml, '1<a>2</a>3');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      test('element_with_html_text_node', () {
        var element = Element.tag('div');
        element.text = '&lt;a&gt;&lt;/a&gt;';
        expect(element.text, '&lt;a&gt;&lt;/a&gt;');
        expect(element.nodes.first.text, '&lt;a&gt;&lt;/a&gt;');
        //devPrint(element.innerHtml);
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      // NO
      test('element_with_inner_html', () {
        var element = Element.tag('div');
        element.innerHtml = '&lt;a&gt;&lt;/a&gt;';

        expect(element.text, '<a></a>');
        expect(element.nodes.first.text, '<a></a>');
        expect(element.innerHtml, '&lt;a&gt;&lt;/a&gt;');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      // NO
      test('parse_element_with_html_text_node', () {
        var element = Element.html('<div>&lt;a&gt;&lt;/a&gt;</div>');
        expect(element.text, '<a></a>');
        expect(element.nodes.first.text, '<a></a>');
        expect(element.innerHtml, '&lt;a&gt;&lt;/a&gt;');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //expect(builder.lines, htmlLines([]));
      });

      test('element_with_head', () async {
        var element = Element.html('<div><head>link</head></div>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, const TypeMatcher<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, isNot(const TypeMatcher<Element>()));
        expect(builder.lines[1].node.nodeType, Node.TEXT_NODE);
        expect(builder.lines[1].depth, 1);
      });

      test('head_element', () async {
        // The first meta is recognized
        // Remaining is ignored
        var element = Element.html('<head><meta><div></div><meta></head>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, const TypeMatcher<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, const TypeMatcher<Element>());
        expect(builder.lines[1].depth, 1);
      });
    });

    group('document', () {
      test('document', () async {
        var document = Document();
        var builder = HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        expect(builder.lines, isEmpty);
      });

      test('document_html_empty', () async {
        var document = Document.html('');
        var builder = HtmlDocumentNodeLinesPrinter();
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
        var document = Document.html(
            '<!DOCTYPE html><html><head></head><body></body></html>');
        var builder = HtmlDocumentNodeLinesPrinter();
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
        var document = Document.html(
            '<!DOCTYPE html><html><head></head><body></body></html>\n');
        var builder = HtmlDocumentNodeLinesPrinter();
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
        var document = Document.html(
            '<!DOCTYPE html><html><head><my-tag></my-tag></head><body></body></html>\n');
        var builder = HtmlDocumentNodeLinesPrinter();
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
