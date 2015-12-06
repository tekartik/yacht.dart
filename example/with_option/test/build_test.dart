@TestOn("vm")
library yacht_example_with_option.test.build_test;

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
  // expect to find the result in build
  String outPath = join(projectTop, 'build', 'example');

  _checkFile(String file, String content) {
    expect(new File(join(outPath, file)).readAsStringSync(), content);
  }

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
      _checkFile('include.css', 'body { color: red; }');

      // ignored (i.e. no formatting
      _checkFile(
          'ignored.css',
          '''
body {
    color: red;
}''');
    });

    // debug build
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
      //TODO
      /*

      String outPath = join(projectTop, 'build', 'example');

      _checkFile(String file, String content) {
        expect(new File(join(outPath, file)).readAsStringSync(), content);
      }

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

      // debug import
      _checkFile('include.css', 'body {\n  color: #f00;\n}');
      */
    });
  });
}
