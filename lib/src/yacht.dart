import 'package:tekartik_html/html.dart';

import 'html_printer_common.dart';

extension HtmlProviderYachtExt on HtmlProvider {
  /// Tidy a file, if [dstFilePath] is ommited, original file is replaced
  String yachtTidyHtml(String src, {HtmlPrinterOptions? options}) {
    var doc = createDocument(html: src);
    var result = htmlPrintDocument(doc, options: options);
    return result;
  }
}
