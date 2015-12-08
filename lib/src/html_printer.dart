library yacht.src.html_printer;

import 'html_visitor.dart';
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:collection/collection.dart';
import 'package:barback/src/transformer/barback_settings.dart';
import 'text_utils.dart';
import 'html_utils.dart';
import 'html_tag_utils.dart';
import 'common_import.dart';

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
  Node visitChildren(Node node);

  // @override
  Node visit(Node node) {
    lines.add(new NodeLine(depth, node));
    depth++;
    var result = visitChildren(node);
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
// helpers
//

bool _elementBeginWithWhiteSpace(Element element) {
  Node firstChild = element.firstChild;
  if (firstChild != null && firstChild.nodeType == Node.TEXT_NODE) {
    // handle empty (for style)
    if (!firstChild.text.isEmpty) {
      return beginWithWhiteSpace(firstChild.text);
    }
  }
  return false;
}

bool _elementBeginEndsWithWhiteSpace(Element element) {
  if (_elementBeginWithWhiteSpace(element)) {
    Node child = element.nodes.last;
    if (child.nodeType == Node.TEXT_NODE) {
      return endWithWhiteSpace(child.text);
    }
  }
  return false;
}

bool _doNotConvertContentForTag(String tagName) {
  switch (tagName) {
    case 'pre':
      return true;
    default:
      return false;
  }
}

// prevent converting > to &gt;
bool _doNotEscapeContentForTag(String tagName) {
  switch (tagName) {
    case 'style':
    case 'script':
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
  if (voidTags.contains(element.localName)) {
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
    if (isWhitespace(rune)) {
      _addCurrent();
    } else {
      sb.writeCharCode(rune);
    }
  }
  _addCurrent();
  return out;
}

String utilsInlineText(String text) => utilsTrimText(text, true);

bool utilsEndsWithWhitespace(String text) {
  Runes runes = text.runes;
  bool hasWhitespaceAfter = isWhitespace(runes.last);
  return hasWhitespaceAfter;
}

String utilsTrimText(String text, [bool keepExternalSpaces = false]) {
  // remove and/trailing space
  Runes runes = text.runes;
  bool hasWhitespaceBefore = isWhitespace(runes.first);
  bool hasWhitespaceAfter = isWhitespace(runes.last);
  List<String> list = _wordSplit(text);
  StringBuffer sb = new StringBuffer();
  if (keepExternalSpaces && hasWhitespaceBefore) {
    sb.write(' ');
  }
  if (list.isNotEmpty) {
    sb.write(list.join(' '));
    if (keepExternalSpaces && hasWhitespaceAfter) {
      sb.write(' ');
    }
  }
  return sb.toString();
}

abstract class HtmlLinesBuilderMixin {
  HtmlPrinterOptions _options;
  set options(HtmlPrinterOptions options) {
    assert(options != null);
    _options = options;
  }

  HtmlPrinterOptions get options {
    if (_options == null) {
      _options = new HtmlPrinterOptions();
    }
    return _options;
  }

  HtmlLines _lines = new HtmlLines();
  HtmlLines get lines {
    _addLine();
    return _lines;
  }

  int depth = 0;
  // implemented by BaseVisitor
  Node visitChildren(Node node);

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

  // specified at the beginning
  bool spaceRequired = false;

  bool parentInline;
  bool inlineContent;
  bool doNotConvertContent;
  bool doNotEscapeContent; // for style/script
  bool isRawTag;
  int beginLineDepth;

  // only add if not at the beginning of a line
  _addWhitespace() {
    if (sb.isEmpty) {
      beginLineDepth = depth;
    } else {
      sb.write(' ');
    }
    spaceRequired = false;
  }

  // if content length is set, truncate when possible
  _add(String content, [int contentLength]) {
    if (sb.isEmpty) {
      beginLineDepth = depth;
      spaceRequired = false;
    } else
    // If a space is required before the next content
    if (spaceRequired) {
      sb.write(' ');
      spaceRequired = false;
    }
    //if ()
    if (content != null) {
      if (contentLength != null) {
        inBufferConvertContent(content, contentLength);
      } else {
        sb.write(content);
      }
    }
    //_lines.add(htmlLine(depth, content));
  }

  _resetLine() {
    // reset
    sb = new StringBuffer();
    spaceRequired = false;
    beginLineDepth = depth;
  }

  _addLine() {
    if (sb.length > 0) {
      // chech whether to trimRight here
      String line = sb.toString().trimRight();
      _lines.add(htmlLine(beginLineDepth, line));

      _resetLine();
    }
  }

  // create new lines for every lines
  _addLines([Iterable<String> lines]) {
    for (String line in lines) {
      _addLine();
      if (!isWhitespaceLine(line)) {
        _add(line);
      }
    }
    // and close at the end
    _addLine();
  }

  void inBufferConvertContent(String input, int contentLength) {
    List<String> words = _wordSplit(input);

    bool beginWithWhitespace = beginWithWhiteSpace(input);
    if (sb.length >= contentLength) {
      _addLine();
    } else if (beginWithWhitespace) {
      _addWhitespace();
    }

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (sb.length == 0) {
        // if empty never create a new line
        // Special first word case with no whitespaces
      } else if ((i > 0 || beginWithWhitespace) &&
          (sb.length + word.length + 1 > contentLength)) {
        _addLine();
      } else if (i > 0) {
        // add a space
        _addWhitespace();
      }
      sb.write(word);
    }

    if (words.length > 0) {
      if (endWithWhiteSpace(input)) {
        _addWhitespace();
      }
    }
  }

  // @override
  Node visit(Node node) {
    if (node is Element) {
      String tag = node.localName;

      // fix noscript issue
      noScriptFix(node);

      //print(node.outerHtml);

      bool parentInline = inlineContent;
      bool parentDoNotConvertContent = doNotConvertContent;
      bool parentIsRawTag = isRawTag;
      doNotConvertContent = _doNotConvertContentForTag(tag);
      doNotEscapeContent = _doNotEscapeContentForTag(tag);
      // raw tags are script/style that we keep as is here
      isRawTag = rawTags.contains(tag);
      // bool tryToInline =  _hasSingleTextNodeLines(node);
      bool tryToInline = !_elementBeginEndsWithWhiteSpace(node);
      // inlineContent = _inlineContentForTag(tag) || tryToInline;
      inlineContent = tryToInline;

      // end line for head tags
      bool _isHeadTag = isHeadTag(tag) &&
          node.parent != null &&
          node.parent.localName != "noscript";
      if (_isHeadTag) {
        _addLine();
      }
      // Don't inline for html
      if (tag == 'html') {
        inlineContent = false;
      }

      _add(elementBeginTag(node));
      if (!inlineContent) {
        _addLine();
      }
      depth++;
      visitChildren(node);
      depth--;

      // if we do not line content
      // close the tag in a new line
      if (!inlineContent) {
        _addLine();
      }
      _add(elementEndTag(node));

      doNotConvertContent = parentDoNotConvertContent;
      inlineContent = parentInline == true;
      isRawTag = parentIsRawTag;
      if (!inlineContent) {
        _addLine();
      }

      // close line for head tag
      if (_isHeadTag) {
        _addLine();
      }
    } else {
      // Escape text
      // &gt; won't get converted to <
      String text;
      if (doNotEscapeContent) {
        text = node.text;
      } else {
        text = htmlSerializeEscape(node.text);
      }
      // make sure new line starts deeper
      //beginLineDepth = depth;
      if (doNotConvertContent) {
        _add(text);
      } else if (node.nodeType == Node.TEXT_NODE) {
        // remove and/trailing space
        if (isRawTag) {
          // Keep as is if single line
          if (isSingleLineText(text)) {
            if (!isWhitespaceLine(text)) {
              _add(text);
            }
          } else {
            _addLine();
            _addLines(LineSplitter.split(text));
          }
        } else if (inlineContent) {
          // trim and add minimum space
          _add(utilsInlineText(text), options.contentLength);

          // if we continue inlining require a space
          //spaceRequired = utilsEndsWithWhitespace(text);
        } else {
          // for style/script split & join to prevent \r \n

          _addLine();
          // Single line trimmed add it if can
          if (isSingleLineText(text.trim())) {
            _add(utilsTrimText(text));

            // if we continue inlining require a space
            spaceRequired = utilsEndsWithWhitespace(text);
          } else {
            List<String> lines = convertContent(text, options.contentLength);
            _addLines(lines);
          }
        }
      } else {
        // skip other
        print('${node.nodeType} ${text}');
      }
    }
    return node;
  }
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

class HtmlDocumentPrinter extends HtmlDocumentVisitor
    with HtmlLinesBuilderMixin {}

class HtmlElementPrinter extends HtmlElementVisitor with HtmlLinesBuilderMixin {
}
