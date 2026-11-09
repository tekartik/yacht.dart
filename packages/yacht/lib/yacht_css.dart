/// Css helpers: [compileCss] (csslib), [HtmlCssInliner] to inline the
/// stylesheets of a page in memory (every platform) and [fixCssInline] to do
/// it on files (`dart:io` only). Re-exports `yacht.dart`.
library;

export 'src/csslib_utils.dart' show compileCss;
export 'src/html_css_inliner.dart'
    show HtmlCssInliner, HtmlCssHrefInlinerFunction, fixCssInline;
export 'yacht.dart';
