library;

import 'package:tekartik_html/html_universal.dart';
import 'package:tekartik_yacht/src/yacht.dart';

import 'test_common.dart';

void main() {
  groupYacht(htmlProviderUniversal);
}

void groupYacht(HtmlProvider htmlProvider) {
  group('yacht', () {
    test('tidyHtml', () async {
      expect(htmlProvider.yachtTidyHtml('''
<!doctype html>
<html>
<head><meta charset="utf-8"><title></title></head>
<body></body>
</html>
'''), '''
<!doctype html>
<html>
<head><meta charset="utf-8"><title></title></head>
<body>
</body>
</html>
''');
    });
    test('amp boilerplate', () async {
      // ignore: unused_local_variable
      var head = htmlProvider.createElementHtml(
          '<head>$yachtAmpBoilerplate</head>',
          noValidate: true);
      // ignore: avoid_print
      print(head.outerHtml);
    });
  });
}
