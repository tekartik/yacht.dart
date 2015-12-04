library yacht.src.html_printer;

import 'html_visitor.dart';
import 'package:html/dom.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:barback/src/transformer/barback_settings.dart';
import 'dart:convert';

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

  /// Try to fit content in 80 chars when appropriate
  int contentLength = 80;
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

class BlockSeparator {
  bool hasWhiteSpace;

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    if (hasWhiteSpace == true) {
      sb.write('|');
    }
    return sb.toString();
  }
}

//
// blocks
//
abstract class HtmlBlock {
  HtmlBlock parent;
  BlockSeparator before = new BlockSeparator();
  BlockSeparator after = new BlockSeparator();

  @override
  String toString() => "$before:$after";
}

class HtmlBlocks extends DelegatingList<HtmlBlock> {
  final List<HtmlBlock> _l;

  HtmlBlocks() : this.from(<HtmlBlock>[]);
  HtmlBlocks.from(l)
      : _l = l,
        super(l);
}
/*
class HtmlParentBlock extends HtmlBlock {
  List<HtmlBlock> children = [];
  String toString() => "$before[]$after";
}
*/

// might contain text
class HtmlTextBlock extends HtmlBlock {
  bool splitable;
  String content;

  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write(before);
    sb.write(content);
    sb.write(after);
    if (splitable) {
      sb.write(' (splitable)');
    }
    return sb.toString();
  }
}

//
// utls
//

///
/// Returns `true` if [rune] represents a whitespace character.
///
/// The definition of whitespace matches that used in [String.trim] which is
/// based on Unicode 6.2. This maybe be a different set of characters than the
/// environment's [RegExp] definition for whitespace, which is given by the
/// ECMAScript standard: http://ecma-international.org/ecma-262/5.1/#sec-15.10
///
/// from quiver
///
bool _isWhitespace(int rune) => ((rune >= 0x0009 && rune <= 0x000D) ||
    rune == 0x0020 ||
    rune == 0x0085 ||
    rune == 0x00A0 ||
    rune == 0x1680 ||
    rune == 0x180E ||
    (rune >= 0x2000 && rune <= 0x200A) ||
    rune == 0x2028 ||
    rune == 0x2029 ||
    rune == 0x202F ||
    rune == 0x205F ||
    rune == 0x3000 ||
    rune == 0xFEFF);

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

// source https://developer.mozilla.org/en/docs/Web/HTML/Inline_elemente
List<String> _inlineTags = [
  'b',
  'big',
  'i',
  'small',
  'tt',
  'abbr',
  'acronym',
  'cite',
  'code',
  'dfn',
  'em',
  'kbd',
  'strong',
  'samp',
  'time',
  'var',
  'a',
  'bdo',
  'br',
  'img',
  'map',
  'object',
  'q',
  'script',
  'span',
  'sub',
  'sup',
  'button',
  'input',
  'label',
  'select',
  'textarea'
];

List<String> _innerInlineTags = [
  'meta', 'title', 'link', // for head
  "h1", "h2", "h3", "h4", "h5", "h6", // for title
]..addAll(_inlineTags);

// private definition
List<String> _rawTags = ['script', 'style'];

//
// helps
//
bool _inlineContentForTag(String tagName) {
  if (_innerInlineTags.contains(tagName)) {
    return true;
  } else {
    return false;
  }
}

bool _doNotConvertContentForTag(String tagName) {
  switch (tagName) {
    case 'pre':
      return true;
    default:
      return false;
  }
}

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

List<String> _wordSplit(String input) {
  List<String> out = [];
  StringBuffer sb = new StringBuffer();

  _addCurrent() {
    if (sb.length > 0) {
      out.add(sb.toString());
      sb = new StringBuffer();
    }
  }
  for (int rune in input.runes) {
    if (_isWhitespace(rune)) {
      _addCurrent();
    } else {
      sb.writeCharCode(rune);
    }
  }
  _addCurrent();
  return out;
}

String utilsInlineText(String text) {
  // remove and/trailing space
  Runes runes = text.runes;
  bool hasWhitespaceBefore = _isWhitespace(runes.first);
  bool hasWhitespaceAfter = _isWhitespace(runes.last);
  List<String> list = _wordSplit(text);
  StringBuffer sb = new StringBuffer();
  if (hasWhitespaceBefore) {
    sb.write(' ');
  }
  if (list.isNotEmpty) {
    sb.write(list.join(' '));
    if (hasWhitespaceAfter) {
      sb.write(' ');
    }
  }
  return sb.toString();
}

abstract class HtmlLinesBuilderMixin {
  HtmlLines _lines = new HtmlLines();
  HtmlLines get lines {
    _addLine();
    return _lines;
  }

  int depth = 0;
  // implemented by BaseVisitor
  Future<Node> visitChildren(Node node);

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

  StringBuffer sb = new StringBuffer();
  bool parentInline;
  bool inlineContent;
  bool doNotConvertContent;
  bool isRawTag;
  int beginLineDepth;

  // @override
  _add(String content) {
    if (sb.isEmpty) {
      beginLineDepth = depth;
    }
    //if ()
    if (content != null) {
      sb.write(content);
    }
    //_lines.add(htmlLine(depth, content));
  }

  _addLine() {
    if (sb.length > 0) {
      _lines.add(htmlLine(beginLineDepth, sb.toString()));
      sb = new StringBuffer();
    }
  }

  // create new lines for every lines
  _addLines([List<String> lines]) {
    for (String line in lines) {
      _addLine();
      _add(line);
    }
    // and close at the end
    _addLine();
  }

