// ignore_for_file: avoid_print
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht_css.dart';

/// Tidy a page, inline its stylesheet and minify css (every platform).
Future<void> main() async {
  print(
    htmlProviderHtml5Lib.yachtTidyHtml(
      '<html><body><p>Hello <b>world</b></p></body></html>',
    ),
  );

  var styles = {'style.css': compileCss('body {\n  h1 { margin: 0; }\n}')};
  var inliner = HtmlCssInliner(
    htmlProvider: htmlProviderHtml5Lib,
    // The css text of a href, null to keep the <link>.
    inliner: (href) async => styles[href],
  );
  print(
    await inliner.build(
      '<html><head><link class="yacht-inline" rel="stylesheet" '
      'href="style.css"></head><body><h1>Hello</h1></body></html>',
    ),
  );
}
