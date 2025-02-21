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
      expect(
        htmlProvider.yachtTidyHtml('''
<!doctype html>
<html>
<head><meta charset="utf-8"><title></title></head>
<body></body>
</html>
'''),
        '''
<!doctype html>
<html>
<head><meta charset="utf-8"><title></title></head>
<body>
</body>
</html>
''',
      );
    });
    test('amp boilerplate', () async {
      // ignore: unused_local_variable
      var head = htmlProvider.createElementHtml(
        '<head>$yachtAmpBoilerplate</head>',
        noValidate: true,
      );
      // ignore: unused_local_variable
      var head2 = htmlProvider.createElementHtml(
        '<div>$yachtAmpBoilerplate</div>',
        noValidate: true,
      );
      if (htmlProvider is HtmlProviderWeb) {
        // ignore: avoid_print
        //print(head.outerHtml);
        //print(head2.outerHtml);
        expect(head.children.length, 0);
        expect(head2.children.length, 5);
        //expect(head.innerHtml, head2.innerHtml);
      } else {
        // ignore: avoid_print

        expect(head.innerHtml, head2.innerHtml);
      }
    });
    test('amp boilerplate', () async {
      // ignore: unused_local_variable
      var boilerplateElements = htmlProvider.createElementsHtml(
        yachtAmpBoilerplate,
      );
      expect(boilerplateElements.length, 5);
      var boilerplateNodes = htmlProvider.createNodesHtml(yachtAmpBoilerplate);
      expect(boilerplateNodes.length, 8);
    });
  });
}
