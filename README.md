# yacht.dart

**Y**et **A**nother **C**ss/**H**tml **T**ransformer

* tidy hml (using [html](https://pub.dartlang.org/packages/html) package)
* lightweight less/scss parser (using [csslib](https://pub.dartlang.org/packages/csslib) package)
* script/css inlining
* exported as transformer (using [barback](https://pub.dartlang.org/packages/barback) package)
* pure dart

[![Build Status](https://travis-ci.org/tekartik/yacht.dart.svg?branch=master)](https://travis-ci.org/tekartik/yacht.dart)

## install as a transformer

in your `pubspec.yaml`

````
...
dependencies:
  yacht: any
  ...
transformers:
  - yacht
  ...
````

options
* import: can be `true` (default), `false`, `debug` or `release`; it controls whether
  css @import are embedded in the source document. By default @import are awlays embedded
* ignore: list of file ignored by the transformer

````
  - yacht:
      import: true # @import will be included in debug mode too
      ignore:
        - example/style.css
````

### Tidy html

This is a purely opiniated formatting, keep some existing formatting

### Html building

An external file can be included at build time:
````
<meta property="yacht-include" content="_included.html">
````

or

````
<yatch-include src="_included.html"></yacht-include>
````

#### yacht-html, yacht-head, yacht-body

Builtin replacement:

````
<yacht-html>
    <yacht-head>
        <title>my title</title>
    </yacht-head>
    <yacht-body>
        My body
    </yacht-body>
</yacht-html>
````

#### Debug vs Release

`yacht-debug` and `yacht-release` attributes (as well as the one with `data-` prefix)
allow to have an element only in one build mode

### Ignore

Transformation is ignored for
* style with `data-yatch-ignore` or `yacht-ignore` attribute
  Example needed for AMP pages
````
<style yacht-ignore>body {opacity: 0}</style>
````

* css file in ignore list of Barback

## Development

### Dependencies

* [html](https://pub.dartlang.org/packages/html)
* [csslib](https://pub.dartlang.org/packages/csslib)
* [barback](https://pub.dartlang.org/packages/barback)

### HTML formatting rules

* An element is not inlined if it begins with a text node with a whitespace at the beginning
