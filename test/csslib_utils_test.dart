library yacht.test.csslib_utils_test;

import 'package:dev_test/test.dart';
import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'package:yacht/src/csslib_utils.dart';

main() {
  group('csslib_utils', () {
    test('compileCss', () {
      expect(
          compileCss('@color1: red; body { color: @color1; }', pretty: false),
          'body { color: red; }');
    });
    test('less var', () {
      String css = 'body{opacity:1}';
      expect(compileCss(css), compileCss(css, polyfill: false));
      css = '@color1: red; body { color: @color1; }';
      expect(compileCss(css), isNot(compileCss(css, polyfill: false)));
    });
  });
  //YachtTransformer transformer;
  group('csslib_exp', () {
    test('simple_less_var', () {
      String css = '''
@color1: red;
body {
color: @color1;
}''';
      StyleSheet sheet = compile(css, polyfill: true);

      expect(printStyleSheet(sheet, pretty: false), 'body { color: red; }');
    });
    test('simple_less_rule', () {
      // not working
      String css = '''
@color1: color: red;
body {
  @color1
}''';
      StyleSheet sheet = compile(css, polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          ':red { color1: ; }'); // should be 'body { color: red; }'
    });
    test('simple_scss_var', () {
      // not working
      String css = '''
\$color1: red;
body {
color: \$color1;
}''';
      StyleSheet sheet = compile(css, polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          ''); // should be'''body { color: red; }');
    });

    test('simple_css3_var_no_polyfill', () {
      String css = '''
:host {
  --test-color1: red;
}
body {
  color: var(--test-color1);
}''';
      StyleSheet sheet = compile(css);

      expect(printStyleSheet(sheet, pretty: false),
          ':host { --test-color1: red; } body { color: var(--test-color1); }');
    });

    test('simple_css3', () {
      // css3 vars not working
      String css = '''
:host {
  --test-color1: red;
}
body {
  color: var(--test-color1);
}''';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          ':host { --test-color1: red; } body { color: ; }');
    });

    test('nested_rule', () {
      // css3 vars not working
      String css = 'body { h1 { color: red ] }';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          'body { } body h1 { color: red; }');
    });

    /*
    test('less_mixin', () {
      // css3 vars not working
      String css = '.red { color: red } body { .red }';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          'body { } body h1 { color: red; }');
    });
    */

    test('scss_extend', () {
      // css3 vars not working
      String css = r'''
.red { color: red; }
.blue { @extend .red; width: 0 }
''';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          '.red,.blue { color: red; } .blue { width: 0; }');
    });

    test('scss_media_query_var_and_extend', () {
      // css3 vars not working inside media query
      // global var working ok
      String css = r'''
@width = 100px;
.red { color: red; }
@media screen {
  .blue { @extend .red; width: @width }
}
''';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          '.red,.blue { color: red; } @media screen { .blue { width: 100px; } }'); // NO!
    });

    test('scss_media_inner_class', () {
      // css3 vars not working inside media query
      // global var working ok
      String css = r'''
@media screen {
  .red { color: red; }
}
.blue { @extend .red; }
''';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          '@media screen { .red,.blue { color: red; } } .blue { }');
    });

    /*
    hangs

    test('scss_mixin', () {
      // css3 vars not working
      String css = r'''
@mixin border-radius($radius) {
  -webkit-border-radius: $radius;
     -moz-border-radius: $radius;
      -ms-border-radius: $radius;
          border-radius: $radius;
}

.box { @include border-radius(10px); }
''';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          '.red,.blue { color: red; } .blue { width: 0; }');
    });
    */

    /*
    skip_test('simple_apply', () {
      // css3 vars not working
      String css = '''
      :host {
        --test-color1: {
          color: red;
        }
      }
      body { @apply(--test-color1) }''';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: false), polyfill: false);

      //expect(printStyleSheet(sheet, pretty: false),
      //    ':host { --test-color1: { color: red; } } body { @apply(--test-color1) }');
      expect(printStyleSheet(sheet, pretty: false),
          '''
      :host {
        --test-color1: {
          color: red;
        }
      }
      body { @apply(--test-color1) }''');
    });
    */

    test('comments', () {
      String css = '''
/* comment */
body {
color: red;
}''';
      StyleSheet sheet = compile(css, polyfill: true);

      expect(printStyleSheet(sheet, pretty: false), 'body { color: red; }');
    });

    test('var_from_import', () {
      StyleSheet styleSheet1 = compile('@color1 = red;');
      StyleSheet styleSheet2 = parse('body {color:@color1}');
      //styleSheet2.topLevels.insertAll(0, styleSheet1.topLevels);

      String css = printStyleSheet(styleSheet2, pretty: false);
      expect(css, 'body { color: var(color1); }');

// Need to compile with polyfill with includes
      styleSheet2 = compile('body {color:@color1}',
          polyfill: true, includes: [styleSheet1]);
      //StyleSheet sheet =
      //StyleSheet sheet = compile(css, options: new PreprocessorOptions(polyfill: true));
      expect(
          printStyleSheet(styleSheet2, pretty: false), 'body { color: red; }');
    });
  });
}
