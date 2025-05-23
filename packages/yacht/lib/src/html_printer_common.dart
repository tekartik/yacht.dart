import 'package:collection/collection.dart';
import 'package:html/dom_parsing.dart' show htmlSerializeEscape;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_html/html.dart';

import 'html_tag_utils.dart';
import 'html_utils_common.dart';
import 'html_visitor_common.dart';
import 'text_utils.dart';

const String htmlDoctype = '<!doctype html>';

class HtmlPreprocessorOptions {}

// ignore: unused_element
void _log(Object? message) {
  // ignore: avoid_print
  print(message);
}

/// Printer options
class HtmlPrinterOptions {
  HtmlPrinterOptions({this.isWindows = false});

  bool isWindows; // CRLF ending
  /// start for index min
  int indentDepthMin = 2;
  String indent = '  ';

  /// Try to fit content in 80 chars when appropriate
  int contentLength = 80;
}

String _htmlPrintLines(HtmlLines htmlLines, HtmlPrinterOptions options) {
  var sb = StringBuffer();
  sb.writeln(htmlDoctype);
  var indent = options.indent;
  var indentDepthMin = options.indentDepthMin;

  var addLn = false;
  for (var line in htmlLines) {
    if (addLn) {
      sb.writeln('');
    } else {
      addLn = true;
    }
    var depth = 1 + line.depth! - indentDepthMin;
    // depth might be negative
    for (var i = 0; i < depth; i++) {
      sb.write(indent);
    }

    sb.write(line.content);
  }
  // Add ending new line
  if (addLn) {
    sb.writeln('');
  }
  return sb.toString();
}

String htmlPrintLines(HtmlLines htmlLines, {HtmlPrinterOptions? options}) {
  options ??= HtmlPrinterOptions();

  return _htmlPrintLines(htmlLines, options);
}

String htmlPrintDocument(Document doc, {HtmlPrinterOptions? options}) {
  options ??= HtmlPrinterOptions();

  var printer = HtmlDocumentPrinterCommon();
  printer.visitDocument(doc);
  return _htmlPrintLines(printer.lines, options);
}

//
// Printer lines
//

String _indent(int depth, {String indent = '  '}) {
  var sb = StringBuffer();
  for (var i = 0; i < depth; i++) {
    sb.write(indent);
  }
  return sb.toString();
}

abstract class PrinterLine {
  final int? depth;

  PrinterLine(this.depth);

  @internal
  String get debugIndent => _indent(depth ?? 0);
  @override
  String toString() => debugIndent;

  @override
  int get hashCode => depth.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is PrinterLine) {
      return other.depth == depth;
    }
    return false;
  }
}

class NodeLine extends PrinterLine {
  final Node node;

  /// Only valid if node is an element
  Element get element => node as Element;

  /// Only valid if node is a text
  Text get textNode => node as Text;

  NodeLine(int super.depth, this.node);

  @override
  String toString() => '$debugIndent$node';

  @override
  int get hashCode => super.hashCode + node.hashCode;

  @override
  bool operator ==(Object other) {
    if (super == (other) && other is NodeLine) {
      return other.node == node;
    }
    return false;
  }
}

/// an output line with a given depth
class HtmlLine extends PrinterLine {
  final String? content;

  HtmlLine(super.depth, this.content);

  @override
  String toString() => '$depth:$content';

  @override
  int get hashCode => super.hashCode + content.hashCode;

  @override
  bool operator ==(Object other) {
    if (super == (other) && other is HtmlLine) {
      return other.content == content;
    }
    return false;
  }
}

abstract mixin class NodeLinesBuilderMixin {
  NodeLines lines = NodeLines();
  int depth = 0;

  // implemented by BaseVisitor
  Node visitChildren(Node node);

  // @override
  Node visit(Node node) {
    lines.add(NodeLine(depth, node));
    depth++;
    var result = visitChildren(node);
    depth--;
    return result;
  }
}

class HtmlElementNodeLinesBuilder extends HtmlElementVisitor
    with NodeLinesBuilderMixin {}

