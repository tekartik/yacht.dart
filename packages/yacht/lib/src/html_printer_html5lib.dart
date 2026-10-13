import 'package:html/dom.dart' show Document;
import 'package:tekartik_html/html_html5lib.dart' show htmlProviderHtml5Lib;

import 'html_printer_common.dart' as common;
import 'html_printer_common.dart' show HtmlPrinterOptions;

/// Print an html5lib HTML document (same output as the common printer).
String htmlPrintDocument(Document doc, {HtmlPrinterOptions? options}) =>
    common.htmlPrintDocument(
      htmlProviderHtml5Lib.wrapDocument(doc),
      options: options,
    );
