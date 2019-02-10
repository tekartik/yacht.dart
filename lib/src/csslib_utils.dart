library yacht.src.csslib_utils;

import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';

/// output a stylesheet
/// [polyfill] apply polyfill if true
String printStyleSheet(StyleSheet styleSheet, {bool pretty = true}) {
  CssPrinter printer = CssPrinter();
  printer.visitTree(styleSheet, pretty: pretty);
  return printer.toString();
}

class CssCompileResult {
  String out;
}

// Compile the resulting css
String compileCss(String input, {bool polyfill = true, bool pretty = true}) {
  StyleSheet styleSheet = compile(input, polyfill: polyfill);
  return printStyleSheet(styleSheet, pretty: pretty);
}
