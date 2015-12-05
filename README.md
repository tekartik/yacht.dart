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
* import: can be `true`, `false` or `release` (default), it controls whether
  css @import are embedded in the source document. By default @import are not
  embedded in debug mode


````
  - yacht:
      import: true # @import will be included in debug mode too
````

### Tidy html

This is a purely opiniated formatting, keep some existing formatting

### Html building

An external file can be included at build time:
````
<meta property="yacht-include" content="_included.html">
````

## Development

### Dependencies

* [html](https://pub.dartlang.org/packages/html)
* [csslib](https://pub.dartlang.org/packages/csslib)
* [barback](https://pub.dartlang.org/packages/barback)

### HTML formatting rules

* An element is not inlined if it begins with a text node with a whitespace at the beginning
