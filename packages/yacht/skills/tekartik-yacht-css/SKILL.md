---
name: tekartik-yacht-css
description: >-
  Use when compiling, minifying or inlining css for an html page with
  package:tekartik_yacht (compileCss with pretty/polyfill from
  yacht_css.dart and the csslib nested rules, @extend and var- syntax it
  accepts; HtmlCssInliner and HtmlCssHrefInlinerFunction to replace
  <link class="yacht-inline"> by <style> in memory; fixCssInline(src, dst)
  on files; cssMvpMin from yacht_mvp.dart, the minified MVP.css classless
  stylesheet). Covers what csslib does and does not support, the inlining
  rules and the tidy printing of the result. Html tidying alone is in
  tekartik-yacht-html-tidy.
---

# tekartik_yacht: css compile and inline

`package:tekartik_yacht/yacht_css.dart` wraps `csslib` for a lightweight
css preprocessing step (`compileCss`) and replaces stylesheet links marked
`yacht-inline` by `<style>` elements, in memory with `HtmlCssInliner` or
file to file with `fixCssInline`. The result is printed with the yacht html
printer (`yacht.dart` is re-exported). `yacht_mvp.dart` provides the
minified MVP.css as a Dart string. Git only, not on pub.dev.

```dart
import 'package:tekartik_yacht/yacht_css.dart';

void main() {
  print(compileCss('body {\n  color: red;\n  h1 { margin: 0; }\n}'));
  // body{color:red}body h1{margin:0}
}
```

## Guidelines

### compileCss

* `compileCss(String input, {bool polyfill = false, bool pretty = false})`
  is csslib `compile(input, polyfill:)` followed by its `CssPrinter`: with
  `pretty: false` (default) the output is minified on one line, with
  `pretty: true` one declaration per line, two space indent. Pure Dart, VM
  and browser.
* What csslib adds on top of plain css: nested rules (`body { h1 { color:
  red } }` gives `body h1 { color: red }`, plus an empty `body {}` rule in
  pretty mode) and `@extend .selector` (the extended rule gets the
  extending selector: `.important, .super-important { color: red }`).
* The README's "less style variable" `@name: value;` is not a variable:
  csslib parses it as its legacy `var-name: value` declaration and `@name`
  usages print as `var(name)`, nothing is substituted. Standard custom
  properties (`--name: value` and `var(--name)`) pass through unchanged
  with `polyfill: false`.
* `polyfill: true` asks csslib to expand `var()` usages; on the standard
  `var(--name)` syntax it produces empty declarations (`color: ;`). Keep
  `polyfill: false`.
* Invalid css does not throw: csslib drops what it cannot parse (an
  unterminated `color:` prints as `color: ;`). Validate elsewhere.
* Values may be rewritten (pretty mode prints `red` as `#f00`); the
  minified output keeps the source text.

### Inlining a stylesheet into the page

* Mark the `<link>` to inline with the class `yacht-inline`:
  `<link class="yacht-inline" rel="stylesheet" href="style.css">`. Only
  `<link>` elements carrying the class are replaced; other elements with
  the class are ignored.
* `HtmlCssInliner({required HtmlProvider htmlProvider, required
  HtmlCssHrefInlinerFunction inliner})`, then `Future<String>
  build(String source)`: parses `source` with the provider, calls
  `inliner(href)` for each marked link (a `Future<String?> Function(String
  href)`: return the css text, or `null` to leave the link untouched),
  replaces the link by a `<style>` holding the css as text, and returns the
  document printed by `htmlPrintDocument` (tidy layout, `<!doctype html>`
  first).
* Attributes of the link other than `href`, `rel`, `type` and `class` are
  copied to the `<style>` (`<link data-custom ...>` gives
  `<style data-custom>`). Multi line css is written after a leading
  newline so the rules start on their own lines. Style content is not
  escaped.
* The `inliner` callback owns resolution and reading: it receives the raw
  `href` value, resolve it against the html location yourself (relative
  path, package asset, http fetch...), and minify with `compileCss` there
  when wanted.
* `fixCssInline(String srcHtmlFilePath, String dstHtmlFilePath)`
  (`dart:io`, `package:html` parser): same replacement on a file, the
  `href` resolved relative to the html file's folder and read from disk,
  output written to `dstHtmlFilePath`, whose folder must exist. A missing
  css file throws (`PathNotFoundException`).
