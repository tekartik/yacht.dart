library yacht_transformer.src.html_printer;

import 'html_visitor.dart';
import 'package:html/dom.dart';
import 'dart:async';
import 'package:collection/collection.dart';

const String htmlDoctype = '<!doctype html>';

class HtmlPreprocessorOptions {}

class HtmlPrinterOptions {
  /// start for index min
  int indentDepthMin = 2;
  String indent = '  ';
}

String _htmlPrintLines(HtmlLines htmlLines, HtmlPrinterOptions options) {
  StringBuffer sb = new StringBuffer();
  sb.writeln(htmlDoctype);
  String indent = options.indent;
  int indentDepthMin = options.indentDepthMin;
  for (HtmlLine line in htmlLines) {
    int depth = 1 + line.depth - indentDepthMin;
    // depth might be negative
    for (int i = 0; i < depth; i++) {
      sb.write(indent);
    }

    sb.writeln(line.content);
  }
  return sb.toString();
}

String htmlPrintLines(HtmlLines htmlLines, {HtmlPrinterOptions options}) {
  if (options == null) {
    options = new HtmlPrinterOptions();
  }
  return _htmlPrintLines(htmlLines, options);
}

Future<String> htmlPrintDocument(
    Document doc, HtmlPrinterOptions options) async {
  if (options == null) {
    options = new HtmlPrinterOptions();
  }
  HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
  await printer.visitDocument(doc);
  return _htmlPrintLines(printer.lines, options);
}

/// an output line with a given depth
class HtmlLine {
  HtmlLine(this.depth, this.content);
  final int depth;
  final String content;

  @override
  toString() => '$depth:$content';

  @override
  int get hashCode => depth.hashCode + content.hashCode;

  String toOutputString({String indent}) {
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < depth; i++) {
      sb.write(' ');
    }
    sb.write(content);
    return sb.toString();
  }

  @override
  bool operator ==(o) {
    if (o is HtmlLine) {
      return o.depth == depth && o.content == content;
    }
    return false;
  }
}

class HtmlLines extends DelegatingList<HtmlLine> {
  final List<HtmlLine> _l;

  HtmlLines() : this.from(<HtmlLine>[]);
  HtmlLines.from(l)
      : _l = l,
        super(l);
}

List<String> _voidTags = [
  'area',
  'base',
  'br',
  'col',
  'embed',
  'hr',
  'img',
  'input',
  'keygen',
  'link',
  'menuitem',
  'meta',
  'param',
  'source',
  'track',
  'wbr'
];

String elementBeginTag(Element element) {
  StringBuffer sb = new StringBuffer();
  sb.write('<${element.localName}');
  element.attributes.forEach((key, value) {
    sb.write(' $key');
    if (value.length > 0) {
      sb.write('="$value"');
    }
  });
  sb.write('>');
  return sb.toString();
}

String elementEndTag(Element element) {
  if (_voidTags.contains(element.localName)) {
    return null;
  } else {
    return '</${element.localName}>';
  }
}

HtmlLine htmlLine(int depth, String content) {
  return new HtmlLine(depth, content);
}

abstract class HtmlLinesBuilderMixin {
  HtmlLines lines = new HtmlLines();
  int depth = 0;
  // implemented by BaseVisitor
  Future<Node> visitChildren(Node node);

  // @override
  _add(String content) {
    lines.add(htmlLine(depth, content));
  }

  // @override
  Future<Node> visit(Node node) async {
    if (node is Element) {
      _add(elementBeginTag(node));
      depth++;
      await visitChildren(node);
      depth--;
      _add(elementEndTag(node));
    } else {
      _add(node.text);
    }
    return node;
  }
}

class HtmlDocumentPrinter extends HtmlDocumentVisitor
    with HtmlLinesBuilderMixin {}

class HtmlElementPrinter extends HtmlElementVisitor with HtmlLinesBuilderMixin {
  /*
  HtmlLines lines = new HtmlLines();
  int depth = 0;

  _add(String content) {
    lines.add(new HtmlLine(depth, content));
  }

  @override
  Future<Node> visit(Node node) async {
    if (node is Element) {
      _add(elementBeginTag(node));
      depth++;
      await super.visit(node);
      depth--;
      _add(elementEndTag(node));

    } else {
      _add(node.text);
    }
    return node;
  }
  */
}
