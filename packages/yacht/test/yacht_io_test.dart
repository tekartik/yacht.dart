@TestOn('vm')
library;

import 'dart:io';

import 'package:tekartik_yacht/yacht_io.dart';

import 'test_common.dart';

void main() {
  group('yacht_io', () {
    test('tidyHtml', () async {
      var dstFilePath = '.dart_tool/yacht/test/yacht_io/min.html';
      await tidyHtml(
          srcFilePath: 'test/data/yacht_io/min.html', dstFilePath: dstFilePath);
      expect(await File(dstFilePath).readAsString(), '''
<!doctype html>
<html>
<head><meta charset="utf-8"><title></title></head>
<body></body>
</html>
''');
    });
  });
}