class HtmlDocumentNodeLinesPrinter extends HtmlDocumentVisitor
    with NodeLinesBuilderMixin {
  @doNotSubmit
  void debugDump() {
    for (var line in lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}

//
// lines
//

class HtmlLines extends DelegatingList<HtmlLine> {
  //final List<HtmlLine> _l;

  HtmlLines() : this.from(<HtmlLine>[]);

  HtmlLines.from(super.l);
}

class PrinterLines extends DelegatingList<PrinterLine> {
  //final List<PrinterLine> _l;

  PrinterLines() : this.from(<PrinterLine>[]);

  PrinterLines.from(super.l);
}

class NodeLines extends DelegatingList<NodeLine> {
  //final List<NodeLine> _l;

  NodeLines() : this.from(<NodeLine>[]);

  NodeLines.from(super.l);
}

//
// helpers
//

bool _elementBeginWithWhiteSpace(Element element) {
  var firstChild = element.childNodes.firstOrNull;
  if (firstChild is Text) {
    // handle empty (for style)
    var text = firstChild.text;
    if (text.isNotEmpty) {
      return beginsWithWhitespaces(text);
    }
  }
  return false;
}

bool _elementBeginEndsWithWhiteSpace(Element element) {
  if (_elementBeginWithWhiteSpace(element)) {
    var child = element.childNodes.last;
    if (child is Text) {
      return endsWithWhitespaces(child.text);
    }
  }
  return false;
}

bool _doNotConvertContentForTag(String? tagName) {
  switch (tagName) {
    case 'pre':
      return true;
    default:
      return false;
  }
}

// prevent converting > to &gt;
bool _doNotEscapeContentForTag(String? tagName) {
  switch (tagName) {
    case 'style':
    case 'script':
      return true;
    default:
      return false;
  }
}

String elementBeginTag(Element element) {
  var sb = StringBuffer();
  sb.write('<${element.tagName}');
  element.attributes.forEach((key, value) {
    sb.write(' $key');
    if (value.isNotEmpty) {
      sb.write('="$value"');
    }
  });
  sb.write('>');
  return sb.toString();
}

String? elementEndTag(Element element) {
  if (voidTags.contains(element.tagName)) {
    return null;
  } else {
    return '</${element.tagName}>';
  }
}

HtmlLine htmlLine(int? depth, String? content) {
  return HtmlLine(depth, content);
}

List<String> _wordSplit(String input) {
  var out = <String>[];
  var sb = StringBuffer();

  void addCurrent() {
    if (sb.length > 0) {
      out.add(sb.toString());
      sb = StringBuffer();
    }
  }

  for (var rune in input.runes) {
    if (isWhitespace(rune)) {
      addCurrent();
    } else {
      sb.writeCharCode(rune);
    }
  }
  addCurrent();
  return out;
}

String utilsInlineText(String text) => utilsTrimText(text, true);

abstract mixin class HtmlLinesBuilderMixin {
  HtmlPrinterOptions? _options;

  set options(HtmlPrinterOptions options) {
    _options = options;
  }

  HtmlPrinterOptions get options {
    _options ??= HtmlPrinterOptions();

    return _options!;
  }

  final _lines = HtmlLines();

  HtmlLines get lines {
    _addLine();
    return _lines;
  }

  int depth = 0;

  // implemented by BaseVisitor
  Node visitChildren(Node node);

  String elementBeginTag(Element element) {
    var sb = StringBuffer();
    sb.write('<${element.tagName}');
    element.attributes.forEach((key, value) {
      sb.write(' $key');
      if (value.isNotEmpty) {
        sb.write('="$value"');
      }
    });
    sb.write('>');
    return sb.toString();
  }

  StringBuffer sb = StringBuffer();

  // specified at the beginning
  bool spaceRequired = false;

  bool? parentInline;
  bool? inlineContent;
  bool? doNotConvertContent;
  late bool doNotEscapeContent; // for style/script
  bool? isRawTag;
  int? beginLineDepth;

  // only add if not at the beginning of a line
  void _addWhitespace() {
    if (sb.isEmpty) {
      beginLineDepth = depth;
    } else {
      sb.write(' ');
    }
    spaceRequired = false;
  }

  // if content length is set, truncate when possible
  void _add(String? content, [int? contentLength]) {
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

  void _resetLine() {
    // reset
    sb = StringBuffer();
    spaceRequired = false;
    beginLineDepth = depth;
  }

  void _addLine() {
    if (sb.length > 0) {
      // chech whether to trimRight here
      var line = sb.toString().trimRight();
      _lines.add(htmlLine(beginLineDepth, line));

      _resetLine();
    }
  }

  // create new lines for every lines
  void _addLines(Iterable<String> lines) {
    for (var line in lines) {
      _addLine();
      if (!isWhitespaceLine(line)) {
        _add(line);
      }
    }
    // and close at the end
    _addLine();
  }

  void inBufferConvertContent(String input, int contentLength) {
    var words = _wordSplit(input);

    var beginWithWhitespace = beginsWithWhitespaces(input);
    if (sb.length >= contentLength) {
      _addLine();
    } else if (beginWithWhitespace) {
      _addWhitespace();
    }

    for (var i = 0; i < words.length; i++) {
      var word = words[i];
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

    if (words.isNotEmpty) {
      if (endsWithWhitespaces(input)) {
        _addWhitespace();
      }
    }
  }

  // @override
  Node visit(Node node) {
    if (node is Element) {
      var tag = node.tagName;

      // fix noscript issue
      noScriptFix(node);

      //print(node.outerHtml);

      var parentInline = this.inlineContent;
      var parentDoNotConvertContent = doNotConvertContent;
      var parentIsRawTag = isRawTag;
      doNotConvertContent = _doNotConvertContentForTag(tag);
      doNotEscapeContent = _doNotEscapeContentForTag(tag);
      // raw tags are script/style that we keep as is here
      isRawTag = rawTags.contains(tag);
      // bool tryToInline =  _hasSingleTextNodeLines(node);
      var tryToInline = !_elementBeginEndsWithWhiteSpace(node);
      // inlineContent = _inlineContentForTag(tag) || tryToInline;
      var inlineContent = tryToInline;
      this.inlineContent = inlineContent;

      // end line for head tags
      /*
      bool _isHeadTag = isHeadTag(tag) &&
          node.parent != null &&
          node.parent.localName != "noscript";
          */
      var isHeadTag = tag == 'head';
      if (isHeadTag) {
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
      inlineContent = inlineContent || parentInline == true;
      isRawTag = parentIsRawTag;
      if (!inlineContent) {
        _addLine();
      }

      // close line for head tag
      if (isHeadTag) {
        _addLine();
      }

      this.inlineContent = inlineContent;
    } else {
      // Escape text
      // &gt; won't get converted to <
      String? text;
      if (doNotEscapeContent) {
        text = node.textContent;
      } else {
        text = htmlSerializeEscape(node.textContent!);
      }
      // make sure new line starts deeper
      //beginLineDepth = depth;
      if (doNotConvertContent!) {
        _add(text);
      } else if (node.nodeType == Node.textNode) {
        // remove and/trailing space
        if (isRawTag!) {
          // Keep as is if single line
          if (isSingleLineText(text!)) {
            if (!isWhitespaceLine(text)) {
              _add(text);
            }
          } else {
            _addLine();
            _addLines(LineSplitter.split(text));
          }
        } else if (inlineContent!) {
          // Handle return case explicitely
          if (isWhitespaceLine(text!) && text.contains('\n')) {
            _addLine();
          } else {
            // trim and add minimum space
            _add(utilsInlineText(text), options.contentLength);
          }

          // if we continue inlining require a space
          //spaceRequired = utilsEndsWithWhitespace(text);
        } else {
          // for style/script split & join to prevent \r \n

          _addLine();
          // Single line trimmed add it if can
          if (isSingleLineText(text!.trim())) {
            _add(utilsTrimText(text));

            // if we continue inlining require a space
            spaceRequired = endsWithWhitespaces(text);
          } else {
            var lines = convertContent(text, options.contentLength);
            _addLines(lines);
          }
        }
      } else {
        // skip other
        if (isDebug) {
          // ignore: avoid_print
          print('${node.nodeType} $text');
        }
      }
    }
    return node;
  }
}

List<String> convertContent(String input, int contentLength) {
  var words = _wordSplit(input);
  var out = <String>[];

  var sb = StringBuffer();

  void addCurrent() {
    if (sb.length > 0) {
      out.add(sb.toString());
      sb = StringBuffer();
    }
  }

  for (var i = 0; i < words.length; i++) {
    var word = words[i];
    if (sb.length == 0) {
      // if empty never create a new line
    } else if (sb.length + word.length + 1 > contentLength) {
      addCurrent();
    } else {
      // add a space
      sb.write(' ');
    }
    sb.write(word);
  }
  addCurrent();
  return out;
}

class HtmlDocumentPrinterCommon extends HtmlDocumentVisitor
    with HtmlLinesBuilderMixin {}

class HtmlElementPrinterCommon extends HtmlElementVisitor
    with HtmlLinesBuilderMixin {}
