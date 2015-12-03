library yacht_transformer.test.html_visitor_test;

import 'package:dev_test/test.dart';
import 'package:yacht_transformer/src/html_printer.dart';
import 'package:html/dom.dart';

HtmlLines htmlLines(List data) {
  HtmlLines lines = new HtmlLines();
  _addItem(List item) {
    lines.add(htmlLine(item[0], item[1]));
  }
  if (data.isNotEmpty) {
    // not a list, might be a line data [0, "test"] directly
    if (data.first is List) {
      for (var item in data) {
        _addItem(item);
      }
    } else {
      _addItem(data);
    }
  }

  return lines;
}

main() {
  group('html_line', () {
    test('equals', () {
      HtmlLine line1 = htmlLine(null, null);
      HtmlLine line2 = htmlLine(null, null);
      expect(line1, line1);
      expect(line1, line2);
      expect(line1.hashCode, line2.hashCode);
      line2 = htmlLine(1, null);
      expect(line1.hashCode, isNot(line2.hashCode));
      expect(line1, isNot(line2));
      line2 = htmlLine(null, "test");
      expect(line1, isNot(line2));
      expect(line1.hashCode, isNot(line2.hashCode));

      line1 = htmlLine(1, "test");
      line2 = htmlLine(1, "test");
      expect(line1, line2);
      expect(line1.hashCode, line2.hashCode);
    });
  });

  group('html_lines', () {
    test('build', () {
      HtmlLines lines = htmlLines([
        [0, "test"],
        [1, "sub"]
      ]);
      expect(lines[0], htmlLine(0, "test"));
      expect(lines[1], htmlLine(1, "sub"));
      expect(lines.length, 2);
    });
    test('equals', () {
      HtmlLines lines1 = htmlLines([
        [0, "test"]
      ]);

      HtmlLines lines2 = htmlLines([0, "test"]);
      expect(lines1, lines2);
      lines2 = htmlLines([1, "sub"]);
      expect(lines1, isNot(lines2));
    });
  });
  group('html_printer', () {
    test('empty', () {
      HtmlElementPrinter printer = new HtmlElementPrinter();
      expect(printer.lines, isEmpty);
    });

    test('element', () async {
      Element element = new Element.html('<a>link</a>');
      expect(element.outerHtml, '<a>link</a>');
      HtmlElementPrinter printer = new HtmlElementPrinter();
      await printer.visitElement(element);
      expect(
          printer.lines,
          htmlLines([
            [0, '<a>'],
            [1, 'link'],
            [0, '</a>']
          ]));
    });

    test('document', () async {
      Document document = new Document();
      expect(document.outerHtml, '');
      HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
      await printer.visitDocument(document);
      //print(printer.lines);
      expect(printer.lines, htmlLines([]));
    });

    test('document_html_empty', () async {
      Document document = new Document.html('');
      expect(document.outerHtml, '<html><head></head><body></body></html>');

      //print(document.outerHtml);
      HtmlDocumentPrinter builder = new HtmlDocumentPrinter();
      await builder.visitDocument(document);
      expect(
          builder.lines,
          htmlLines([
            [0, '<html>'],
            [1, '<head>'],
            [1, '</head>'],
            [1, '<body>'],
            [1, '</body>'],
            [0, '</html>']
          ]));
      //print(builder.nodes);
    });

    test('document_html_basic', () async {
      Document document = new Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>');

      //print(document.outerHtml);
      HtmlDocumentPrinter builder = new HtmlDocumentPrinter();
      await builder.visitDocument(document);
      expect(
          builder.lines,
          htmlLines([
            [0, '<html>'],
            [1, '<head>'],
            [1, '</head>'],
            [1, '<body>'],
            [1, '</body>'],
            [0, '</html>']
          ]));
      //print(builder.nodes);
    });
  });

  group('utils', () {
    test('htmlPrintLines', () {
      expect(htmlPrintLines(htmlLines([])), '${htmlDoctype}\n');
      expect(
          htmlPrintLines(htmlLines([0, '<html/>'])), '${htmlDoctype}\n<html/>');
      expect(
          htmlPrintLines(htmlLines([1, '<html/>'])), '${htmlDoctype}\n<html/>');
      expect(htmlPrintLines(htmlLines([2, '<html/>'])),
          '${htmlDoctype}\n  <html/>');
    });

    test('htmlPrintDocument', () async {
      Document document = new Document();
      expect(await htmlPrintDocument(document), '${htmlDoctype}\n');
      document = new Document.html('');
      expect(await htmlPrintDocument(document),
          '${htmlDoctype}\n<html>\n<head>\n</head>\n<body>\n</body>\n</html>');
      document = new Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>');
      expect(await htmlPrintDocument(document),
          '${htmlDoctype}\n<html>\n<head>\n</head>\n<body>\n</body>\n</html>');
      //document = new Document.html('<!DOCTYPE html><html><head></head><body></body></html>\n');
      //expect(await htmlPrintDocument(document), '${htmlDoctype}\n<html>\n<head>\n</head>\n<body>\n</body>\n</html>\n');
      /*
      expect(htmlPrintLines(htmlLines([0, '<html/>'])),
          '${htmlDoctype}\n<html/>\n');
      expect(htmlPrintLines(htmlLines([1, '<html/>'])),
          '${htmlDoctype}\n<html/>\n');
      expect(htmlPrintLines(htmlLines([2, '<html/>'])),
          '${htmlDoctype}\n  <html/>\n');
          */
    });
  });
}
