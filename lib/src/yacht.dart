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

const yachtAmpBoilerplate =
    '<meta name="viewport" content="width=device-width">\n'
    '<link rel="canonical" href="/article.html">\n'
    '<style amp-boilerplate>body{-webkit-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-moz-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-ms-animation:-amp-start 8s steps(1,end) 0s 1 normal both;animation:-amp-start 8s steps(1,end) 0s 1 normal both}@-webkit-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-moz-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-ms-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-o-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}</style><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript>\n'
    '<script async src="https://cdn.ampproject.org/v0.js"></script>';
