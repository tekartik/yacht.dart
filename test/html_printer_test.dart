library yacht.test.html_visitor_test;

import 'package:dev_test/test.dart';
import 'package:yacht/src/html_printer.dart';
import 'package:html/dom.dart';
import 'dart:async';

const String minHtml = '''
<!doctype html>
<html>
<head></head>
<body></body>
</html>''';
const String minInHtml =
    '<!doctype html><html><head></head><body></body></html>';

// Allow for [0,'<a>'] or ['</a>'] or '<a>'
_addItem(HtmlLines lines, dynamic item) {
  int depth = 0;
  String content;
  if (item is List) {
    int index = 0;
    if (item.length > 1) {
      depth = item[index++];
    }
    content = item[index++];
  } else {
    content = item;
  }
  lines.add(htmlLine(depth, content));
}

@deprecated // use htmlLines
HtmlLines htmlMultiHtmlLines(List data) {
  HtmlLines lines = new HtmlLines();
  for (var item in data) {
    _addItem(lines, item);
  }
  return lines;
}

Future<HtmlLines> htmlLinesFromElementHtml(String html) async {
  Element element = new Element.html(html);
  //print(element.outerHtml');
  HtmlElementPrinter printer = new HtmlElementPrinter();
  await printer.visitElement(element);
  return printer.lines;
}
// Allow for [[0,'<a>'],[0,'</a']]
// ['<a>', '</a>']

HtmlLines htmlLines(dynamic data) {
  HtmlLines lines = new HtmlLines();

  if (data is List) {
    if (data.isNotEmpty) {
      // not a list, might be a line data [0, "test"] directly
      if (data.first is int) {
        _addItem(lines, data);
      } else if (data is List) {
        for (var item in data) {
          _addItem(lines, item);
        }
      } else {
        throw 'invalid param: ${data}';
      }
    }
  } else {
    _addItem(lines, data);
  }

  return lines;
}

