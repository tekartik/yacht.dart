@TestOn("vm")

import 'test_common.dart';
import 'package:dev_test/test.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:process_run/dartbin.dart';

main() {
  group('build_release', () {
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

      _checkFile('simple.html', html());
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

      _checkFile('release_debug.html', html(head: '<title>release</title>'));

      // Removed (different in debug)
      _checkFileExists('part/included.part.css', isFalse);

      // markdown
      _checkFile(
          'post/simple_post.html',
          '''
<!doctype html>
<html>
<head></head>
<body>Simple post</body>
</html>''');
      _checkFileExists('post/simple_post.md', isFalse);

      // css
      _checkFile('simple.css', 'body { color:red; }');
      _checkFile('include.css', 'body { color:red; }');
      _checkFile('short.css', 'body{color:red}');
    });
  });
}
