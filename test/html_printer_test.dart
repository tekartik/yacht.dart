library yacht.test.html_visitor_test;

import 'package:html/dom.dart';
import 'package:yacht/src/html_printer.dart';

import 'test_common.dart';

const String minHtml = '''
<!doctype html>
<html>
<head></head>
<body></body>
</html>
''';
const String minInHtml =
    '<!doctype html><html><head></head><body></body></html>';

HtmlLines minHtmlLines = htmlLines([
  [0, '<html>'],
  [1, '<head></head>'],
  [1, '<body></body>'],
  [0, '</html>']
]);
// Allow for [0,'<a>'] or ['</a>'] or '<a>'
void _addItem(HtmlLines lines, dynamic item) {
  var depth = 0;
  dynamic content;
  if (item is List) {
    var index = 0;
    if (item.length > 1) {
      depth = item[index++] as int;
    }
    content = item[index++];

    // the content can be a list as well..
    if (content is List) {
      for (var _content in content?.cast<String>()) {
        lines.add(htmlLine(depth, _content));
      }
      return;
    }
  } else {
    content = item;
  }
  lines.add(htmlLine(depth, content as String));
}

@deprecated // use htmlLines
HtmlLines htmlMultiHtmlLines(List data) {
  var lines = HtmlLines();
  for (var item in data) {
    _addItem(lines, item);
  }
  return lines;
}

HtmlLines htmlLinesFromElementHtml(String html, {HtmlPrinterOptions options}) {
  var element = Element.html(html);
  //print(element.outerHtml');
  var printer = HtmlElementPrinter();
  if (options != null) {
    printer.options = options;
  }

  printer.visitElement(element);
  return printer.lines;
}
// Allow for [[0,'<a>'],[0,'</a']]
// ['<a>', '</a>']

