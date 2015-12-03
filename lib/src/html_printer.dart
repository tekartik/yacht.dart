library yacht.src.html_printer;

import 'html_visitor.dart';
import 'package:html/dom.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:barback/src/transformer/barback_settings.dart';

const String htmlDoctype = '<!doctype html>';

class HtmlPreprocessorOptions {}

class HtmlPrinterOptions {
  HtmlPrinterOptions();
  HtmlPrinterOptions.fromBarbackSettings(BarbackSettings settings) {
    //TODO
  }

  /// start for index min
  int indentDepthMin = 2;
  String indent = '  ';
}

String _htmlPrintLines(HtmlLines htmlLines, HtmlPrinterOptions options) {
  StringBuffer sb = new StringBuffer();
  sb.writeln(htmlDoctype);
  String indent = options.indent;
  int indentDepthMin = options.indentDepthMin;

  bool addLn = false;
  for (HtmlLine line in htmlLines) {
    if (addLn) {
      sb.writeln('');
    } else {
      addLn = true;
    }
    int depth = 1 + line.depth - indentDepthMin;
    // depth might be negative
    for (int i = 0; i < depth; i++) {
      sb.write(indent);
    }

    sb.write(line.content);
  }
  return sb.toString();
}

String htmlPrintLines(HtmlLines htmlLines, {HtmlPrinterOptions options}) {
  if (options == null) {
    options = new HtmlPrinterOptions();
  }
  return _htmlPrintLines(htmlLines, options);
}

Future<String> htmlPrintDocument(Document doc,
    {HtmlPrinterOptions options}) async {
  if (options == null) {
    options = new HtmlPrinterOptions();
  }
  HtmlDocumentPrinter printer = new HtmlDocumentPrinter();
  await printer.visitDocument(doc);
  return _htmlPrintLines(printer.lines, options);
}

//
// Printer lines
//

abstract class PrinterLine {
  final int depth;

  PrinterLine(this.depth);

  @override
  toString() => '$depth';

  @override
  int get hashCode => depth.hashCode;

  @override
  bool operator ==(o) {
    if (o is PrinterLine) {
      return o.depth == depth;
    }
    return false;
  }
}

class NodeLine extends PrinterLine {
  final Node node;
  NodeLine(int depth, this.node) : super(depth);
  @override
  toString() => '$depth:$node';

  @override
  int get hashCode => super.hashCode + node.hashCode;
  @override
  bool operator ==(o) {
    if (super == (o)) {
      return o.node == node;
    }
    return false;
  }
}

/// an output line with a given depth
class HtmlLine extends PrinterLine {
  final String content;
  HtmlLine(int depth, this.content) : super(depth);
  @override
  toString() => '$depth:$content';

  @override
  int get hashCode => super.hashCode + content.hashCode;

  @override
  bool operator ==(o) {
    if (super == (o)) {
      return o.content == content;
    }
    return false;
  }
}

abstract class NodeLinesBuilderMixin {
  NodeLines lines = new NodeLines();
  int depth = 0;

  // implemented by BaseVisitor
  Future<Node> visitChildren(Node node);

  // @override
  Future<Node> visit(Node node) async {
    lines.add(new NodeLine(depth, node));
    depth++;
    var result = await visitChildren(node);
    depth--;
    return result;
  }
}

class HtmlElementNodeLinesBuilder extends HtmlElementVisitor
    with NodeLinesBuilderMixin {}

class HtmlDocumentNodeLinesPrinter extends HtmlDocumentVisitor
    with NodeLinesBuilderMixin {}

//
// lines
//

class HtmlLines extends DelegatingList<HtmlLine> {
  final List<HtmlLine> _l;

  HtmlLines() : this.from(<HtmlLine>[]);
  HtmlLines.from(l)
      : _l = l,
        super(l);
}

class PrinterLines extends DelegatingList<PrinterLine> {
  final List<PrinterLine> _l;

  PrinterLines() : this.from(<PrinterLine>[]);
  PrinterLines.from(l)
      : _l = l,
        super(l);
}

class NodeLines extends DelegatingList<NodeLine> {
  final List<NodeLine> _l;

  NodeLines() : this.from(<NodeLine>[]);
  NodeLines.from(l)
      : _l = l,
        super(l);
}

//
// tags
//
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
