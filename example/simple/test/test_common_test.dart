@TestOn("vm")
library yacht_example_simple.test.build_release_test;

import 'test_common.dart';
import 'package:dev_test/test.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:mirrors';
import 'package:process_run/process_run.dart';
import 'package:process_run/dartbin.dart';

main() {
  group('test_common', () {
    // release build
    test('html', () {
      expect(
          html(),
          '''
<!doctype html>
<html>
<head></head>
<body></body>
</html>''');
    });
    test('head', () {
      expect(
          html(head: '<meta>'),
          '''
<!doctype html>
<html>
<head>
  <meta>
</head>
<body></body>
</html>''');
    });
    test('body', () {
      expect(
          html(body: '<a></a>'),
          '''
<!doctype html>
<html>
<head></head>
<body>
  <a></a>
</body>
</html>''');
    });
  });
}