HtmlLines htmlLines(dynamic data) {
  var lines = HtmlLines();

  if (data is List) {
    if (data.isNotEmpty) {
      // not a list, might be a line data [0, 'test'] directly
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

void checkHtmlElement(String html, HtmlLines lines, [int contentLength]) {
  var options = HtmlPrinterOptions();
  if (contentLength != null) {
    options.contentLength = contentLength;
  }
  expect(htmlLinesFromElementHtml(html, options: options), lines,
      reason: 'html: \'${html}\'');
  // reconvert result to be sure
  var outHtml = htmlPrintLines(lines, options: options);
  expect(htmlLinesFromElementHtml(outHtml, options: options), lines,
      reason: 'outhtml: ${outHtml}\n/\n ${html}');
}

void main() {
  group('html_line', () {
    test('equals', () {
      var line1 = htmlLine(null, null);
      var line2 = htmlLine(null, null);
      expect(line1, line1);
      expect(line1, line2);
      expect(line1.hashCode, line2.hashCode);
      line2 = htmlLine(1, null);
      expect(line1.hashCode, isNot(line2.hashCode));
      expect(line1, isNot(line2));
      line2 = htmlLine(null, 'test');
      expect(line1, isNot(line2));
      expect(line1.hashCode, isNot(line2.hashCode));

      line1 = htmlLine(1, 'test');
      line2 = htmlLine(1, 'test');
      expect(line1, line2);
      expect(line1.hashCode, line2.hashCode);
    });
  });

  group('html_lines', () {
    test('build', () {
      var lines = htmlLines([
        [0, 'test'],
        [1, 'sub']
      ]);
      expect(lines[0], htmlLine(0, 'test'));
      expect(lines[1], htmlLine(1, 'sub'));
      expect(lines.length, 2);
    });
    test('equals', () {
      var lines1 = htmlLines([
        [0, 'test']
      ]);

      var lines2 = htmlLines([0, 'test']);
      expect(lines1, lines2);
      lines2 = htmlLines([1, 'sub']);
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
      expect(lines1, htmlLines([0, 'test']));

      expect(
          lines1,
          htmlLines([
            0,
            ['test']
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

  group('html_printer', () {
    test('empty', () {
      var printer = HtmlElementPrinter();
      expect(printer.lines, isEmpty);
    });

    test('element', () {
      var element = Element.html('<a></a>');
      expect(element.outerHtml, '<a></a>');
      var printer = HtmlElementPrinter();
      printer.visitElement(element);
      expect(printer.lines, htmlLines(['<a></a>']));
    });

    test('inner_element', () {
      var element = Element.html('<div><a></a></div>');
      expect(element.outerHtml, '<div><a></a></div>');
      /*
      devPrint(element.innerHtml);
      devPrint(element.text);
      */
      var printer = HtmlElementPrinter();
      printer.visitElement(element);
      expect(printer.lines, htmlLines(['<div><a></a></div>']));
    });

    test('element_with_text_node', () {
      var element = Element.tag('div');
      element.text = '<a></a>';
      var printer = HtmlElementPrinter();
      printer.visitElement(element);
      expect(printer.lines, htmlLines(['<div>&lt;a&gt;&lt;/a&gt;</div>']));
    });

    test('element_html', () {
      try {
        Element.html('&lt;a&gt;&lt;/a&gt;');
        fail('should fail');
      } on ArgumentError catch (_) {
        //print(_);
        //print(_.runtimeType);

      }
      var element = Element.html('<div>&lt;a&gt;&lt;/a&gt;</div>');
      expect(element.outerHtml, '<div>&lt;a&gt;&lt;/a&gt;</div>');
      expect(element.text, '<a></a>');
      var printer = HtmlElementPrinter();
      printer.visitElement(element);
      expect(printer.lines, htmlLines(['<div>&lt;a&gt;&lt;/a&gt;</div>']));
    });

    test('span', () async {
      checkHtmlElement('<a></a>', htmlLines('<a></a>'));
      checkHtmlElement('<a>link</a>', htmlLines('<a>link</a>'));
      checkHtmlElement('<a> link</a>', htmlLines('<a> link</a>'));
      checkHtmlElement('<a>  link</a>', htmlLines('<a> link</a>'));
      checkHtmlElement('<a>link </a>', htmlLines('<a>link </a>'));
      checkHtmlElement(
          '<a> link </a>',
          htmlLines([
            '<a>',
            [1, 'link'],
            '</a>'
          ]));
      checkHtmlElement(
          '<a>\rlink\n</a>',
          htmlLines([
            '<a>',
            [1, 'link'],
            '</a>'
          ]));
      checkHtmlElement('<a>\n</a>', htmlLines(['<a>', '</a>']));
    });

    test('element_base', () async {
      //checkHtmlElement('<a>\r0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 012345789 link\n</a>', htmlLines('<a> link </a>'));
      checkHtmlElement('<div></div>', htmlLines('<div></div>'));
      checkHtmlElement('<div>\n</div>', htmlLines(['<div>', '</div>']));
      checkHtmlElement('<div>\na</div>', htmlLines('<div> a</div>'));
      checkHtmlElement('<div>a\n</div>', htmlLines('<div>a </div>'));
      checkHtmlElement('<div> a</div>', htmlLines(['<div> a</div>']));
      checkHtmlElement('<div>a </div>', htmlLines(['<div>a </div>']));
    });

    test('element_sub', () async {
      checkHtmlElement(
          '<a><span></span></a>', htmlLines('<a><span></span></a>'));
      checkHtmlElement(
          '<div><span></span></div>', htmlLines('<div><span></span></div>'));
      checkHtmlElement(
          '<div><div></div></div>', htmlLines('<div><div></div></div>'));
      checkHtmlElement('<div><div>text</div></div>',
          htmlLines('<div><div>text</div></div>'));
    });

    test('style_element_with_empty_lines', () async {
      checkHtmlElement(
          '<style>body {\n\r\tmargin: 0;\n}</style>',
          htmlLines([
            '<style>',
            [
              1,
              ['body {', '\tmargin: 0;', '}']
            ],
            '</style>'
          ]));
    });

    test('style_empty', () async {
      checkHtmlElement('<style></style>', htmlLines(['<style></style>']));
    });

    test('style_spaces', () {
      checkHtmlElement('<style> </style>', htmlLines(['<style>', '</style>']));
    });

    test('style_linefeed', () {
      checkHtmlElement('<style>\n</style>', htmlLines(['<style>', '</style>']));
    });

    test('style_linefeed_and_spaces', () {
      checkHtmlElement(
          '<style>\n \n</style>', htmlLines(['<style>', '</style>']));
    });

    test('style_multi_spaces', () async {
      checkHtmlElement(
          '<style>\r \r</style>', htmlLines(['<style>', '</style>']));
    });

    test('style_element_single_line', () {
      // from amp
      checkHtmlElement('<style>body {opacity: 0}</style>',
          htmlLines(['<style>body {opacity: 0}</style>']));
    });

    test('style_no_escape', () {
      // from amp
      checkHtmlElement('<style>div>a{color:red}</style>',
          htmlLines(['<style>div>a{color:red}</style>']));
    });

    test('script_no_escape', () {
      // from amp
      checkHtmlElement('<script>if (2 > 1) print("hi");</script>',
          htmlLines(['<script>if (2 > 1) print("hi");</script>']));
    });

    test('style_element_with_line_feed', () {
      checkHtmlElement('<style>\n</style>', htmlLines(['<style>', '</style>']));
      checkHtmlElement(
          '<style>\n\n</style>', htmlLines(['<style>', '</style>']));
    });

    test('title_element', () {
      checkHtmlElement(
          '<title>some  text</title>', htmlLines(['<title>some text</title>']));
    });

    test('input_element', () {
      checkHtmlElement('<input />', htmlLines(['<input>']));
    });

    test('paragraph_long', () {
      checkHtmlElement(
          '<p>0123456789 012345678 012345678910 0123456 789 12345\n</p>',
          htmlLines([
            '<p>0123456789',
            [
              1,
              ['012345678', '012345678910', '0123456', '789 12345 </p>']
            ]
          ]),
          10);
    });

    test('paragraph_long_2', () {
      checkHtmlElement('<p>0123456789</p>', htmlLines('<p>0123456789</p>'), 10);
      checkHtmlElement(
          '<p>\n0123456789</p>',
          htmlLines([
            '<p>',
            [1, '0123456789</p>']
          ]),
          10);
      checkHtmlElement(
          '<p>0123456789\n</p>', htmlLines(['<p>0123456789 </p>']), 10);
      checkHtmlElement(
          '<p> 0123456789\n</p>',
          htmlLines([
            '<p>',
            [1, '0123456789'],
            '</p>'
          ]),
          10);
      checkHtmlElement(
          '<p>0123456 789</p>',
          htmlLines([
            '<p>0123456',
            [1, '789</p>']
          ]),
          10);
      checkHtmlElement(
          '<p>012 345 678</p>',
          htmlLines([
            '<p>012 345',
            [1, '678</p>']
          ]),
          10);
      checkHtmlElement(
          '<p>012 3456 78</p>',
          htmlLines([
            '<p>012',
            [1, '3456 78</p>']
          ]),
          10);
    });

    test('paragraph', () {
      checkHtmlElement('<p></p>', htmlLines(['<p></p>']));
    });

    test('paragraph_with_span', () {
      checkHtmlElement('<p>some <span>text</span></p>',
          htmlLines(['<p>some <span>text</span></p>']));
      checkHtmlElement('<p>some <span>text\n</span></p>',
          htmlLines(['<p>some <span>text </span></p>']));
      checkHtmlElement('<p>some <span>text</span>\n</p>',
          htmlLines(['<p>some <span>text</span>', '</p>']));
      checkHtmlElement(
          '<p>\nsome <span>text</span>\n</p>',
          htmlLines([
            '<p>',
            [1, 'some <span>text</span>'],
            '</p>'
          ]));
    });

    test('div', () {
      checkHtmlElement(
          '<div>some  text\r</div>', htmlLines(['<div>some text </div>']));
    });

    test('div_inner_html', () {
      checkHtmlElement('<div>&lt;link rel=prerender&gt</div>',
          htmlLines(['<div>&lt;link rel=prerender&gt;</div>']));
    });

    test('code', () {
      checkHtmlElement('<code>&lt;link rel=prerender&gt</code>',
          htmlLines(['<code>&lt;link rel=prerender&gt;</code>']));
    });

    test('pre', () {
      checkHtmlElement('<pre>&lt;link rel=prerender&gt</pre>',
          htmlLines(['<pre>&lt;link rel=prerender&gt;</pre>']));
    });

    test('noscript', () {
      checkHtmlElement(
          '<noscript><style>body { color: red; }</style></noscript>',
          htmlLines(
              ['<noscript><style>body { color: red; }</style></noscript>']));
    });

    test('two_elements_no_break', () {
      checkHtmlElement(
          '<div>\n<style></style><noscript></noscript>\n</div>',
          htmlLines([
            '<div>',
            [1, '<style></style><noscript></noscript>'],
            '</div>'
          ]));
    });

    test('two_elements_with_break', () {
      checkHtmlElement(
          '<div>\n<style></style>\n<noscript></noscript>\n</div>',
          htmlLines([
            '<div>',
            [
              1,
              ['<style></style>', '<noscript></noscript>']
            ],
            '</div>'
          ]));
    });
    test('two_elements_with_break', () {
      checkHtmlElement(
          '<div>\n<style></style> \n <noscript></noscript>\n</div>',
          htmlLines([
            '<div>',
            [
              1,
              ['<style></style>', '<noscript></noscript>']
            ],
            '</div>'
          ]));
    });

    test('element_base_debug', () async {
      // copy the test here and make it solo
      checkHtmlElement(
          '<head>\n<meta charset="utf-8">\n<title>Included Title</title>  </head>',
          htmlLines([
            '<head>',
            [
              1,
              ['<meta charset="utf-8">', '<title>Included Title</title>']
            ],
            '</head>'
          ]));
    });

    test('anchor_with_inner_element', () {
      checkHtmlElement('<a><img/></a>', htmlLines(['<a><img></a>']));
    });

    test('element_with_text', () async {
      var element = Element.html('<a>link</a>');
      expect(element.outerHtml, '<a>link</a>');
      var printer = HtmlElementPrinter();
      printer.visitElement(element);
      expect(printer.lines, htmlLines([0, '<a>link</a>']));
    });
  });

  group('print_document', () {
    test('document', () async {
      var document = Document();
      expect(document.outerHtml, '');
      var printer = HtmlDocumentPrinter();
      printer.visitDocument(document);
      //print(printer.lines);
      expect(printer.lines, htmlLines([]));
    });

    test('document_html_empty', () async {
      var document = Document.html('');
      expect(document.outerHtml, '<html><head></head><body></body></html>');

      //print(document.outerHtml);
      var builder = HtmlDocumentPrinter();
      builder.visitDocument(document);
      expect(builder.lines, minHtmlLines);
      //print(builder.nodes);
    });

    test('document_html_basic', () async {
      var document = Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>');

      //print(document.outerHtml);
      var builder = HtmlDocumentPrinter();
      builder.visitDocument(document);
      expect(builder.lines, minHtmlLines);
      //print(builder.nodes);
    });

    test('document_html_tag_in_head', () async {
      var document = Document.html(
          '<!DOCTYPE html><html><head><my-tag></my-tag></head><body></body></html>');

      // my-tag move to body!
      expect(document.head.querySelector('my-tag'), isNull);
      expect(document.body.querySelector('my-tag'), isNotNull);
      //print(document.outerHtml);
      var builder = HtmlDocumentPrinter();
      builder.visitDocument(document);
      //expect(builder.lines, minHtmlLines);
      //print(builder.nodes);
    });
  });

  group('utils', () {
    test('htmlPrintLines', () {
      expect(htmlPrintLines(htmlLines([])), '${htmlDoctype}\n');
      expect(htmlPrintLines(htmlLines([0, '<html/>'])),
          '${htmlDoctype}\n<html/>\n');
      expect(htmlPrintLines(htmlLines([1, '<html/>'])),
          '${htmlDoctype}\n<html/>\n');
      expect(htmlPrintLines(htmlLines([2, '<html/>'])),
          '${htmlDoctype}\n  <html/>\n');
    });

    test('htmlPrintDocument', () async {
      var document = Document();
      expect(htmlPrintDocument(document), '${htmlDoctype}\n');
      document = Document.html('');
      expect(htmlPrintDocument(document),
          '${htmlDoctype}\n<html>\n<head></head>\n<body></body>\n</html>\n');

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

    test('htmlPrintDocument_min', () async {
      var document = Document.html(
          '<!DOCTYPE html><html><head></head><body></body></html>\n');
      expect(htmlPrintDocument(document), minHtml);
    }, skip: true);
  });
}
