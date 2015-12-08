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
    test('result', () {
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
