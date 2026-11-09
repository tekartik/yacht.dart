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

/// Css compile result.
class CssCompileResult {
  /// Output css.
  String? out;
}

/// Compile [input] with csslib (nested rules and `@extend` resolved),
/// minified on one line unless [pretty].
///
/// Keep [polyfill] false: on `var(--name)` it produces empty declarations.
/// Invalid css does not throw, csslib drops what it cannot parse.
String compileCss(String input, {bool polyfill = false, bool pretty = false}) {
  var styleSheet = compile(input, polyfill: polyfill);

  return printStyleSheet(styleSheet, pretty: pretty);
}
