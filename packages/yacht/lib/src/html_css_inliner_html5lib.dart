import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/src/html_css_inliner.dart';

/// Inline CSS in an HTML file.
///
/// `link` elements with the `yacht-inline` class are replaced by a `style`
/// element with the content of the css file (href relative to the html file).
/// A link without href is left as is.
Future fixCssInline(String srcHtmlFilePath, String dstHtmlFilePath) async {
  var html = await File(srcHtmlFilePath).readAsString();
  var inliner = HtmlCssInliner(
    htmlProvider: htmlProviderHtml5Lib,
    inliner: (href) =>
        File(normalize(join(dirname(srcHtmlFilePath), href))).readAsString(),
  );
  html = await inliner.build(html);
  await File(dstHtmlFilePath).writeAsString(html);
}
