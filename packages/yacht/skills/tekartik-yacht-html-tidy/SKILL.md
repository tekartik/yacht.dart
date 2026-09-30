---
name: tekartik-yacht-html-tidy
description: >-
  Use when pretty printing, tidying or re-serializing an html document or
  file with package:tekartik_yacht (htmlPrintDocument, HtmlPrinterOptions,
  the yachtTidyHtml extension on a tekartik_html HtmlProvider,
  yachtAmpBoilerplate from yacht.dart; the package:html flavour of
  htmlPrintDocument in yacht_html5lib.dart; tidyHtml(srcFilePath:,
  dstFilePath:) in yacht_io.dart; the yacht executable). Covers the
  provider choice (htmlProviderHtml5Lib, htmlProviderWeb,
  htmlProviderUniversal), the formatting rules (inlining, indentation,
  wrapping, pre/style/script handling, escaping) and their limits. Css
  compilation and css inlining are in tekartik-yacht-css.
---

# tekartik_yacht: tidy html

`tekartik_yacht` ("Yet Another Css/Html Transformer", git only, not on
pub.dev) re-prints an html document with a fixed, opinionated layout: a
`<!doctype html>` line, `<html>`, `<head>` and `<body>` at column 0, two
space indentation below, elements kept inline unless their content starts
and ends with whitespace. The document comes from a `tekartik_html`
`HtmlProvider` (pure Dart html5lib parser, or the browser dom) or directly
from `package:html`.

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht.dart';

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
}
```

## Guidelines

### Libraries and providers

* Depend with git (`url: https://github.com/tekartik/yacht.dart`, `path:
  packages/yacht`) plus `tekartik_html` (`url:
  https://github.com/tekartik/html.dart`) for the providers.
* `package:tekartik_yacht/yacht.dart`, the multi platform entry point:
  `htmlPrintDocument(Document doc, {HtmlPrinterOptions? options})` for a
  `tekartik_html` `Document`, `HtmlPrinterOptions`, the
  `HtmlProviderYachtExt.yachtTidyHtml(String src, {options})` extension
  (`createDocument(html: src)` then print) and the `yachtAmpBoilerplate`
  constant. Works on the VM and in the browser.
* `package:tekartik_yacht/yacht_html5lib.dart`: `htmlPrintDocument` for a
  `package:html` `dom.Document` (`Document.html(src)` or `parse(src)`) and
  the same extension. Never import it together with `yacht.dart` without a
  prefix: the two `htmlPrintDocument` collide.
* `package:tekartik_yacht/yacht_io.dart`: `tidyHtml({required String
  srcFilePath, String? dstFilePath, HtmlProvider? htmlProvider})`,
  `dart:io` only. It reads the file, tidies it with `htmlProviderHtml5Lib`
  by default, creates the destination folders and writes `dstFilePath`,
  overwriting the source when `dstFilePath` is omitted.
* Providers: `htmlProviderHtml5Lib`
  (`package:tekartik_html/html_html5lib.dart`) parses with `package:html`,
  everywhere; `htmlProviderWeb` (`package:tekartik_html/html_web.dart`)
  uses the browser dom and throws `UnsupportedError('Web only')` on the
  VM; `htmlProviderUniversal` (`package:tekartik_html/html_universal.dart`)
  is the web one when compiled for the web, html5lib otherwise. The
  printer is the same for all; the parsers differ (see below).
* `yacht_css.dart` re-exports `yacht.dart`: one import when you also
  compile or inline css.

### What the printer does

* Output always starts with `<!doctype html>` (whatever the input doctype)
  and ends with a newline; lines are `\n` terminated.
* Indentation starts at depth `indentDepthMin` (default 2): `<html>`,
  `<head>`, `<body>` at column 0, their content indented by `indent`
  (default two spaces) per level. `HtmlPrinterOptions()` is a mutable
  holder, set the fields after construction.
