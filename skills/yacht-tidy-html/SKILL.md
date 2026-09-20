---
name: yacht-tidy-html
description: >-
  Use when pretty printing (tidying) html with the legacy yacht package:
  tidyHtml(srcFilePath:, dstFilePath:, htmlProvider:) from yacht_io.dart,
  htmlPrintDocument and HtmlPrinterOptions (indent, indentDepthMin,
  contentLength) from yacht_common.dart, the yachtTidyHtml extension on an
  HtmlProvider, yachtAmpBoilerplate, and when migrating an old `yacht`
  dependency to tekartik_yacht.
---

# Tidy html with the legacy yacht package (yacht)

`yacht` ("Yet Another Css/Html Transformer") re-prints html documents with a
stable, opinionated layout: a `<!doctype html>` line, two space indentation,
inline elements kept inline and text wrapped at 80 columns. Every library of
this package is `@Deprecated('Use tekartik_yacht')`: it is a compatibility
shim over `tekartik_yacht`, in `packages/yacht` of the same repository.

## Guidelines

* New code depends on `tekartik_yacht`, not on `yacht` (neither is on
  pub.dev):

  ```yaml
  dependencies:
    tekartik_yacht:
      git:
        url: https://github.com/tekartik/yacht.dart
        path: packages/yacht
  ```

  Only keep `yacht` (`git: url: https://github.com/tekartik/yacht.dart`, no
  `path:`, the package is at the repository root) while migrating existing
  dependents: importing any of its libraries raises a deprecation hint.
  Migration is a pure import rewrite, the symbols are the same:
  `package:yacht/yacht_common.dart` → `package:tekartik_yacht/yacht.dart`,
  `package:yacht/yacht.dart` → `package:tekartik_yacht/yacht_html5lib.dart`,
  `package:yacht/yacht_io.dart` → `package:tekartik_yacht/yacht_io.dart`.
* The three libraries of `yacht`:
  * `package:yacht/yacht_io.dart` — `tidyHtml({required srcFilePath,
    dstFilePath, htmlProvider})`, plus everything of
    `tekartik_yacht/yacht_io.dart`. `dart:io` only.
  * `package:yacht/yacht_common.dart` — `htmlPrintDocument(document,
    {options})` for a `tekartik_html` `Document`, `HtmlPrinterOptions`, the
    `HtmlProviderYachtExt.yachtTidyHtml(String src, {options})` extension and
    the `yachtAmpBoilerplate` constant. This is the multi-platform entry
    point.
  * `package:yacht/yacht.dart` — the html5lib flavour:
    `htmlPrintDocument(document, {options})` for a `package:html`
    `dom.Document`, and the same extension.
* Never import `yacht.dart` and `yacht_common.dart` in the same library: both
  export a different `htmlPrintDocument` (one takes a `tekartik_html`
  `Document`, the other a `package:html` one) and the names collide. Pick one,
  or `import ... as`.
* Documents come from `tekartik_html`: `htmlProviderHtml5Lib`
  (`package:tekartik_html/html_html5lib.dart`) parses with `package:html` and
  works everywhere, `htmlProviderUniversal`
  (`package:tekartik_html/html_universal.dart`) picks the browser dom on the
  web. `provider.createDocument(html: src)` then `htmlPrintDocument(doc)`, or
  the one-liner `provider.yachtTidyHtml(src)`.
* `tidyHtml` reads `srcFilePath`, tidies it and writes `dstFilePath`,
  **overwriting the source file when `dstFilePath` is omitted** (creating the
  destination directories first). It defaults to `htmlProviderHtml5Lib`.
  Tidying is not idempotent-safe on hand-formatted files: run it on generated
  output or commit before the first run.
* `HtmlPrinterOptions()` is a mutable holder: `indent` (`'  '`),
  `indentDepthMin` (2, the depth at which indentation starts, so `<html>` and
  `<head>` stay at column 0) and `contentLength` (80, where text is wrapped).
  Set them as fields after construction. The `isWindows` constructor flag is
  dead weight today: the printer always writes `\n`.
