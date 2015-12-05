@TestOn("vm")
library tekartik_uppercase_transformer_test;

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
String get simpleProjectTop => join(projectTop, 'example', 'simple');

main() {
  group('example_simple', () {
    test('runTest', () async {
      ProcessResult result = await run(
          dartExecutable, pubArguments(['get', '--offline']),
          connectStderr: true, workingDirectory: simpleProjectTop);

      expect(result.exitCode, 0);

      result = await run(dartExecutable, pubArguments(['run', 'test']),
          connectStdout: true,
          connectStderr: true,
          workingDirectory: simpleProjectTop);

      // on 1.13, current windows is failing
      if (!Platform.isWindows) {
        expect(result.exitCode, 0);
      }
    });
  });
}