* An element is printed inline (open tag, children, close tag on one line)
  unless its first text node starts with whitespace **and** its last text
  node ends with whitespace: `<a> link </a>` becomes three lines, `<a>
  link</a>` and `<a>link </a>` stay inline. A text node made of whitespace
  containing a newline is a line break; other runs of whitespace collapse
  to one space; a leading or trailing space of a text is kept as a single
  space. `<html>` is never inlined, `<head>` always gets its own line(s).
* Inline text runs are wrapped at `contentLength` (default 80) with
  continuation lines one level deeper; a block whose text is a single line
  is not wrapped.
* Text is escaped on output (`<` in a text node prints `&lt;`); the content
  of `<style>` and `<script>` is not escaped and is copied line by line
  (blank lines dropped, `\r` removed); `<pre>` content is copied untouched.
* Void elements print without slash (`<input />` becomes `<input>`,
  `<img/>` `<img>`), an attribute with an empty value prints bare
  (`<style amp-boilerplate>`); attribute order and quoting come from the
  parser: the round trip is stable in structure, not byte for byte.
* `<noscript>` content is re-parsed as html before printing (the parsers
  keep it as text); content that does not parse stays text.
* `htmlPrintDocument` and `yachtTidyHtml` only honour `indent` and
  `indentDepthMin` of the options they receive: the line builder keeps its
  default `contentLength` of 80 (the options are not passed down) and
  `isWindows` is unused (always `\n`). To wrap at another width drive the
  printer class yourself (example below).

### Parser side effects to expect

* `provider.createDocument(html: src)` (tekartik_html) normalizes the
  head: an empty or missing head gets `<meta charset="utf-8"><title></title>`;
  pass `noCharsetTitleFix: true` (or `charset: null`) to keep it as is.
  `package:html` `Document.html('')` keeps `<head></head>`.
* html5 parsing rules apply before printing: unknown elements inside
  `<head>` (`<my-tag>`) are moved to `<body>`, missing `html`, `head` and
  `body` are created, a newline after `</body>` or `</html>` becomes a
  text node inside `<body>` (hence `<body>\n</body>` in the output of a
  file ending with a newline).
* The browser dom is stricter than html5lib (a `<head>` fragment created
  outside a document comes back empty): use `htmlProviderHtml5Lib` in
  build tools, the universal provider in code shared with a web app.
* `yachtAmpBoilerplate` is the AMP boilerplate (viewport meta, canonical
  link, `amp-boilerplate` style and its noscript copy, the `v0.js`
  script): 5 elements, 8 nodes once parsed. Append its nodes to the
  `<head>` of an AMP document, then print; `<style amp-boilerplate>` keeps
  its bare attribute.

### Command line

* `bin/yacht.dart` (`dart run tekartik_yacht:yacht`, not listed in
  `executables:`) is a placeholder: it answers `--help` and `--version`
  (`0.1.0`) and prints the help for anything else, it does not tidy files.
  Tidy from a `tool/` script with `tidyHtml` (first example).

## Examples

### Tidy the html files of a folder (dart:io)

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_yacht/yacht_io.dart';

Future<void> main() async {
  var inputDir = Directory(join('web', 'raw'));
  var outputDir = Directory(join('web', 'tidy'));
  var names = await inputDir
      .list()
      .map((fse) => basename(fse.path))
      .where((name) => extension(name) == '.html')
      .toList();
  for (var name in names) {
    // Omit dstFilePath to overwrite the source file in place.
    await tidyHtml(
      srcFilePath: join(inputDir.path, name),
      dstFilePath: join(outputDir.path, name),
    );
  }
}
```

### Build a document and print it (tekartik_html)

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht.dart';

String indexPage(List<String> files) {
  var provider = htmlProviderHtml5Lib;
  var doc = provider.createDocument(title: 'Index');
  var ul = provider.createElementTag('ul');
  doc.body.appendChild(ul);
  for (var file in files) {
    var li = provider.createElementTag('li');
    li.appendChild(provider.createElementHtml('<a href="$file">$file</a>'));
    ul.appendChild(li);
    ul.appendChild(provider.createTextNode('\n')); // one <li> per line
  }
  return htmlPrintDocument(doc, options: HtmlPrinterOptions()..indent = '    ');
}

void main() {
  print(indexPage(['a.html', 'b.html']));
}
```

