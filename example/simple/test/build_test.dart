@TestOn("vm")
library yacht_transformer_example_simple.test.build_test;

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
    //_test.Context ctx;
    test('runBuild', () async {
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
      expect(
          new File(join(outPath, 'simple.html')).readAsStringSync(),
          '''
<!doctype html>
<html>
<head>
</head>
<body>
</body>
</html>''');
    });
  });
}
