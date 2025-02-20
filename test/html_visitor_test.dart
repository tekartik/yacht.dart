import 'package:tekartik_html/html_universal.dart';
import 'package:yacht/src/html_printer_common.dart';

import 'test_common.dart';

void main() {
  groupVisitor(htmlProviderUniversal);
}

void groupVisitor(HtmlProvider htmlProvider) {
  group('html_visitor', () {
    test('empty', () {
      var builder = HtmlElementNodeLinesBuilder();
      expect(builder.lines, isEmpty);
    });

    group('node', () {
      test('text', () {
        var element = htmlProvider.createElementHtml('<div>T</div>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(builder.lines, hasLength(2));
        var index = 0;
        var line = builder.lines[index++];
        expect(line.node.nodeType, Node.elementNode);
        expect(line.element.tagName, 'div');
        line = builder.lines[index++];
        expect(line.textNode.nodeType, Node.textNode);
        expect(line.textNode.text, 'T');
      });
    });
    group('element', () {
      test('element', () async {
        var element = htmlProvider.createElementHtml('<a>link</a>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(element.textContent, 'link');
        expect(element.innerHtml, 'link');
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, const TypeMatcher<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, isNot(const TypeMatcher<Element>()));
        expect(builder.lines[1].node.nodeType, Node.textNode);
        expect(builder.lines[1].depth, 1);
      });

      test('element_with_innner', () {
        var element = htmlProvider.createElementHtml('<div><a></a></div>');
        expect(element.textContent, '');
        expect(element.childNodes.first.textContent, '');
        expect(element.innerHtml, '<a></a>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      test('element with children', () {
        var element1 =
            htmlProvider.createElementHtml('<ul><li></li><li></li></ul>');
        var element2 =
            htmlProvider.createElementHtml('<ul>\n<li></li>\n<li></li>\n</ul>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element1);
        builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element2);
      });

      test('element_with_innner_2', () {
        var element = htmlProvider.createElementHtml('<div>1<a>2</a>3</div>');
        expect(element.textContent, '123');
        expect(element.childNodes.first.textContent, '1');
        expect(element.innerHtml, '1<a>2</a>3');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      test('element_with_html_text_node', () {
        var element = htmlProvider.createElementTag('div');
        element.text = '&lt;a&gt;&lt;/a&gt;';
        expect(element.textContent, '&lt;a&gt;&lt;/a&gt;');
        expect(element.childNodes.first.textContent, '&lt;a&gt;&lt;/a&gt;');
        //devPrint(element.innerHtml);
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      // NO
      test('element_with_inner_html', () {
        var element = htmlProvider.createElementTag('div');
        element.innerHtml = '&lt;a&gt;&lt;/a&gt;';

        expect(element.textContent, '<a></a>');
        expect(element.childNodes.first.textContent, '<a></a>');
        expect(element.innerHtml, '&lt;a&gt;&lt;/a&gt;');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //devPrint(builder.lines);
      });

      // NO
      test('parse_element_with_html_text_node', () {
        var element =
            htmlProvider.createElementHtml('<div>&lt;a&gt;&lt;/a&gt;</div>');
        expect(element.textContent, '<a></a>');
        expect(element.childNodes.first.textContent, '<a></a>');
        expect(element.innerHtml, '&lt;a&gt;&lt;/a&gt;');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        //expect(builder.lines, htmlLines([]));
      });

      test('element_with_head', () async {
        var element =
            htmlProvider.createElementHtml('<div><head>link</head></div>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        expect(builder.lines, hasLength(2));
        expect(builder.lines[0].node, const TypeMatcher<Element>());
        expect(builder.lines[0].depth, 0);
        expect(builder.lines[1].node, isNot(const TypeMatcher<Element>()));
        expect(builder.lines[1].node.nodeType, Node.textNode);
        expect(builder.lines[1].depth, 1);
      });

      test('head_element', () async {
        // The first meta is recognized
        // Remaining is ignored
        var element = htmlProvider
            .createElementHtml('<head><meta><div></div><meta></head>');
        var builder = HtmlElementNodeLinesBuilder();
        builder.visitElement(element);
        var node = builder.lines[0].node as Element;
        expect(builder.lines[0].depth, 0);
        if (htmlProvider is HtmlProviderWeb) {
          expect(builder.lines, hasLength(1));

          expect(node.tagName, 'meta');
        } else {
          expect(builder.lines, hasLength(2));
          expect(node.tagName, 'head');
          var node2 = builder.lines[1].node as Element;
          expect(node2.tagName, 'meta');
          expect(builder.lines[1].depth, 1);
        }
      });
    });

    group('document', () {
      test('document', () async {
        var document = htmlProvider.createDocument();
        var builder = HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        if (htmlProvider is HtmlProviderHtml5Lib) {
          expect(builder.lines.length, 6);
        } else if (htmlProvider is HtmlProviderWeb) {
          expect(builder.lines.length, 5);
        } else {
          throw UnimplementedError();
        }
      });

      test('document_html_empty', () async {
        var document = htmlProvider.createDocument(html: '');
        var builder = HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        expect((builder.lines[0].node as Element).tagName, 'html');
        expect(builder.lines[0].depth, 0);
        expect((builder.lines[1].node as Element).tagName, 'head');
        expect(builder.lines[1].depth, 1);
        if (htmlProvider is HtmlProviderHtml5Lib) {
          expect(builder.lines, hasLength(6));

          expect((builder.lines[5].node as Element).tagName, 'body');
          expect(builder.lines[5].depth, 1);
        } else if (htmlProvider is HtmlProviderWeb) {
          expect(builder.lines.length, 5);
        } else {
          throw UnimplementedError();
        }
      });

      test('document_html_basic', () async {
        var document = htmlProvider.createDocument(
            html: '<!DOCTYPE html><html><head></head><body></body></html>');
        var builder = HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        // builder.debugDump();
        // Html5lib
        // <html html>
        //   <html head>
        //     <html meta>
        //     <html title>
        //       Text()
        //   <html body>
        // Web
        // [object HTMLHtmlElement]
        //   [object HTMLHeadElement]
        //     [object HTMLMetaElement]
        //     [object HTMLTitleElement]
        //   [object HTMLBodyElement]
        var size = (htmlProvider is HtmlProviderWeb) ? 5 : 6;
        expect(builder.lines.length, size);
        expect((builder.lines[0].node as Element).tagName, 'html');
        expect(builder.lines[0].depth, 0);
        expect((builder.lines[1].node as Element).tagName, 'head');
        expect(builder.lines[1].depth, 1);
        expect((builder.lines[size - 1].node as Element).tagName, 'body');
        expect(builder.lines[size - 1].depth, 1);
        //print(builder.nodes);
      });

      test('document_html_basic_new_line', () async {
        // somehow the last new line was get converted to body...
        var document = htmlProvider.createDocument(
            html: '<!DOCTYPE html><html><head></head><body></body></html>\n');
        var builder = HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        // print(builder.lines);
        //print(builder.lines[3].node.nodeType);
        expect((builder.lines[0].node as Element).tagName, 'html');
        expect(builder.lines[0].depth, 0);
        expect((builder.lines[1].node as Element).tagName, 'head');
        expect(builder.lines[1].depth, 1);

        // builder.debugDump();
        // Web:
        // [object HTMLHtmlElement]
        //   [object HTMLHeadElement]
        //     [object HTMLMetaElement]
        //     [object HTMLTitleElement]
        //   [object HTMLBodyElement]
        //     Text(
        // )
        // Html5lib
        // <html html>
        //   <html head>
        //     <html meta>
        //     <html title>
        //       Text()
        //   <html body>
        //     Text(
        // )
        var index = (htmlProvider is HtmlProviderWeb) ? 5 : 6;
        var line = builder.lines[index];
        //expect((builder.lines[5].node as Text).textContent, 'body');
        //expect(builder.lines[5].depth, 1);
        var node = line.node as Text;
        expect(node.nodeType, Node.textNode);
        expect(node.textContent, '\n');
        expect(line.depth, 2);

        //
      });

      test('document_html_tag_in_head', () async {
        // somehow the tag in head is moved to body
        var document = htmlProvider.createDocument(
            html:
                '<!DOCTYPE html><html><head><my-tag></my-tag></head><body></body></html>\n');
        var builder = HtmlDocumentNodeLinesPrinter();
        builder.visitDocument(document);
        //builder.debugDump();

        //print(builder.lines);
        //print(builder.lines[3].node.nodeType);
        expect((builder.lines[0].node as Element).tagName, 'html');
        expect(builder.lines[0].depth, 0);
        expect((builder.lines[1].node as Element).tagName, 'head');
        expect(builder.lines[1].depth, 1);
        Element bodyNode;
        var index = (htmlProvider is HtmlProviderWeb) ? 4 : 5;
        var line = builder.lines[index];

        bodyNode = (line.node as Element);
        expect(bodyNode.tagName, 'body');
        expect(line.depth, 1);
        // head tag move here
        index++;
        line = builder.lines[index];
        var tagElement = (line.node as Element);
        expect(tagElement.tagName, 'my-tag');
        expect(line.depth, 2);
        index++;
        line = builder.lines[index];
        var textNode = (line.node as Text);
        expect(textNode.nodeType, Node.textNode);
        expect(textNode.textContent, '\n');
        expect(line.depth, 2);
        //
      });
    });
  });
}