* What the printer does, and what it will do to a document: it normalises the
  doctype to `<!doctype html>`, indents from `indentDepthMin`, inlines an
  element unless its content starts *and* ends with whitespace, re-wraps text
  at `contentLength`, keeps `<pre>` content untouched, leaves `<style>` and
  `<script>` content unescaped, and escapes text elsewhere. Attribute order
  and quoting come out of the parser, so a round trip is not byte stable.
* Only three libraries are re-exported. The css side of the project
  (`compileCss`, `HtmlCssInliner`, `fixCssInline` in
  `package:tekartik_yacht/yacht_css.dart`), the mvp helpers
  (`yacht_mvp.dart`) and the `yacht` command line tool are **not** reachable
  through `package:yacht/...` — depend on `tekartik_yacht` for those.
* The barback transformer and the `pubspec.yaml` `transformers:` block of the
  repository README are historical (barback has been removed from dart):
  today it is `tidyHtml`, the printers, and the builders inside
  `tekartik_yacht`.
* `yachtAmpBoilerplate` is the constant AMP boilerplate (viewport meta,
  canonical link, `amp-boilerplate` style + noscript, the `v0.js` script) to
  inject in the `<head>` of an AMP page; it parses to 5 elements / 8 nodes.
* Tests: `dart pub get` then `dart test` at the repository root. The real
  suite lives in `packages/yacht` (`test/yacht_test.dart`,
  `test/html_printer_test.dart`, `test/yacht_io_html5lib_test.dart`); the root
  package has no test of its own.
* Anti-patterns: adding a new dependency on `yacht` (use `tekartik_yacht`);
  calling `tidyHtml` without `dstFilePath` on a source file you have not
  committed; expecting css compilation or the cli from this package;
  importing `package:yacht/src/...` (there is no `src/` here, everything is a
  re-export).

## Examples

Tidy a directory of generated html files (dart:io).

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:yacht/yacht_io.dart';

Future<void> main() async {
  var inputDir = Directory(join('example', 'input'));
  var outputDir = Directory(join('example', 'output'));
  await outputDir.create(recursive: true);

  var names = await inputDir
      .list()
      .map((fse) => basename(fse.path))
      .where((name) => extension(name) == '.html')
      .toList();
  for (var name in names) {
    // Without dstFilePath the source file is overwritten in place.
    await tidyHtml(
      srcFilePath: join(inputDir.path, name),
      dstFilePath: join(outputDir.path, name),
    );
  }
}
```

Tidy an html string in memory, with printer options.

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:yacht/yacht_common.dart';

String tidy(String src) {
  var options = HtmlPrinterOptions()
    ..indent = '    ' // 4 spaces
    ..contentLength = 100; // wrap text later
  var document = htmlProviderHtml5Lib.createDocument(html: src);
  return htmlPrintDocument(document, options: options);
}

void main() {
  print(tidy('''
<!doctype html>
<html>
<head><meta charset="utf-8"><title></title></head>
<body><p>hello</p></body>
</html>
'''));

  // Same thing in one call, with the default options.
  print(htmlProviderHtml5Lib.yachtTidyHtml('<html><body></body></html>'));
}
```

Tidy a document parsed with `package:html` (the html5lib flavour).

```dart
import 'package:html/parser.dart' show parse;
import 'package:yacht/yacht.dart';

/// Note: yacht.dart and yacht_common.dart must not be imported together,
/// their htmlPrintDocument take different Document types.
String tidyParsed(String src) => htmlPrintDocument(parse(src));

void main() {
  print(tidyParsed('<html><head><title>t</title></head><body>x</body></html>'));
}
```

Build an AMP page head and check the migration target compiles the same way.

```dart
// Migrated version: package:tekartik_yacht/yacht.dart instead of
// package:yacht/yacht_common.dart, same symbols.
import 'package:tekartik_html/html_universal.dart';
import 'package:tekartik_yacht/yacht.dart';

String ampPage({required String title, required String body}) {
  var provider = htmlProviderUniversal;
  var document = provider.createDocument(
    html:
        '<html><head>$yachtAmpBoilerplate<title>$title</title></head>'
        '<body>$body</body></html>',
  );
  return htmlPrintDocument(document);
}

void main() {
  print(ampPage(title: 'Article', body: '<p>content</p>'));
}
```