* Both print the whole document through the yacht printer: the rest of the
  page is re-formatted too.

### MVP.css

* `package:tekartik_yacht/yacht_mvp.dart` exports `cssMvpMin`, the
  minified MVP.css classless stylesheet (about 8 KB) as a `String`: put it
  in a `<style>` for a quick page built from semantic html, or write it to
  a `mvp.min.css` asset.
* `lib/src/mvp/mvp.css` is the source; `cssMvpMin` is
  `compileCss(source)`, the same call minifies your own stylesheet.

## Examples

### Minify a stylesheet at build time

```dart
import 'dart:io';

import 'package:tekartik_yacht/yacht_css.dart';

Future<void> main() async {
  var css = await File('web/style.css').readAsString();
  await File('web/style.min.css').writeAsString(compileCss(css));
}
```

### Inline the stylesheets of a page in memory (dart:io resolution)

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht_css.dart';

Future<String> inlinePage(String htmlPath) async {
  var dir = dirname(htmlPath);
  var inliner = HtmlCssInliner(
    htmlProvider: htmlProviderHtml5Lib,
    inliner: (href) async {
      var file = File(normalize(join(dir, href)));
      if (!file.existsSync()) {
        return null; // keep the <link>
      }
      // Minified before inlining.
      return compileCss(await file.readAsString());
    },
  );
  return inliner.build(await File(htmlPath).readAsString());
}

Future<void> main() async {
  print(await inlinePage('web/index.html'));
}
```

### Inline from a map (tests, web)

```dart
import 'package:tekartik_html/html_universal.dart';
import 'package:tekartik_yacht/yacht_css.dart';

Future<void> main() async {
  var styles = {'style1.css': 'body { color: red; }'};
  var inliner = HtmlCssInliner(
    htmlProvider: htmlProviderUniversal,
    inliner: (href) async => styles[href],
  );
  print(await inliner.build('''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <link data-custom class="yacht-inline" rel="stylesheet" href="style1.css" type="text/css">
</head>
<body>
Hello
</body>
</html>
'''));
  // <!doctype html>
  // <html lang="en">
  // <head>
  //   <meta charset="UTF-8">
  //   <title>Title</title>
  //   <style data-custom>body { color: red; }</style>
  // </head>
  // <body>
  //   Hello
  // </body>
  // </html>
}
```

### File to file

```dart
import 'dart:io';

import 'package:tekartik_yacht/yacht_css.dart';

Future<void> main() async {
  await Directory('build/web').create(recursive: true);
  // <link class="yacht-inline" href="style.css"> is read next to index.html.
  await fixCssInline('web/index.html', 'build/web/index.html');
}
```

### MVP page

```dart
import 'package:tekartik_html/html_html5lib.dart';
import 'package:tekartik_yacht/yacht.dart';
import 'package:tekartik_yacht/yacht_mvp.dart';

String mvpPage(String title, String bodyHtml) {
  var provider = htmlProviderHtml5Lib;
  var doc = provider.createDocument(title: title);
  var style = provider.createElementTag('style');
  style.text = cssMvpMin;
  doc.head.appendChild(style);
  doc.body.appendChild(provider.createElementHtml('<main>$bodyHtml</main>'));
  return htmlPrintDocument(doc);
}

void main() {
  print(mvpPage('Hello', '<h1>Hello</h1><p>MVP styled.</p>'));
}
```

## Common mistakes

* Expecting `@color: red;` to be substituted: csslib turns it into
  `var-color` / `var(color)`, nothing is replaced.
* `polyfill: true` on `var(--x)`: empty declarations.
* Forgetting the `yacht-inline` class, or putting it on a `<style>` or an
  `<a>`: nothing is replaced.
* Returning the css path instead of its content from the `inliner`
  callback: the path ends up inside `<style>`.
* `fixCssInline` into a folder that does not exist: `PathNotFoundException`
  on write.
* Importing `yacht_css.dart` and `yacht_html5lib.dart` together unprefixed:
  `htmlPrintDocument` collides (`yacht_css.dart` re-exports `yacht.dart`).

## More

* Package README, "Css preprocessing" section (its `import:` and `ignore:`
  transformer options are barback era and not implemented).
* [../tekartik-yacht-html-tidy/SKILL.md](../tekartik-yacht-html-tidy/SKILL.md)
  for the printer rules applied to the inlined page.
