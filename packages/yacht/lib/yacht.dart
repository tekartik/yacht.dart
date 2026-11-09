/// Tidy (re-print) html documents of `package:tekartik_html`, on every
/// platform: [htmlPrintDocument], [HtmlPrinterOptions], the `yachtTidyHtml`
/// extension on an `HtmlProvider` and [yachtAmpBoilerplate].
library;

export 'src/html_printer_common.dart'
    show htmlPrintDocument, HtmlPrinterOptions;
export 'src/yacht.dart' show HtmlProviderYachtExt, yachtAmpBoilerplate;
