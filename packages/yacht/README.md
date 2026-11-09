# tekartik_yacht

**Y**et **A**nother **C**ss/**H**tml **T**ransformer, pure Dart:

* tidy html: re-print a document with a stable, opinionated layout;
* compile css with [csslib](https://pub.dev/packages/csslib) (nested rules,
  `@extend`, minified or pretty output);
* inline the stylesheets of a page (`<link class="yacht-inline">` becomes a
  `<style>`);
* the minified [MVP.css](https://andybrewer.github.io/mvp/) classless
  stylesheet as a Dart string.

## Getting started

The package is not on pub.dev, add it as a git dependency, with
`tekartik_html` for the html parsers:

```yaml
dependencies:
  tekartik_yacht:
    git:
      url: https://github.com/tekartik/yacht.dart
      path: packages/yacht
  tekartik_html:
    git:
      url: https://github.com/tekartik/html.dart
```

Tidy html and compile css:

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht_css.dart';

void main() {
  print(
    htmlProviderHtml5Lib.yachtTidyHtml(
      '<html><body><p>Hello <b>world</b></p></body></html>',
    ),
  );
  // <!doctype html>
  // <html>
  // <head><meta charset="utf-8"><title></title></head>
  // <body><p>Hello <b>world</b></p></body>
  // </html>

  print(compileCss('body {\n  color: red;\n  h1 { margin: 0; }\n}'));
  // body{color:red}body h1{margin:0}
}
```

## Libraries and platforms

| Import | What | Platforms |
|---|---|---|
| `yacht.dart` | `htmlPrintDocument` (a `tekartik_html` `Document`), `HtmlPrinterOptions`, the `yachtTidyHtml` extension on an `HtmlProvider`, `yachtAmpBoilerplate` | all (VM, browser) |
| `yacht_css.dart` | `compileCss`, `HtmlCssInliner` (in memory) and `yacht.dart`; `fixCssInline` (file to file) | all; `fixCssInline` io only |
| `yacht_html5lib.dart` | `htmlPrintDocument` for a `package:html` document | all |
| `yacht_io.dart` | `tidyHtml(srcFilePath:, dstFilePath:)` | io only (`dart:io`) |
| `yacht_mvp.dart` | `cssMvpMin`, the minified MVP.css | all |

The html comes from a `tekartik_html` provider: `htmlProviderHtml5Lib`
(`package:html` parser, everywhere, the choice for build tools),
`htmlProviderWeb` (browser dom, web only) or `htmlProviderUniversal` (the web
one on the web, html5lib elsewhere).

## Tidy rules

* The output starts with `<!doctype html>`, `<html>`, `<head>` and `<body>` at
  column 0, two space indentation below, `\n` line endings.
* An element stays on one line unless its content starts **and** ends with
  whitespace; whitespace runs collapse to one space and long text is wrapped
  at 80 columns.
* Text is escaped (`&lt;`); the content of `<style>` and `<script>` is kept as
  is and `<pre>` content untouched.
* `tekartik_html`'s `createDocument(html:)` adds a missing
  `<meta charset="utf-8">` and `<title>` to the head.

## Inlining stylesheets

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht_css.dart';

Future<void> main() async {
  var styles = {'style.css': 'body { color: red; }'};
  var inliner = HtmlCssInliner(
    htmlProvider: htmlProviderHtml5Lib,
    // The css text of a href, null to keep the <link>.
    inliner: (href) async => styles[href],
  );
  print(
    await inliner.build(
      '<html><head><link class="yacht-inline" rel="stylesheet" '
      'href="style.css"></head><body>Hello</body></html>',
    ),
  );
  // ...<style>body { color: red; }</style>...
}
```

`fixCssInline('web/index.html', 'build/index.html')` does the same on files,
each `href` read relative to the html file.

## Common pitfalls

* The layout is opinionated: re-printing changes whitespace and attribute
  quoting (the structure is kept, not the bytes).
* `HtmlPrinterOptions(isWindows: true)` does not give CRLF line endings, and
  `htmlPrintDocument` only uses the `indent` and `indentDepthMin` options.
* csslib has no `@name: value` variables: use css custom properties
  (`--name` and `var(--name)`) with `polyfill: false` (the default).
* `tidyHtml` without `dstFilePath` rewrites the source file.
* `yacht.dart` and `yacht_html5lib.dart` both define `htmlPrintDocument`:
  prefix one of them when importing both.
* The `yacht` executable (`bin/yacht.dart`) only prints its usage.
* The barback transformer of the former `yacht` package (`yacht-include`,
  `yacht-html`/`yacht-head`/`yacht-body`, `yacht-debug`/`yacht-release`,
  `yacht-ignore`, the `import:`/`ignore:` options, less style variables) no
  longer exists.

Agent skills: [skills/tekartik-yacht-html-tidy](skills/tekartik-yacht-html-tidy/SKILL.md)
and [skills/tekartik-yacht-css](skills/tekartik-yacht-css/SKILL.md).
