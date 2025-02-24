library;

import 'package:tekartik_html/html_universal.dart';
import 'package:tekartik_yacht/src/html_css_inliner.dart';

import 'test_common.dart';

void main() {
  groupCssInliner(htmlProviderUniversal);
}

final _map = {'style1.css': 'body { color: red; }'};
void groupCssInliner(HtmlProvider htmlProvider) {
  group('html_css_inliner', () {
    test('fixCssInline', () async {
      var inliner = HtmlCssInliner(
        htmlProvider: htmlProvider,
        inliner: (href) async {
          var key = href;

          var replaceValue = _map[key];

          return replaceValue;
        },
      );
      var inlined = await inliner.build('''
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
''');
      expect(
        inlined,
        '<!doctype html>\n'
        '<html lang="en">\n'
        '<head>\n'
        '  <meta charset="UTF-8">\n'
        '  <title>Title</title>\n'
        '  <style data-custom>body { color: red; }</style>\n'
        '</head>\n'
        '<body>\n'
        '  Hello\n'
        '</body>\n'
        '</html>\n',
      );
    });
  });
}
