@TestOn("vm")
library yacht_example_simple.test.build_test;

import 'package:dev_test/test.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:mirrors';
import 'package:process_run/process_run.dart';
import 'package:process_run/dartbin.dart';

class _TestUtils {
  static final String scriptPath =
      (reflectClass(_TestUtils).owner as LibraryMirror).uri.toFilePath();
}

String get testScriptPath => _TestUtils.scriptPath;
String get projectTop => dirname(dirname(testScriptPath));

main() {
  group('build', () {
    // release build
    test('release', () async {
      //print(pkg);
      ProcessResult result = await run(
          dartExecutable, pubArguments(['build', 'example']),
          connectStderr: true,
          workingDirectory: projectTop,
          connectStdout: false);

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }

      // expect to find the result in build
      String outPath = join(projectTop, 'build', 'example');

      _checkFile(String file, String content) {
        expect(new File(join(outPath, file)).readAsStringSync(), content);
      }
      _checkFile(
          'simple.html',
          '''
<!doctype html>
<html>
<head></head>
<body></body>
</html>''');
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
<body>Hello World! </body>
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
          'import.html',
          '''
<!doctype html>
<html>
<head>
  <style>body { color: red; } html { color: black; }</style>
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
  <script async src="test.dart.js"></script>
</head>
<body></body>
</html>''');

      // css
      _checkFile('simple.css', 'body { color: red; }');
      _checkFile('include.css', 'body { color: red; }');
      _checkFile('short.css', 'body{color:red}');
    });

    // debug build
    // - no import
    test('debug', () async {
      //print(pkg);
      ProcessResult result = await run(
          dartExecutable, pubArguments(['build', 'example', '--mode', 'debug']),
          connectStderr: true,
          workingDirectory: projectTop,
          connectStdout: false);

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }

      // expect to find the result in build
      String outPath = join(projectTop, 'build', 'example');

      _checkFile(String file, String content) {
        expect(new File(join(outPath, file)).readAsStringSync(), content);
      }
      _checkFile(
          'simple.html',
          '''
<!doctype html>
<html>
<head></head>
<body></body>
</html>''');
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
<body>Hello World! </body>
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

      // debug pretty style
      _checkFile(
          'import.html',
          '''
<!doctype html>
<html>
<head>
  <style>
    @import "part/included.part.css";
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

      // css

      // debug pretty style
      _checkFile('simple.css', 'body {\n  color: #f00;\n}');
      // debug no import
      _checkFile('include.css', '@import "simple.css";');
      _checkFile('short.css', 'body{color:red}');
    });
  });
}
