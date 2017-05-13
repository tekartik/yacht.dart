@TestOn("vm")

import 'test_common.dart';
import 'package:dev_test/test.dart';

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
