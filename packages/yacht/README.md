# yacht.dart

**Y**et **A**nother **C**ss/**H**tml **T**ransformer

* tidy hml (using [html](https://pub.dartlang.org/packages/html) package)
* lightweight less/scss parser (using [csslib](https://pub.dartlang.org/packages/csslib) package)
* script/css inlining
* exported as transformer (using [barback](https://pub.dartlang.org/packages/barback) package)
* pure dart

[![Build Status](https://travis-ci.org/tekartik/yacht.dart.svg?branch=master)](https://travis-ci.org/tekartik/yacht.dart)

## install dependencies

in your `pubspec.yaml`

```yaml
dependencies:
  tekartik_yacht:
    git:
      url: https://github.com/tekartik/yacht.dart
      path: packages/yacht
      ref: dart3a
...
```

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

This is a purely opiniated formatting, keeping some existing
formatting especially whitespace before/after a tag

### Css preprocessing

Provide a leighweight css preprocessor:
* support for `less` style variable
````
@test-color: red
body {
  color: @test-color;
}
````
* support for nested rules i.e.
````
body {
  h1 {
    color: red;
  }
}
````
* support for scss like mixin
````
.important {
  color: red;
}
.super-important {
  @extend .important;
  width: 100px;
}
````

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

### Limitations

* `<noscript>` content is not parsed using the html package. Its content is displayed as is (no style computing)