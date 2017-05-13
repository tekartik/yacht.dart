library yacht.test.csslib_utils_test;

import 'package:dev_test/test.dart';
import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'package:yacht/src/csslib_utils.dart';

const simpleOptionsWithCheckedAndWarningsAsErrors = const PreprocessorOptions(
    useColors: false,
    checked: true,
    warningsAsErrors: true,
    inputFile: 'memory');

checkCompile(String input, String generated,
    {bool pretty: false, bool polyfill: false}) {
  expect(compileCss(input, pretty: pretty, polyfill: polyfill), generated);
}

checkNoPolyfill(String input, String generated, {bool pretty: false}) =>
    checkCompile(input, generated, pretty: pretty, polyfill: false);
checkPolyfill(String input, String generated, {bool pretty: false}) =>
    checkCompile(input, generated, pretty: pretty, polyfill: true);

checkPrettyPolyfill(String input, String generated) =>
    checkPolyfill(input, generated, pretty: true);

main() {
  group('csslib_utils', () {
    test('compileCss', () {
      expect(
          compileCss('@color1: red; body { color: @color1; }', pretty: false),
          'body { color:red; }');
    });
    test('less_@', () {
      String css = 'body{opacity:1}';
      expect(compileCss(css), compileCss(css, polyfill: false));
      css = '@color1: red; body { color: @color1; }';
      expect(compileCss(css), isNot(compileCss(css, polyfill: false)));
    });

    test('less_var', () {
      final input = '''
@color-background: red;
@color-foreground: blue;
.test {
  background-color: var(color-background);
  color: var(color-foreground);
}
''';
      final generated = '''
var-color-background: #f00;
var-color-foreground: #00f;

.test {
  background-color: var(color-background);
  color: var(color-foreground);
}''';
      checkCompile(input, generated, pretty: true);
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

      final generated = 'body { color:red; }';
      final generatedPretty = '''
body {
  color: #f00;
}''';
      checkPolyfill(css, generated); // the color is 'red'
      checkPrettyPolyfill(css, generatedPretty); // the color is '#f00';
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
          ':red { color1:; }'); // should be 'body { color: red; }'
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
      final input = '''
:host {
  --test-color1: red;
}
body {
  color: var(--test-color1);
}''';
      final generated =
          ':host { --test-color1:red; } body { color:var(--test-color1); }';

      checkNoPolyfill(input, generated);
    });

    // css3 vars not working
    test('simple_css3', () {
      String css = '''
:root {
  --test-color1: red;
}
body {
  color: var(--test-color1);
}''';
      // We should have: checkPolyfill(css, ':root { } body { color: red; }')
      checkPolyfill(css, ':root { --test-color1:red; } body { color:; }');
    });

    test('simple_var', () {
      // simple var implementation
      String css = '''
:root {
  var-test-color1: red;
}
body {
  color: var(test-color1);
}''';

      final generated = ':root { } body { color:red; }';

      final generatedPretty = '''
:root {
}
body {
  color: #f00;
}''';
      checkPolyfill(css, generated);
      checkPrettyPolyfill(css, generatedPretty);
    });

    test('nested_rule', () {
      // css3 vars not working
      String css = 'body { h1 { color: red ] }';
      StyleSheet sheet = compile(css,
          options: new PreprocessorOptions(polyfill: true), polyfill: true);

      expect(printStyleSheet(sheet, pretty: false),
          'body { } body h1 { color:red; }');
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
          '.red,.blue { color:red; } .blue { width:0; }');
    });

    test('pretty_pring_bug media_query', () {
      var input = '''
.good { color: red; }
@media screen { .better { color: blue; } }
.best { color: green }''';
      String generated = '''
.good {
  color: #f00;
}
@media screen {
.better {
  color: #00f;
}
}
.best {
  color: #008000;
}''';
      String shouldBe = '''
.good {
  color: #f00;
}
@media screen {
  .better {
    color: #00f;
  }
}
.best {
  color: #008000;
}''';
      checkPrettyPolyfill(input, generated);
      // bug: shouldBe should be the result!
      expect(generated, isNot(shouldBe));
    });
    test('extend_bug_media_query', () {
      String input;
      String generated;

      // extend works when a a single definition is used
      input =
          '.good { color: red; } @media screen { .better { @extend .good; } }';
      generated = '.good,.better { color:red; } @media screen{ .better { } }';
      // it should be: '.good { color: red; } @media screen { .better { color: red; } }
      checkPolyfill(input, generated);
    });

    test('extend_bug_multi_selector', () {
      String input;
      String generated;

      // extend works when a a single definition is used
      input = '.good { color: red; } .better { @extend .good; }';
      generated = '.good,.better { color:red; } .better { }';
      checkPolyfill(input, generated);

      // but not if use
      input = '.good { color: red; } .better,.best { @extend .good; }';
      generated = '.good,.better { color:red; } .better,.best { }';
      // it should be: generated = '.good,.better,.best { color: red; } .better,.best { }';
      checkPolyfill(input, generated);
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
          '.red,.blue { color:red; } @media screen{ .blue { width:100px; } }'); // NO!
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
          '@media screen{ .red,.blue { color:red; } } .blue { }');
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

      expect(printStyleSheet(sheet, pretty: false), 'body { color:red; }');
    });

    test('var_from_import', () {
      StyleSheet styleSheet1 = compile('@color1 = red;');
      StyleSheet styleSheet2 = parse('body {color:@color1}');
      //styleSheet2.topLevels.insertAll(0, styleSheet1.topLevels);

      String css = printStyleSheet(styleSheet2, pretty: false);
      expect(css, 'body { color:var(color1); }');

// Need to compile with polyfill with includes
      styleSheet2 = compile('body {color:@color1}',
          polyfill: true, includes: [styleSheet1]);
      //StyleSheet sheet =
      //StyleSheet sheet = compile(css, options: new PreprocessorOptions(polyfill: true));
      expect(
          printStyleSheet(styleSheet2, pretty: false), 'body { color:red; }');
    });

    test('pretty_print_bug_color', () {
      String input = 'body { color: red; }';
      final generated = 'body { color:red; }';
      final generatedPretty = '''
body {
  color: #f00;
}''';
      checkPolyfill(input, generated); // the color is 'red'
      checkPrettyPolyfill(input, generatedPretty); // the color is '#f00';
    });

    test('print_minify', () {
      String input = 'body { color: black; } div { }';
      final generated = 'body { color:black; } div { }';
      // should be 'body{color:#000}';
      checkPolyfill(input, generated); // the color is 'red'
    });
  });
}