Future checkHtmlElement(String html, HtmlLines lines) async {
  expect(await htmlLinesFromElementHtml(html), lines,
      reason: "html: '${html}'");
  // reconvert result to be sure
  expect(await htmlLinesFromElementHtml(htmlPrintLines(lines)), lines,
      reason: html);
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
      expect(lines1, htmlLines('test'));
      expect(lines1, htmlLines(['test']));
      expect(
          lines1,
          htmlLines([
            ['test']
          ]));
      expect(
          lines1,
          htmlLines([
            [0, 'test']
          ]));
    });
  });

  group('utils', () {
    test('inlineText', () {
      expect(utilsInlineText('a'), 'a');
      expect(utilsInlineText(' '), ' ');
      expect(utilsInlineText(' a'), ' a');
      expect(utilsInlineText('a '), 'a ');
      expect(utilsInlineText(' a '), ' a ');
      expect(utilsInlineText('  a  '), ' a ');
      expect(utilsInlineText('\r\na\t\r\n '), ' a ');
    });
  });
  List<String> blocksToStrings(List<HtmlBlock> blocks) {
    List<String> list = [];
    for (HtmlBlock block in blocks) {
      list.add(block.toString());
    }
    return list;
  }
  group('html_block_printer', () {
    test('empty', () {
      HtmlBlockElementPrinter printer = new HtmlBlockElementPrinter();
      expect(printer.blocks, isEmpty);
    });

    test('element', () async {
      Element element = new Element.html('<a></a>');
      HtmlBlockElementPrinter printer = new HtmlBlockElementPrinter();
      await printer.visitElement(element);
      HtmlBlocks blocks = printer.blocks;
      expect(blocksToStrings(blocks), ['<a>', '</a>']);
      expect((blocks[0] as HtmlTextBlock).content, '<a>');
      expect(blocks[0].before.hasWhiteSpace, isNot(isTrue));
      expect(blocks[0].after.hasWhiteSpace, isNot(isTrue));
      expect((blocks[1] as HtmlTextBlock).content, '</a>');
      expect(blocks[1].before.hasWhiteSpace, isNot(isTrue));
      expect(blocks[1].after.hasWhiteSpace, isNot(isTrue));
      expect(blocks, hasLength(2));

      //expect(block, htmlLines(['<a></a>']));
    });

    test('element_with_content', () async {
      Element element = new Element.html('<a>link</a>');
      HtmlBlockElementPrinter printer = new HtmlBlockElementPrinter();
      await printer.visitElement(element);
      HtmlBlocks blocks = printer.blocks;
      expect(blocksToStrings(blocks), ['<a>', 'link (splitable)', '</a>']);
      expect((blocks[0] as HtmlTextBlock).content, '<a>');
      expect(blocks[0].before.hasWhiteSpace, isNot(isTrue));
      expect(blocks[0].after.hasWhiteSpace, isNot(isTrue));
      expect((blocks[2] as HtmlTextBlock).content, '</a>');
      expect(blocks[2].before.hasWhiteSpace, isNot(isTrue));
      expect(blocks[2].after.hasWhiteSpace, isNot(isTrue));
      expect(blocks, hasLength(3));
      //expect(printer.block, htmlLines(['<a></a>']));
    });

    /*
    test('element_with_space', () async {
      Element element = new Element.html('<a> </a>');
      HtmlBlockElementPrinter printer = new HtmlBlockElementPrinter();
      await printer.visitElement(element);
      dumpBlock(block);
      expect((blocks[0] as HtmlTextBlock).content, '<a>');
      expect(blocks[0].before.hasWhiteSpace, isNot(isTrue));
      expect(blocks[0].after.hasWhiteSpace, isTrue);
      expect((blocks[1] as HtmlTextBlock).content, '</a>');
      expect(blocks[1].before.hasWhiteSpace, isTrue);
      expect(blocks[1].after.hasWhiteSpace, isNot(isTrue));
      expect(blocks, hasLength(2));
      //expect(printer.block, htmlLines(['<a></a>']));
    });
    */
  });
  group('html_printer', () {
    test('empty', () {
      HtmlElementPrinter printer = new HtmlElementPrinter();
      expect(printer.lines, isEmpty);
    });

    test('element', () async {
      Element element = new Element.html('<a></a>');
      expect(element.outerHtml, '<a></a>');
      HtmlElementPrinter printer = new HtmlElementPrinter();
      await printer.visitElement(element);
      expect(printer.lines, htmlLines(['<a></a>']));
    });

    test('element_base', () async {
      await checkHtmlElement('<a></a>', htmlLines('<a></a>'));
      await checkHtmlElement('<a>link</a>', htmlLines('<a>link</a>'));
      await checkHtmlElement('<a> link</a>', htmlLines('<a> link</a>'));
      await checkHtmlElement('<a>  link</a>', htmlLines('<a> link</a>'));
      await checkHtmlElement('<a>link </a>', htmlLines('<a>link </a>'));
      await checkHtmlElement('<a>\rlink\n</a>', htmlLines('<a> link </a>'));
      await checkHtmlElement('<a>\n</a>', htmlLines('<a> </a>'));
      //await checkHtmlElement('<a>\r0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 012345789 link\n</a>', htmlLines('<a> link </a>'));
      await checkHtmlElement('<div></div>', htmlLines('<div></div>'));
      await checkHtmlElement('<div>\n</div>', htmlLines(['<div>', '</div>']));
      await checkHtmlElement(
          '<div>\na</div>',
          htmlLines([
            '<div>',
            [1, 'a'],
            '</div>'
          ]));
      await checkHtmlElement(
          '<div>a\n</div>',
          htmlLines([
            '<div>',
            [1, 'a'],
            '</div>'
          ]));
      await checkHtmlElement('<div> a</div>', htmlLines(['<div> a</div>']));
      await checkHtmlElement('<div>a </div>', htmlLines(['<div>a </div>']));
    });

    test('element_sub', () async {
      await checkHtmlElement(
          '<a><span></span></a>', htmlLines('<a><span></span></a>'));
      await checkHtmlElement(
          '<div><span></span></div>',
          htmlLines([
            '<div>',
            [1, '<span></span>'],
            '</div>'
          ]));
      await checkHtmlElement(
          '<div><div></div></div>',
          htmlLines([
            '<div>',
            [1, '<div></div>'],
            '</div>'
          ]));
      await checkHtmlElement(
          '<div><div>text</div></div>',
          htmlLines([
            '<div>',
            [1, '<div>text</div>'],
            '</div>'
          ]));
    });
    test('element_base_debug', () async {
      // copy the test here and make it solo
      //await checkHtmlElement('<div><div><div></div></div></div>', htmlLines(['<div>', [1, '<div>'], [2, '<div></div>'],[1, '</div>'], '</div>']));
      await checkHtmlElement('<div> a</div>', htmlLines(['<div> a</div>']));

      //await checkHtmlElement('<a>link</a>', htmlLines('<a>link</a>'));
    });
    test('element_with_text', () async {
      Element element = new Element.html('<a>link</a>');
      expect(element.outerHtml, '<a>link</a>');
      HtmlElementPrinter printer = new HtmlElementPrinter();
      await printer.visitElement(element);
      expect(printer.lines, htmlLines([0, '<a>link</a>']));
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
            [1, '<head></head>'],
            [1, '<body></body>'],
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
            [1, '<head></head>'],
            [1, '<body></body>'],
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
          '${htmlDoctype}\n<html>\n<head></head>\n<body></body>\n</html>');
      document = new Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>');
      //minHtml
      expect(await htmlPrintDocument(document), minHtml);
      //'${htmlDoctype}\n<html>\n<head></head>\n<body></body>\n</html>');
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
