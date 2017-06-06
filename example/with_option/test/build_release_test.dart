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

  group('build_release', () {
    // release build
    test('release', () async {
      //print(pkg);
      ProcessResult result = await run(
          dartExecutable, pubArguments(['build', 'example']),
          workingDirectory: projectTop, stderr: stderr);

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
  <style>body { color:red; } html { color:black; }</style>
</head>
<body>
</body>
</html>''');
      _checkFile('include.css', 'body { color:red; }');

      // ignored (i.e. no formatting
      if (Platform.isWindows) {
        _checkFile('ignored.css', 'body {\r\n\    color:red;\r\n}');
      } else {
        _checkFile(
            'ignored.css',
            '''
body {
    color: red;
}''');
      }
    });
  });
}
