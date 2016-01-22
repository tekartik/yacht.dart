@TestOn("vm")
library yacht_example_simple.test.build_test;

import 'package:dev_test/test.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'test_common.dart';

main() {
  // debug build
  // - no import
  group('build_debug', () {
    test('debug', () async {
      //print(pkg);
      ProcessResult result =
          await runCmd(pubCmd(['build', 'example', '--mode', 'debug'])
            ..connectStderr = true
            ..workingDirectory = projectTop
            ..connectStdout = false);
      //..connectStdout = true); int w;

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }

      // expect to find the result in build
      String outPath = join(projectTop, 'build', 'example');

      _getFileContent(String file) {
        return new File(join(outPath, file)).readAsStringSync();
      }
      _checkFile(String file, String content) {
        expect(_getFileContent(file), content);
      }
      _checkFileExists(String file, Matcher exists) {
        expect(new File(join(outPath, file)).existsSync(), exists);
      }
      _checkFile(
          'simple.html',
          '''
<!doctype html>
<html>
<head></head>
<body></body>
</html>''');
      // style is pretty here
      _checkFile(
          'amp_basic.html',
          '''
<!doctype html>
<html ⚡ lang="en">
<head>
  <meta charset="utf-8">
  <title>Basic</title>
  <link rel="canonical" href="amp_basic.html">
  <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1">
  <style amp-custom></style>
  <style>body {opacity: 0}</style>
  <noscript><style>body {opacity: 1}</style></noscript>
  <script async src="https://cdn.ampproject.org/v0.js"></script>
</head>
<body>Hello World!</body>
</html>''');

      _checkFile(
          'include.html',
          '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Included Title</title>
</head>
<body></body>
</html>''');

      _checkFile(
          'include_meta.html',
          '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Included Title</title>
</head>
<body></body>
</html>''');

      // debug pretty style
      _checkFile(
          'import.html',
          '''
<!doctype html>
<html>
<head>
  <style>
    body {
      color: #f00;
    }
    html {
      color: #000;
    }
  </style>
</head>
<body>
</body>
</html>''');

      _checkFile(
          'with_dart_script.html',
          '''
<!doctype html>
<html>
<head>
  <script async type="application/dart" src="test.dart"></script>
  <script async src="packages/browser/dart.js"></script>
</head>
<body></body>
</html>''');

      _checkFile('release_debug.html', html(head: '<title>debug</title>'));
      // not Removed (different in debug)
      _checkFileExists('part/included.part.css', isTrue);

      // markdown
      _checkFile(
          'post/simple_post.html',
          '''
<!doctype html>
<html>
<head></head>
<body>Simple post</body>
</html>''');
      _checkFileExists('post/simple_post.md', isTrue);

      // css

      // debug pretty style
      _checkFile('simple.css', 'body {\n  color: #f00;\n}');
      // debug no import
      _checkFile('include.css', 'body {\n  color: #f00;\n}');
      _checkFile('short.css', 'body{color:red}');
    });
  });
}
