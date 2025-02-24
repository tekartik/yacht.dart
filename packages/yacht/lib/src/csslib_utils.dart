library;

import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';

/// output a stylesheet
/// [polyfill] apply polyfill if true
String printStyleSheet(StyleSheet styleSheet, {bool pretty = true}) {
  var printer = CssPrinter();
  printer.visitTree(styleSheet, pretty: pretty);
  return printer.toString();
}

class CssCompileResult {
  String? out;
}

/// Compile the resulting css (prefer polyfill = false and pretty = false
String compileCss(String input, {bool polyfill = false, bool pretty = false}) {
  var styleSheet = compile(input, polyfill: polyfill);
  return printStyleSheet(styleSheet, pretty: pretty);
}
