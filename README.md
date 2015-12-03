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

````
````

## Development

### Dependencies

* [html](https://pub.dartlang.org/packages/html)
* [csslib](https://pub.dartlang.org/packages/csslib)
* [barback](https://pub.dartlang.org/packages/barback)