  // @override
  Future<Node> visit(Node node) async {

    if (node is Element) {
      //print(node.outerHtml);
      String tag = node.localName;
      bool parentInline = inlineContent;
      bool parentDoNotConvertContent = doNotConvertContent;
      bool parentIsRawTag = isRawTag;
      doNotConvertContent = _doNotConvertContentForTag(tag);
      bool hasSingleTextNodeLine = _hasSingleTextNodeLine(node) || !node.hasChildNodes();
      inlineContent = _inlineContentForTag(tag) || hasSingleTextNodeLine;
      isRawTag = _rawTags.contains(tag);
      _add(elementBeginTag(node));
      if (!inlineContent) {
        _addLine();
      }
      depth++;
      await visitChildren(node);
      depth--;
      _add(elementEndTag(node));
      doNotConvertContent = parentDoNotConvertContent;
      inlineContent = parentInline == true;
      isRawTag = parentIsRawTag;
      if (!inlineContent) {
        _addLine();
      }
    } else {
      if (doNotConvertContent) {
        _add(node.text);
      } else if (node.nodeType == Node.TEXT_NODE) {
        // remove and/trailing space
        String text = node.text;

        if (inlineContent) {
          // trim and add minimum space
          _add(utilsInlineText(text));
        } else {
          _addLine();
          // for style/script split & join to prevent \r \n
          if (isRawTag) {
            _addLines(LineSplitter.split(text));
          } else {
            List<String> lines = convertContent(text, 80);
            _addLines(lines);
          }
        }
      } else {
        // skip other
        print('${node.nodeType} ${node.text}');
      }

    }
    return node;
  }
}

// Character constants.
const int _LF = 10;
const int _CR = 13;

// <h1>test</h1>
// <style>body {opacity: 0}</style>
bool _hasSingleTextNodeLine(Element element) {
  List<Node> childNodes = element.nodes;
  if (childNodes.length == 1) {
    Node node = childNodes.first;
    if (node.nodeType == Node.TEXT_NODE) {
      String value = node.text;
      if (!(value.codeUnits.contains(_CR) || value.codeUnits.contains(_LF))) {
        return true;
      }
    }
  }
  return false;
}

List<String> convertContent(String input, int contentLength) {
  List<String> words = _wordSplit(input);
  List<String> out = [];

  StringBuffer sb = new StringBuffer();

  _addCurrent() {
    if (sb.length > 0) {
      out.add(sb.toString());
      sb = new StringBuffer();
    }
  }
  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    if (sb.length == 0) {
      // if empty never create a new line
    } else if (sb.length + word.length + 1 > contentLength) {
      _addCurrent();
    } else {
      // add a space
      sb.write(' ');
    }
    sb.write(word);
  }
  _addCurrent();
  return out;
}

/// block build
abstract class HtmlBlocksBuilderMixin {
  final HtmlBlocks blocks = new HtmlBlocks();

  int depth = 0;
  // implemented by BaseVisitor
  Future<Node> visitChildren(Node node);

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

  StringBuffer sb = new StringBuffer();
  bool parentInline;
  bool inline;
  bool doNotFormatContent;

  //bool previousIsSpace;
  HtmlBlock previousBlock;

  // @override
  _add(String content) {
    //if ()
    sb.write(content);
    //_lines.add(htmlLine(depth, content));
  }

  /*
  _addLine() {
    if (sb.length > 0) {
      _lines.add(htmlLine(depth, sb.toString()));
      sb = new StringBuffer();
    }
  }
  */

  _addBlock(HtmlBlock block) {
    // Fix from previous
    if (block.before.hasWhiteSpace != true) {
      if (previousBlock != null) {
        block.before.hasWhiteSpace = previousBlock.after.hasWhiteSpace;
      }
    } else {
      // fix previous
      if (previousBlock != null) {
        if (previousBlock.after.hasWhiteSpace != true) {
          previousBlock.after.hasWhiteSpace = block.before.hasWhiteSpace;
        }
      }
    }

    blocks.add(block);
    previousBlock = block;
  }
  // whole text block
  HtmlTextBlock _htmlStringBlock(String content) {
    HtmlTextBlock block = new HtmlTextBlock()..content = content;
    return block;
  }

  // @override
  Future<Node> visit(Node node) async {
    if (node is Element) {
      String tag = node.localName;
      bool previousInline = inline;
      inline = _inlineContentForTag(tag);
      doNotFormatContent = _doNotConvertContentForTag(tag);
      _addBlock(_htmlStringBlock(elementBeginTag(node))..splitable = false);
      await visitChildren(node);
      _addBlock(_htmlStringBlock(elementEndTag(node))..splitable = false);
      inline = previousInline;
      /*
      if (!inline) {
        //_addLine();
      }
      */
    } else {
      String text = node.text;
      Runes runes = text.runes;
      bool hasWhitespaceBefore = _isWhitespace(runes.first);
      bool hasWhitespaceAfter = _isWhitespace(runes.last);
      //previousIsSpace = hasWhitespaceAfter;

      text = text.trim();
      if (text.length > 0) {
        _addBlock(_htmlStringBlock(node.text)
          ..splitable = !doNotFormatContent
          ..before.hasWhiteSpace = hasWhitespaceBefore
          ..after.hasWhiteSpace = hasWhitespaceAfter);


      } else if (hasWhitespaceBefore && previousBlock != null) {
        previousBlock.after.hasWhiteSpace = hasWhitespaceBefore;
      }
    }
    return node;
  }
}

class HtmlBlockElementPrinter extends HtmlElementVisitor
    with HtmlBlocksBuilderMixin {}

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