### Same input, two parsers (yacht.dart and yacht_html5lib.dart)

```dart
import 'package:html/dom.dart' as dom;
import 'package:tekartik_html/html_universal.dart';
import 'package:tekartik_yacht/yacht.dart';
import 'package:tekartik_yacht/yacht_html5lib.dart' as html5lib;

void main() {
  var src = '<html><head></head><body><p>x</p></body></html>';
  // tekartik_html provider: head normalized with charset and title.
  print(htmlProviderUniversal.yachtTidyHtml(src));
  // package:html document: head kept empty.
  print(html5lib.htmlPrintDocument(dom.Document.html(src)));
}
```

### AMP page head

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht.dart';

String ampPage({required String title, required String body}) {
  var provider = htmlProviderHtml5Lib;
  var doc = provider.createDocument(title: title);
  doc.html.setAttribute('⚡', '');
  var head = doc.head;
  head.appendChild(provider.createTextNode('\n'));
  var boilerplate = provider.createElementHtml(
    '<head>$yachtAmpBoilerplate</head>',
    noValidate: true,
  );
  for (var node in List.of(boilerplate.childNodes)) {
    head.appendChild(node);
  }
  head.appendChild(provider.createTextNode('\n'));
  doc.body.appendChild(provider.createElementHtml(body));
  return htmlPrintDocument(doc);
}

void main() {
  print(ampPage(title: 'Article', body: '<h1>Hello</h1>'));
}
```

### Wrap text at another width (printer class)

```dart
import 'package:tekartik_html/html_html5lib.dart';
// The public functions do not forward contentLength, the printer does.
// ignore: implementation_imports
import 'package:tekartik_yacht/src/html_printer_common.dart'
    show HtmlDocumentPrinterCommon, htmlPrintLines;
import 'package:tekartik_yacht/yacht.dart';

String tidyNarrow(String src, {int width = 40}) {
  var options = HtmlPrinterOptions()..contentLength = width;
  var doc = htmlProviderHtml5Lib.createDocument(html: src);
  var printer = HtmlDocumentPrinterCommon()..options = options;
  printer.visitDocument(doc);
  return htmlPrintLines(printer.lines, options: options);
}

void main() {
  print(tidyNarrow('<html><body><p>${'word ' * 20}</p></body></html>'));
}
```

## Common mistakes

* Importing `yacht.dart` and `yacht_html5lib.dart` unprefixed in the same
  file: `htmlPrintDocument` is ambiguous.
* Writing `HtmlPrinterOptions(contentLength: 100)`: the constructor only
  takes `isWindows`; set the fields after construction, and remember that
  `contentLength` is not forwarded by `htmlPrintDocument`.
* Calling `tidyHtml` without `dstFilePath` on a hand written file: it is
  rewritten in place.
* Expecting the input head to survive: `createDocument` adds the charset
  meta and an empty title unless `noCharsetTitleFix: true`.
* Putting custom elements in `<head>`: the parser moves them to `<body>`.
* Using `htmlProviderWeb` in code that also runs on the VM: use
  `htmlProviderUniversal`.
* Expecting `dart run tekartik_yacht:yacht` to tidy: it is a placeholder.

## More

* Package README for the git dependency snippet. Its "Html building"
  section (barback transformer, `yacht-include`, `yacht-debug` and
  `yacht-release` attributes, `import:`/`ignore:` options) describes a
  former implementation: none of it exists in the current code.
* [../tekartik-yacht-css/SKILL.md](../tekartik-yacht-css/SKILL.md) for
  `compileCss`, `HtmlCssInliner` and `fixCssInline`.
