# yacht.dart

**Y**et **A**nother **C**ss/**H**tml **T**ransformer: tidy html, compile and
inline css, in pure Dart.

The package to use is **`tekartik_yacht`**, in
[packages/yacht](packages/yacht) (getting started, platforms, examples):

```yaml
dependencies:
  tekartik_yacht:
    git:
      url: https://github.com/tekartik/yacht.dart
      path: packages/yacht
```

The root package `yacht` is a deprecated compatibility shim: its libraries
(`yacht.dart`, `yacht_common.dart`, `yacht_io.dart`) re-export
`tekartik_yacht` (agent skill: [skills/yacht-tidy-html](skills/yacht-tidy-html/SKILL.md)).
Replace `package:yacht/yacht_common.dart` by
`package:tekartik_yacht/yacht.dart`, `package:yacht/yacht.dart` by
`package:tekartik_yacht/yacht_html5lib.dart` and `package:yacht/yacht_io.dart`
by `package:tekartik_yacht/yacht_io.dart`.

The barback transformer of the former `yacht` package (`yacht-include`,
`yacht-debug`, `import:`/`ignore:` options...) no longer exists.
